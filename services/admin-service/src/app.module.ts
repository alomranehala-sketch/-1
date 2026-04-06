import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DashboardModule } from './dashboard/dashboard.module';
import { UserManagementModule } from './user-management/user-management.module';
import { AuditModule } from './audit/audit.module';
import { AuditLog } from './entities/audit-log.entity';
import { User } from './entities/user.entity';
import { DoctorProfile } from './entities/doctor-profile.entity';
import { HealthRecord } from './entities/health-record.entity';
import { Appointment } from './entities/appointment.entity';
import { Notification } from './entities/notification.entity';
import { EmergencyAlert } from './entities/emergency-alert.entity';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get<string>('DB_HOST', 'localhost'),
        port: config.get<number>('DB_PORT', 5432),
        username: config.get<string>('DB_USERNAME', 'postgres'),
        password: config.get<string>('DB_PASSWORD', 'postgres'),
        database: config.get<string>('DB_NAME', 'healthcare_platform'),
        entities: [AuditLog, User, DoctorProfile, HealthRecord, Appointment, Notification, EmergencyAlert],
        synchronize: false,
        logging: config.get<string>('NODE_ENV') === 'development',
      }),
    }),
    DashboardModule,
    UserManagementModule,
    AuditModule,
  ],
})
export class AppModule {}
