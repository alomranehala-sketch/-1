import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike } from 'typeorm';
import { User } from '../entities/user.entity';
import { DoctorProfile } from '../entities/doctor-profile.entity';
import { AuditLog } from '../entities/audit-log.entity';
import { UpdateUserStatusDto } from './dto/update-user-status.dto';

@Injectable()
export class UserManagementService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    @InjectRepository(DoctorProfile)
    private readonly doctorRepo: Repository<DoctorProfile>,
    @InjectRepository(AuditLog)
    private readonly auditLogRepo: Repository<AuditLog>,
  ) {}

  async listUsers(
    page = 1,
    limit = 20,
    role?: string,
    search?: string,
    isActive?: boolean,
  ): Promise<{ data: User[]; total: number; page: number; limit: number }> {
    const qb = this.userRepo.createQueryBuilder('user');

    if (role) {
      qb.andWhere('user.role = :role', { role });
    }

    if (search) {
      qb.andWhere(
        '(user.email ILIKE :search OR user.firstName ILIKE :search OR user.lastName ILIKE :search)',
        { search: `%${search}%` },
      );
    }

    if (isActive !== undefined) {
      qb.andWhere('user.is_active = :isActive', { isActive });
    }

    const [data, total] = await qb
      .skip((page - 1) * limit)
      .take(limit)
      .orderBy('user.created_at', 'DESC')
      .getManyAndCount();

    return { data, total, page, limit };
  }

  async getUserDetail(userId: string): Promise<Record<string, any>> {
    const user = await this.userRepo.findOne({ where: { id: userId } });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const doctorProfile = await this.doctorRepo.findOne({ where: { userId } });

    const recentAuditLogs = await this.auditLogRepo.find({
      where: { userId },
      order: { createdAt: 'DESC' },
      take: 20,
    });

    return {
      user,
      doctorProfile,
      recentActivity: recentAuditLogs,
    };
  }

  async updateUserStatus(
    userId: string,
    dto: UpdateUserStatusDto,
    adminId: string,
  ): Promise<User> {
    const user = await this.userRepo.findOne({ where: { id: userId } });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (dto.isActive !== undefined) {
      user.isActive = dto.isActive;
    }

    if (dto.role) {
      user.role = dto.role;
    }

    const updatedUser = await this.userRepo.save(user);

    await this.auditLogRepo.save({
      userId: adminId,
      action: 'UPDATE_USER_STATUS',
      resourceType: 'users',
      resourceId: userId,
      details: {
        changes: dto,
        previousValues: {
          isActive: !dto.isActive,
          role: user.role,
        },
      },
    });

    return updatedUser;
  }

  async deleteUser(userId: string, adminId: string): Promise<void> {
    const user = await this.userRepo.findOne({ where: { id: userId } });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    user.isActive = false;
    await this.userRepo.save(user);

    await this.auditLogRepo.save({
      userId: adminId,
      action: 'DEACTIVATE_USER',
      resourceType: 'users',
      resourceId: userId,
      details: { email: user.email, softDeleted: true },
    });
  }

  async verifyDoctor(profileId: string, adminId: string): Promise<DoctorProfile> {
    const profile = await this.doctorRepo.findOne({ where: { id: profileId } });

    if (!profile) {
      throw new NotFoundException('Doctor profile not found');
    }

    profile.isVerified = true;
    const updatedProfile = await this.doctorRepo.save(profile);

    await this.auditLogRepo.save({
      userId: adminId,
      action: 'VERIFY_DOCTOR',
      resourceType: 'doctor_profiles',
      resourceId: profileId,
      details: { doctorUserId: profile.userId },
    });

    return updatedProfile;
  }

  async listUnverifiedDoctors(
    page = 1,
    limit = 20,
  ): Promise<{ data: DoctorProfile[]; total: number; page: number; limit: number }> {
    const [data, total] = await this.doctorRepo.findAndCount({
      where: { isVerified: false },
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    });

    return { data, total, page, limit };
  }
}
