import {
  Injectable,
  Logger,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { EmergencyAlert } from '../entities/emergency-alert.entity';
import { EmergencyGateway } from './emergency.gateway';
import { CreateAlertDto } from './dto/create-alert.dto';
import { UpdateAlertDto } from './dto/update-alert.dto';

@Injectable()
export class EmergencyService {
  private readonly logger = new Logger(EmergencyService.name);

  constructor(
    @InjectRepository(EmergencyAlert)
    private readonly alertRepo: Repository<EmergencyAlert>,
    private readonly emergencyGateway: EmergencyGateway,
  ) {}

  /**
   * Create a new emergency alert and broadcast via WebSocket
   */
  async createAlert(userId: string, dto: CreateAlertDto) {
    const alert = this.alertRepo.create({
      userId,
      severity: dto.severity || 'medium',
      alertType: dto.alertType,
      message: dto.message,
      locationLat: dto.locationLat || null,
      locationLng: dto.locationLng || null,
      vitalsSnapshot: dto.vitalsSnapshot || null,
      status: 'active',
    });

    const saved = await this.alertRepo.save(alert);
    this.logger.warn(
      `Emergency alert created: ${saved.id} | User: ${userId} | Severity: ${saved.severity}`,
    );

    // Broadcast to all connected clients via WebSocket
    this.emergencyGateway.broadcastNewAlert(saved);

    return saved;
  }

  /**
   * Get active alerts for a user
   */
  async getActiveAlerts(userId: string) {
    return this.alertRepo.find({
      where: { userId, status: 'active' },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Get all alerts (for monitoring dashboard)
   */
  async getAllActiveAlerts(page = 1, limit = 50) {
    const [items, total] = await this.alertRepo.findAndCount({
      where: { status: 'active' },
      order: { severity: 'DESC', createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });

    return {
      items,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  /**
   * Get alert history for a user
   */
  async getAlertHistory(userId: string, page = 1, limit = 20) {
    const [items, total] = await this.alertRepo.findAndCount({
      where: { userId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });

    return {
      items,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  /**
   * Acknowledge an alert (doctor/admin action)
   */
  async acknowledgeAlert(alertId: string, acknowledgedByUserId: string) {
    const alert = await this.alertRepo.findOne({ where: { id: alertId } });
    if (!alert) {
      throw new NotFoundException('Alert not found');
    }

    if (alert.status !== 'active') {
      throw new ForbiddenException('Alert is not active');
    }

    alert.status = 'acknowledged';
    alert.acknowledgedBy = acknowledgedByUserId;
    alert.acknowledgedAt = new Date();

    const updated = await this.alertRepo.save(alert);
    this.emergencyGateway.broadcastAlertAcknowledged(updated);

    this.logger.log(`Alert ${alertId} acknowledged by ${acknowledgedByUserId}`);
    return updated;
  }

  /**
   * Resolve an alert
   */
  async resolveAlert(alertId: string, dto: UpdateAlertDto, resolvedByUserId: string) {
    const alert = await this.alertRepo.findOne({ where: { id: alertId } });
    if (!alert) {
      throw new NotFoundException('Alert not found');
    }

    alert.status = dto.status || 'resolved';
    alert.resolvedAt = new Date();
    alert.resolvedNotes = dto.resolvedNotes || null;

    const updated = await this.alertRepo.save(alert);
    this.emergencyGateway.broadcastAlertResolved(updated);

    this.logger.log(`Alert ${alertId} resolved by ${resolvedByUserId}`);
    return updated;
  }
}
