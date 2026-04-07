import { IsString, IsOptional, IsEnum, IsUUID, IsObject, MaxLength } from 'class-validator';

enum NotificationType {
  EMAIL = 'email',
  SMS = 'sms',
  PUSH = 'push',
}

export class SendNotificationDto {
  @IsUUID()
  userId: string;

  @IsEnum(NotificationType)
  type: NotificationType;

  @IsString()
  @MaxLength(300)
  title: string;

  @IsString()
  body: string;

  @IsOptional()
  @IsObject()
  data?: Record<string, any>; // e.g., { recipientEmail, recipientPhone, deviceToken }
}
