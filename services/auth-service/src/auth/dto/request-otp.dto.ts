import { IsString, IsNotEmpty, Length, Matches } from 'class-validator';

export class RequestOtpDto {
  @IsString()
  @IsNotEmpty()
  @Matches(/^(\+9627|07)\d{8}$/, {
    message: 'Phone must be a valid Jordanian number (e.g., +962791234567 or 0791234567)',
  })
  phone: string;
}
