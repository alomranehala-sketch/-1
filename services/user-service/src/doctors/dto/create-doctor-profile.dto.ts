import { IsString, IsOptional, MaxLength, IsNumber, Min, Max, IsArray } from 'class-validator';

export class CreateDoctorProfileDto {
  @IsString()
  @MaxLength(100)
  specialization: string;

  @IsString()
  @MaxLength(50)
  licenseNumber: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  hospitalAffiliation?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(60)
  yearsOfExperience?: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  languages?: string[];

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  bio?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  consultationFee?: number;
}
