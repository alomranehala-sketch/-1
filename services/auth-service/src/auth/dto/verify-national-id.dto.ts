import { IsString, IsNotEmpty, IsOptional, Length, Matches } from 'class-validator';

export class VerifyNationalIdDto {
  @IsString()
  @IsNotEmpty()
  @Length(10, 10, { message: 'National ID must be exactly 10 digits' })
  @Matches(/^\d{10}$/, { message: 'National ID must contain only digits' })
  nationalId: string;

  @IsString()
  @IsNotEmpty()
  firstName: string;

  @IsString()
  @IsNotEmpty()
  lastName: string;

  @IsOptional()
  @IsString()
  firstNameAr?: string;

  @IsOptional()
  @IsString()
  lastNameAr?: string;

  @IsOptional()
  @IsString()
  dateOfBirth?: string;
}
