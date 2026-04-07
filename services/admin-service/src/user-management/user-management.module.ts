import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserManagementService } from './user-management.service';
import { UserManagementController } from './user-management.controller';
import { User } from '../entities/user.entity';
import { DoctorProfile } from '../entities/doctor-profile.entity';
import { AuditLog } from '../entities/audit-log.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User, DoctorProfile, AuditLog])],
  controllers: [UserManagementController],
  providers: [UserManagementService],
})
export class UserManagementModule {}
