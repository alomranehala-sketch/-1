import { IsString, MinLength, MaxLength } from 'class-validator';

export class SendMessageDto {
  @IsString()
  @MinLength(1, { message: 'Message cannot be empty' })
  @MaxLength(10000, { message: 'Message too long. Maximum 10000 characters.' })
  message: string;
}
