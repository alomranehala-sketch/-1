import {
  IsString,
  IsOptional,
  IsUUID,
  IsDateString,
  IsNumber,
  Min,
  Max,
} from 'class-validator';

export class CreateAppointmentDto {
  @IsOptional()
  @IsUUID()
  patientId?: string; // Required if doctor creates the appointment

  @IsOptional()
  @IsUUID()
  doctorId?: string; // Required if patient creates the appointment

  @IsDateString()
  scheduledAt: string;

  @IsOptional()
  @IsNumber()
  @Min(15)
  @Max(120)
  durationMinutes?: number;

  @IsOptional()
  @IsString()
  reason?: string;
}
