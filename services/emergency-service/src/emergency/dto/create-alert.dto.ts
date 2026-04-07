import {
  IsString,
  IsOptional,
  IsEnum,
  IsNumber,
  IsObject,
  MaxLength,
} from 'class-validator';

enum EmergencySeverity {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  CRITICAL = 'critical',
}

export class CreateAlertDto {
  @IsString()
  @MaxLength(100)
  alertType: string; // e.g., 'heart_rate_anomaly', 'fall_detected', 'manual', 'low_oxygen'

  @IsString()
  @MaxLength(2000)
  message: string;

  @IsOptional()
  @IsEnum(EmergencySeverity)
  severity?: EmergencySeverity;

  @IsOptional()
  @IsNumber()
  locationLat?: number;

  @IsOptional()
  @IsNumber()
  locationLng?: number;

  @IsOptional()
  @IsObject()
  vitalsSnapshot?: Record<string, any>;
}
