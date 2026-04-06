import { IsString, IsOptional, MaxLength, IsObject } from 'class-validator';

export class UpdateRecordDto {
  @IsOptional()
  @IsString()
  @MaxLength(300)
  title?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsObject()
  metadata?: Record<string, any>;

  @IsOptional()
  @IsObject()
  sensitiveData?: Record<string, any>;
}
