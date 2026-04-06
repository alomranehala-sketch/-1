import { IsOptional, IsBoolean, IsString, IsIn } from 'class-validator';

export class UpdateUserStatusDto {
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @IsOptional()
  @IsString()
  @IsIn(['patient', 'doctor', 'admin'])
  role?: string;
}
