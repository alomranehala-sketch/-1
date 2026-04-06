import { IsString, IsOptional, IsEnum } from 'class-validator';

enum EmergencyResolveStatus {
  RESOLVED = 'resolved',
  FALSE_ALARM = 'false_alarm',
}

export class UpdateAlertDto {
  @IsOptional()
  @IsEnum(EmergencyResolveStatus)
  status?: EmergencyResolveStatus;

  @IsOptional()
  @IsString()
  resolvedNotes?: string;
}
