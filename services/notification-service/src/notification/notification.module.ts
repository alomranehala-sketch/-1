import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BullModule } from '@nestjs/bullmq';
import { ConfigModule } from '@nestjs/config';
import { Notification } from '../entities/notification.entity';
import { NotificationController } from './notification.controller';
import { NotificationService } from './notification.service';
import { EmailService } from './channels/email.service';
import { NotificationProcessor } from './notification.processor';

@Module({
  imports: [
    TypeOrmModule.forFeature([Notification]),
    BullModule.registerQueue({ name: 'notifications' }),
    ConfigModule,
  ],
  controllers: [NotificationController],
  providers: [NotificationService, EmailService, NotificationProcessor],
  exports: [NotificationService],
})
export class NotificationModule {}
