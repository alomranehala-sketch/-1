import {
  Injectable,
  Logger,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThanOrEqual } from 'typeorm';
import { Appointment } from '../entities/appointment.entity';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { UpdateAppointmentDto } from './dto/update-appointment.dto';

@Injectable()
export class AppointmentsService {
  private readonly logger = new Logger(AppointmentsService.name);

  constructor(
    @InjectRepository(Appointment)
    private readonly appointmentRepo: Repository<Appointment>,
  ) {}

  /**
   * Create a new appointment
   */
  async create(userId: string, dto: CreateAppointmentDto, userRole: string) {
    // Validate scheduled time is in the future
    const scheduledAt = new Date(dto.scheduledAt);
    if (scheduledAt <= new Date()) {
      throw new BadRequestException('Appointment must be scheduled in the future');
    }

    const appointment = this.appointmentRepo.create({
      patientId: userRole === 'doctor' ? dto.patientId! : userId,
      doctorId: userRole === 'doctor' ? userId : dto.doctorId,
      scheduledAt,
      durationMinutes: dto.durationMinutes || 30,
      reason: dto.reason || null,
      status: 'scheduled',
    });

    const saved = await this.appointmentRepo.save(appointment);
    this.logger.log(`Appointment created: ${saved.id}`);
    return saved;
  }

  /**
   * Get appointments for a user (patient or doctor view)
   */
  async getUserAppointments(
    userId: string,
    userRole: string,
    page = 1,
    limit = 20,
    status?: string,
  ) {
    const queryBuilder = this.appointmentRepo.createQueryBuilder('apt');

    if (userRole === 'doctor') {
      queryBuilder.where('apt.doctor_id = :userId', { userId });
    } else {
      queryBuilder.where('apt.patient_id = :userId', { userId });
    }

    if (status) {
      queryBuilder.andWhere('apt.status = :status', { status });
    }

    queryBuilder
      .orderBy('apt.scheduled_at', 'ASC')
      .skip((page - 1) * limit)
      .take(limit);

    const [items, total] = await queryBuilder.getManyAndCount();

    return {
      items,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  /**
   * Get upcoming appointments
   */
  async getUpcoming(userId: string, userRole: string) {
    const where: any = {
      scheduledAt: MoreThanOrEqual(new Date()),
      status: 'scheduled',
    };

    if (userRole === 'doctor') {
      where.doctorId = userId;
    } else {
      where.patientId = userId;
    }

    return this.appointmentRepo.find({
      where,
      order: { scheduledAt: 'ASC' },
      take: 10,
    });
  }

  /**
   * Update appointment status
   */
  async update(appointmentId: string, userId: string, dto: UpdateAppointmentDto) {
    const appointment = await this.appointmentRepo.findOne({
      where: { id: appointmentId },
    });

    if (!appointment) {
      throw new NotFoundException('Appointment not found');
    }

    // Verify access
    if (appointment.patientId !== userId && appointment.doctorId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    if (dto.status) appointment.status = dto.status;
    if (dto.notes) appointment.notes = dto.notes;
    if (dto.meetingUrl) appointment.meetingUrl = dto.meetingUrl;

    if (dto.status === 'cancelled') {
      appointment.cancelledBy = userId;
      appointment.cancelledReason = dto.cancelledReason || null;
    }

    const updated = await this.appointmentRepo.save(appointment);
    return updated;
  }
}
