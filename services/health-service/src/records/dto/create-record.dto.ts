import {
  IsString,
  IsOptional,
  MaxLength,
  IsObject,
} from 'class-validator';

export class CreateRecordDto {
  @IsString()
  @MaxLength(100)
  recordType: string; // e.g., 'lab_result', 'prescription', 'diagnosis'

  @IsString()
  @MaxLength(300)
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  fileUrl?: string;

  @IsOptional()
  @IsObject()
  metadata?: Record<string, any>;

  @IsOptional()
  @IsObject()
  sensitiveData?: Record<string, any>; // Will be encrypted at rest
}
