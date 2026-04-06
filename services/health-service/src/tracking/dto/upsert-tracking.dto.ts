import {
  IsOptional,
  IsString,
  IsNumber,
  IsEnum,
  Min,
  Max,
  IsDateString,
} from 'class-validator';

enum TrackingMood {
  EXCELLENT = 'excellent',
  GOOD = 'good',
  NEUTRAL = 'neutral',
  BAD = 'bad',
  TERRIBLE = 'terrible',
}

export class UpsertTrackingDto {
  @IsOptional()
  @IsDateString()
  trackingDate?: string; // defaults to today

  @IsOptional()
  @IsNumber()
  @Min(30)
  @Max(250)
  heartRate?: number;

  @IsOptional()
  @IsNumber()
  @Min(60)
  @Max(250)
  bloodPressureSystolic?: number;

  @IsOptional()
  @IsNumber()
  @Min(30)
  @Max(150)
  bloodPressureDiastolic?: number;

  @IsOptional()
  @IsNumber()
  @Min(20)
  @Max(600)
  bloodSugar?: number;

  @IsOptional()
  @IsNumber()
  @Min(20)
  @Max(300)
  weight?: number;

  @IsOptional()
  @IsNumber()
  @Min(35)
  @Max(42)
  temperature?: number;

  @IsOptional()
  @IsNumber()
  @Min(70)
  @Max(100)
  oxygenSaturation?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  stepsCount?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(24)
  sleepHours?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  waterIntakeMl?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  caloriesConsumed?: number;

  @IsOptional()
  @IsEnum(TrackingMood)
  mood?: TrackingMood;

  @IsOptional()
  @IsString()
  notes?: string;
}
