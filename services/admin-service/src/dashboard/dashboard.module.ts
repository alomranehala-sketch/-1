import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DashboardService } from './dashboard.service';
import { DashboardController } from './dashboard.controller';
import { User } from '../entities/user.entity';
import { DoctorProfile } from '../entities/doctor-profile.entity';
import { HealthRecord } from '../entities/health-record.entity';
import { Appointment } from '../entities/appointment.entity';
import { Notification } from '../entities/notification.entity';
import { EmergencyAlert } from '../entities/emergency-alert.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      User,
      DoctorProfile,
      HealthRecord,
      Appointment,
      Notification,
      EmergencyAlert,
    ]),
  ],
  controllers: [DashboardController],
  providers: [DashboardService],
})
export class DashboardModule {}
