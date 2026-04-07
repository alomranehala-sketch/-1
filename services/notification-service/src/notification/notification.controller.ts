import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  Headers,
  HttpCode,
  HttpStatus,
  ParseUUIDPipe,
} from '@nestjs/common';
import { NotificationService } from './notification.service';
import { SendNotificationDto } from './dto/send-notification.dto';

@Controller('notifications')
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  /**
   * POST /api/v1/notifications
   * Send a notification (typically called by other services)
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async send(@Body() dto: SendNotificationDto) {
    const notification = await this.notificationService.send(dto);
    return {
      success: true,
      data: notification,
      statusCode: HttpStatus.CREATED,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/notifications
   * Get user's notifications
   */
  @Get()
  async findAll(
    @Headers('x-user-id') userId: string,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
  ) {
    const result = await this.notificationService.getUserNotifications(userId, page, limit);
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * PATCH /api/v1/notifications/:id/read
   * Mark notification as read
   */
  @Patch(':id/read')
  async markAsRead(
    @Headers('x-user-id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    const notification = await this.notificationService.markAsRead(userId, id);
    return {
      success: true,
      data: notification,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * PATCH /api/v1/notifications/read-all
   * Mark all notifications as read
   */
  @Patch('read-all')
  async markAllAsRead(@Headers('x-user-id') userId: string) {
    const result = await this.notificationService.markAllAsRead(userId);
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }
}
