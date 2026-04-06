import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { Notification } from '../entities/notification.entity';
import { SendNotificationDto } from './dto/send-notification.dto';

@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);

  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepo: Repository<Notification>,
    @InjectQueue('notifications')
    private readonly notificationQueue: Queue,
  ) {}

  /**
   * Queue a notification for async delivery
   */
  async send(dto: SendNotificationDto) {
    const notification = this.notificationRepo.create({
      userId: dto.userId,
      type: dto.type,
      title: dto.title,
      body: dto.body,
      data: dto.data || {},
      status: 'pending',
    });

    const saved = await this.notificationRepo.save(notification);

    // Add to BullMQ queue for async processing
    await this.notificationQueue.add('send-notification', {
      notificationId: saved.id,
      type: saved.type,
      userId: saved.userId,
      title: saved.title,
      body: saved.body,
      data: saved.data,
    });

    this.logger.log(`Notification queued: ${saved.id} (${saved.type}) for user ${saved.userId}`);
    return saved;
  }

  /**
   * Get notifications for a user
   */
  async getUserNotifications(userId: string, page = 1, limit = 20) {
    const [items, total] = await this.notificationRepo.findAndCount({
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
      unreadCount: await this.notificationRepo.count({
        where: { userId, status: 'sent' },
      }),
    };
  }

  /**
   * Mark notification as read
   */
  async markAsRead(userId: string, notificationId: string) {
    const notification = await this.notificationRepo.findOne({
      where: { id: notificationId, userId },
    });
    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    notification.status = 'read';
    notification.readAt = new Date();
    return this.notificationRepo.save(notification);
  }

  /**
   * Mark all notifications as read
   */
  async markAllAsRead(userId: string) {
    await this.notificationRepo.update(
      { userId, status: 'sent' },
      { status: 'read', readAt: new Date() },
    );
    return { message: 'All notifications marked as read' };
  }

  /**
   * Update notification status (called by processor)
   */
  async updateStatus(
    notificationId: string,
    status: 'sent' | 'failed',
    errorMessage?: string,
  ) {
    const update: any = { status };
    if (status === 'sent') {
      update.sentAt = new Date();
    }
    if (errorMessage) {
      update.errorMessage = errorMessage;
    }
    await this.notificationRepo.update(notificationId, update);
  }

  /**
   * Increment retry count
   */
  async incrementRetry(notificationId: string) {
    await this.notificationRepo.increment({ id: notificationId }, 'retryCount', 1);
  }
}
