import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BullModule } from '@nestjs/bullmq';
import { NotificationModule } from './notification/notification.module';
import { Notification } from './entities/notification.entity';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, envFilePath: '../../.env' }),

    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (c: ConfigService) => ({
        type: 'postgres',
        host: c.get('DB_HOST', 'localhost'),
        port: c.get<number>('DB_PORT', 5432),
        username: c.get('DB_USERNAME', 'healthcare_user'),
        password: c.get('DB_PASSWORD', 'healthcare_password'),
        database: c.get('DB_NAME', 'healthcare_db'),
        entities: [Notification],
        synchronize: false,
      }),
    }),

    BullModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (c: ConfigService) => ({
        connection: {
          host: c.get('REDIS_HOST', 'localhost'),
          port: c.get<number>('REDIS_PORT', 6379),
          password: c.get('REDIS_PASSWORD', undefined),
        },
      }),
    }),

    NotificationModule,
  ],
})
export class AppModule {}
