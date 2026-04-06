import {
  IsString,
  IsOptional,
  IsBoolean,
  IsEmail,
  MaxLength,
} from 'class-validator';

export class CreateContactDto {
  @IsString()
  @MaxLength(200)
  name: string;

  @IsString()
  @MaxLength(100)
  relationship: string;

  @IsString()
  @MaxLength(20)
  phone: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsBoolean()
  isPrimary?: boolean;
}
