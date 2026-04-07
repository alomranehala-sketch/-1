import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike } from 'typeorm';
import { DoctorProfile } from '../entities/doctor-profile.entity';
import { User } from '../entities/user.entity';
import { CreateDoctorProfileDto } from './dto/create-doctor-profile.dto';
import { UpdateDoctorProfileDto } from './dto/update-doctor-profile.dto';

@Injectable()
export class DoctorsService {
  constructor(
    @InjectRepository(DoctorProfile)
    private readonly doctorProfileRepo: Repository<DoctorProfile>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
  ) {}

  async createProfile(userId: string, dto: CreateDoctorProfileDto): Promise<DoctorProfile> {
    const existing = await this.doctorProfileRepo.findOne({ where: { userId } });
    if (existing) {
      throw new ConflictException('Doctor profile already exists for this user');
    }

    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const profile = this.doctorProfileRepo.create({
      ...dto,
      userId,
      isVerified: false,
    });

    return this.doctorProfileRepo.save(profile);
  }

  async getProfile(userId: string): Promise<DoctorProfile> {
    const profile = await this.doctorProfileRepo.findOne({
      where: { userId },
      relations: ['user'],
    });

    if (!profile) {
      throw new NotFoundException('Doctor profile not found');
    }

    return profile;
  }

  async getProfileById(profileId: string): Promise<DoctorProfile> {
    const profile = await this.doctorProfileRepo.findOne({
      where: { id: profileId },
      relations: ['user'],
    });

    if (!profile) {
      throw new NotFoundException('Doctor profile not found');
    }

    return profile;
  }

  async updateProfile(userId: string, dto: UpdateDoctorProfileDto): Promise<DoctorProfile> {
    const profile = await this.doctorProfileRepo.findOne({ where: { userId } });

    if (!profile) {
      throw new NotFoundException('Doctor profile not found');
    }

    Object.assign(profile, dto);
    return this.doctorProfileRepo.save(profile);
  }

  async searchDoctors(
    specialization?: string,
    name?: string,
    page = 1,
    limit = 20,
  ): Promise<{ data: DoctorProfile[]; total: number; page: number; limit: number }> {
    const qb = this.doctorProfileRepo
      .createQueryBuilder('doctor')
      .leftJoinAndSelect('doctor.user', 'user')
      .where('doctor.isVerified = :verified', { verified: true });

    if (specialization) {
      qb.andWhere('doctor.specialization ILIKE :spec', { spec: `%${specialization}%` });
    }

    if (name) {
      qb.andWhere(
        '(user.firstName ILIKE :name OR user.lastName ILIKE :name)',
        { name: `%${name}%` },
      );
    }

    const [data, total] = await qb
      .skip((page - 1) * limit)
      .take(limit)
      .orderBy('doctor.createdAt', 'DESC')
      .getManyAndCount();

    return { data, total, page, limit };
  }

  async verifyDoctor(profileId: string): Promise<DoctorProfile> {
    const profile = await this.doctorProfileRepo.findOne({ where: { id: profileId } });

    if (!profile) {
      throw new NotFoundException('Doctor profile not found');
    }

    profile.isVerified = true;
    return this.doctorProfileRepo.save(profile);
  }

  async listAll(page = 1, limit = 20): Promise<{ data: DoctorProfile[]; total: number; page: number; limit: number }> {
    const [data, total] = await this.doctorProfileRepo.findAndCount({
      relations: ['user'],
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    });

    return { data, total, page, limit };
  }
}
