import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { User } from '../entities/user.entity';
import { DoctorProfile } from '../entities/doctor-profile.entity';
import { HealthRecord } from '../entities/health-record.entity';
import { Appointment } from '../entities/appointment.entity';
import { Notification } from '../entities/notification.entity';
import { EmergencyAlert } from '../entities/emergency-alert.entity';

@Injectable()
export class DashboardService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    @InjectRepository(DoctorProfile)
    private readonly doctorRepo: Repository<DoctorProfile>,
    @InjectRepository(HealthRecord)
    private readonly healthRecordRepo: Repository<HealthRecord>,
    @InjectRepository(Appointment)
    private readonly appointmentRepo: Repository<Appointment>,
    @InjectRepository(Notification)
    private readonly notificationRepo: Repository<Notification>,
    @InjectRepository(EmergencyAlert)
    private readonly emergencyAlertRepo: Repository<EmergencyAlert>,
  ) {}

  async getOverviewStats(): Promise<Record<string, any>> {
    const [
      totalUsers,
      activeUsers,
      totalDoctors,
      verifiedDoctors,
      totalRecords,
      totalAppointments,
      pendingAppointments,
      activeAlerts,
    ] = await Promise.all([
      this.userRepo.count(),
      this.userRepo.count({ where: { isActive: true } }),
      this.doctorRepo.count(),
      this.doctorRepo.count({ where: { isVerified: true } }),
      this.healthRecordRepo.count(),
      this.appointmentRepo.count(),
      this.appointmentRepo.count({ where: { status: 'scheduled' } }),
      this.emergencyAlertRepo.count({ where: { status: 'active' } }),
    ]);

    return {
      users: { total: totalUsers, active: activeUsers },
      doctors: { total: totalDoctors, verified: verifiedDoctors },
      healthRecords: { total: totalRecords },
      appointments: { total: totalAppointments, pending: pendingAppointments },
      emergencyAlerts: { active: activeAlerts },
    };
  }

  async getUserGrowth(days = 30): Promise<{ date: string; count: number }[]> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const result = await this.userRepo
      .createQueryBuilder('user')
      .select("DATE(user.created_at) as date")
      .addSelect('COUNT(*) as count')
      .where('user.created_at >= :startDate', { startDate })
      .groupBy('DATE(user.created_at)')
      .orderBy('date', 'ASC')
      .getRawMany();

    return result.map((r) => ({ date: r.date, count: parseInt(r.count, 10) }));
  }

  async getUsersByRole(): Promise<{ role: string; count: number }[]> {
    const result = await this.userRepo
      .createQueryBuilder('user')
      .select('user.role as role')
      .addSelect('COUNT(*) as count')
      .groupBy('user.role')
      .getRawMany();

    return result.map((r) => ({ role: r.role, count: parseInt(r.count, 10) }));
  }

  async getAppointmentStats(days = 30): Promise<Record<string, any>> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const statusCounts = await this.appointmentRepo
      .createQueryBuilder('apt')
      .select('apt.status as status')
      .addSelect('COUNT(*) as count')
      .where('apt.created_at >= :startDate', { startDate })
      .groupBy('apt.status')
      .getRawMany();

    const dailyTrend = await this.appointmentRepo
      .createQueryBuilder('apt')
      .select("DATE(apt.scheduled_at) as date")
      .addSelect('COUNT(*) as count')
      .where('apt.scheduled_at >= :startDate', { startDate })
      .groupBy('DATE(apt.scheduled_at)')
      .orderBy('date', 'ASC')
      .getRawMany();

    return {
      byStatus: statusCounts.map((r) => ({ status: r.status, count: parseInt(r.count, 10) })),
      dailyTrend: dailyTrend.map((r) => ({ date: r.date, count: parseInt(r.count, 10) })),
    };
  }

  async getNotificationStats(): Promise<Record<string, any>> {
    const statusCounts = await this.notificationRepo
      .createQueryBuilder('n')
      .select('n.status as status')
      .addSelect('COUNT(*) as count')
      .groupBy('n.status')
      .getRawMany();

    const channelCounts = await this.notificationRepo
      .createQueryBuilder('n')
      .select('n.type as channel')
      .addSelect('COUNT(*) as count')
      .groupBy('n.type')
      .getRawMany();

    return {
      byStatus: statusCounts.map((r) => ({ status: r.status, count: parseInt(r.count, 10) })),
      byChannel: channelCounts.map((r) => ({ channel: r.channel, count: parseInt(r.count, 10) })),
    };
  }

  async getEmergencyStats(days = 30): Promise<Record<string, any>> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const [severityCounts, statusCounts, totalActive] = await Promise.all([
      this.emergencyAlertRepo
        .createQueryBuilder('ea')
        .select('ea.severity as severity')
        .addSelect('COUNT(*) as count')
        .where('ea.created_at >= :startDate', { startDate })
        .groupBy('ea.severity')
        .getRawMany(),
      this.emergencyAlertRepo
        .createQueryBuilder('ea')
        .select('ea.status as status')
        .addSelect('COUNT(*) as count')
        .where('ea.created_at >= :startDate', { startDate })
        .groupBy('ea.status')
        .getRawMany(),
      this.emergencyAlertRepo.count({ where: { status: 'active' } }),
    ]);

    return {
      bySeverity: severityCounts.map((r) => ({ severity: r.severity, count: parseInt(r.count, 10) })),
      byStatus: statusCounts.map((r) => ({ status: r.status, count: parseInt(r.count, 10) })),
      currentlyActive: totalActive,
    };
  }

  async getSystemHealth(): Promise<Record<string, any>> {
    const dbCheck = await this.userRepo.query('SELECT 1 as healthy');

    return {
      database: dbCheck ? 'healthy' : 'unhealthy',
      uptime: process.uptime(),
      memoryUsage: process.memoryUsage(),
      nodeVersion: process.version,
    };
  }
}
