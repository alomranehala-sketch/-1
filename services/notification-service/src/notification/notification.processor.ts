import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { NotificationService } from './notification.service';
import { EmailService } from './channels/email.service';

@Processor('notifications')
export class NotificationProcessor extends WorkerHost {
  private readonly logger = new Logger(NotificationProcessor.name);

  constructor(
    private readonly notificationService: NotificationService,
    private readonly emailService: EmailService,
  ) {
    super();
  }

  async process(job: Job): Promise<void> {
    const { notificationId, type, title, body, data } = job.data;
    this.logger.log(`Processing notification ${notificationId} (${type})`);

    try {
      switch (type) {
        case 'email':
          await this.processEmail(notificationId, data.recipientEmail, title, body);
          break;
        case 'sms':
          await this.processSms(notificationId, data.recipientPhone, body);
          break;
        case 'push':
          await this.processPush(notificationId, data.deviceToken, title, body);
          break;
        default:
          this.logger.warn(`Unknown notification type: ${type}`);
      }

      await this.notificationService.updateStatus(notificationId, 'sent');
    } catch (error: any) {
      this.logger.error(`Failed to process notification ${notificationId}: ${error.message}`);
      await this.notificationService.incrementRetry(notificationId);
      await this.notificationService.updateStatus(notificationId, 'failed', error.message);
      throw error; // BullMQ will retry based on queue config
    }
  }

  private async processEmail(
    notificationId: string,
    recipientEmail: string,
    subject: string,
    body: string,
  ) {
    if (!recipientEmail) {
      this.logger.warn(`No email for notification ${notificationId}, skipping`);
      return;
    }
    const htmlBody = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #2563eb;">Healthcare Platform</h2>
        <div style="padding: 20px; background: #f8fafc; border-radius: 8px;">
          ${body}
        </div>
        <p style="color: #94a3b8; font-size: 12px; margin-top: 20px;">
          This is an automated notification from Healthcare Platform.
        </p>
      </div>
    `;
    await this.emailService.sendEmail(recipientEmail, subject, htmlBody);
  }

  private async processSms(
    notificationId: string,
    recipientPhone: string,
    body: string,
  ) {
    // SMS integration placeholder - would use Twilio or similar
    this.logger.log(`SMS sent to ${recipientPhone}: ${body.substring(0, 50)}...`);
  }

  private async processPush(
    notificationId: string,
    deviceToken: string,
    title: string,
    body: string,
  ) {
    // Push notification placeholder - would use FCM or APNs
    this.logger.log(`Push sent to device ${deviceToken}: ${title}`);
  }
}
