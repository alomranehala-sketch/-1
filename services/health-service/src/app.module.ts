import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RecordsModule } from './records/records.module';
import { TrackingModule } from './tracking/tracking.module';
import { AppointmentsModule } from './appointments/appointments.module';
import { HealthRecord } from './entities/health-record.entity';
import { DailyTracking } from './entities/daily-tracking.entity';
import { Appointment } from './entities/appointment.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '../../.env',
    }),

    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DB_HOST', 'localhost'),
        port: configService.get<number>('DB_PORT', 5432),
        username: configService.get('DB_USERNAME', 'healthcare_user'),
        password: configService.get('DB_PASSWORD', 'healthcare_password'),
        database: configService.get('DB_NAME', 'healthcare_db'),
        entities: [HealthRecord, DailyTracking, Appointment],
        synchronize: false,
        logging: configService.get('NODE_ENV') === 'development',
      }),
    }),

    RecordsModule,
    TrackingModule,
    AppointmentsModule,
  ],
})
export class AppModule {}
