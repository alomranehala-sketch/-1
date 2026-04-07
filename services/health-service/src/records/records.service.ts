import {
  Injectable,
  Logger,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import { HealthRecord } from '../entities/health-record.entity';
import { CreateRecordDto } from './dto/create-record.dto';
import { UpdateRecordDto } from './dto/update-record.dto';

@Injectable()
export class RecordsService {
  private readonly logger = new Logger(RecordsService.name);
  private readonly encryptionKey: Buffer;
  private readonly encryptionIv: Buffer;

  constructor(
    @InjectRepository(HealthRecord)
    private readonly recordRepo: Repository<HealthRecord>,
    private readonly configService: ConfigService,
  ) {
    // Initialize encryption keys for HIPAA-compliant data encryption
    const key = this.configService.get('ENCRYPTION_KEY', 'default-32-char-key-change-this!');
    const iv = this.configService.get('ENCRYPTION_IV', 'default-16-char!');
    this.encryptionKey = Buffer.from(key.padEnd(32, '0').slice(0, 32));
    this.encryptionIv = Buffer.from(iv.padEnd(16, '0').slice(0, 16));
  }

  /**
   * Create a new health record with optional data encryption
   */
  async createRecord(userId: string, dto: CreateRecordDto, userRole: string) {
    const record = this.recordRepo.create({
      userId,
      recordType: dto.recordType,
      title: dto.title,
      description: dto.description || null,
      fileUrl: dto.fileUrl || null,
      recordedBy: userRole === 'doctor' ? userId : null,
      metadata: dto.metadata || {},
    });

    // Encrypt sensitive health data if provided
    if (dto.sensitiveData) {
      record.dataEncrypted = this.encryptData(JSON.stringify(dto.sensitiveData));
    }

    const saved = await this.recordRepo.save(record);
    this.logger.log(`Health record created: ${saved.id} for user ${userId}`);
    return this.formatRecord(saved);
  }

  /**
   * Get records for a user with pagination
   */
  async getUserRecords(userId: string, page = 1, limit = 20, recordType?: string) {
    const queryBuilder = this.recordRepo
      .createQueryBuilder('record')
      .where('record.user_id = :userId', { userId });

    if (recordType) {
      queryBuilder.andWhere('record.record_type = :recordType', { recordType });
    }

    queryBuilder
      .orderBy('record.recorded_at', 'DESC')
      .skip((page - 1) * limit)
      .take(limit);

    const [items, total] = await queryBuilder.getManyAndCount();

    return {
      items: items.map((r) => this.formatRecord(r)),
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  /**
   * Get a single record by ID
   */
  async getRecord(recordId: string, userId: string, userRole: string) {
    const record = await this.recordRepo.findOne({ where: { id: recordId } });
    if (!record) {
      throw new NotFoundException('Health record not found');
    }

    // Only the owner or a doctor can view the record
    if (record.userId !== userId && userRole !== 'doctor' && userRole !== 'admin') {
      throw new ForbiddenException('Access denied');
    }

    const formatted = this.formatRecord(record);

    // Decrypt sensitive data if present
    if (record.dataEncrypted) {
      formatted.sensitiveData = JSON.parse(this.decryptData(record.dataEncrypted));
    }

    return formatted;
  }

  /**
   * Update a health record
   */
  async updateRecord(recordId: string, userId: string, dto: UpdateRecordDto) {
    const record = await this.recordRepo.findOne({ where: { id: recordId } });
    if (!record) {
      throw new NotFoundException('Health record not found');
    }

    if (record.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    if (dto.title) record.title = dto.title;
    if (dto.description !== undefined) record.description = dto.description;
    if (dto.metadata) record.metadata = { ...record.metadata, ...dto.metadata };

    if (dto.sensitiveData) {
      record.dataEncrypted = this.encryptData(JSON.stringify(dto.sensitiveData));
    }

    const updated = await this.recordRepo.save(record);
    return this.formatRecord(updated);
  }

  /**
   * Delete a health record
   */
  async deleteRecord(recordId: string, userId: string) {
    const record = await this.recordRepo.findOne({ where: { id: recordId } });
    if (!record) {
      throw new NotFoundException('Health record not found');
    }

    if (record.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    await this.recordRepo.remove(record);
    return { message: 'Record deleted successfully' };
  }

  // ─── Encryption helpers (AES-256-CBC) ─────────────

  private encryptData(data: string): Buffer {
    const cipher = crypto.createCipheriv('aes-256-cbc', this.encryptionKey, this.encryptionIv);
    const encrypted = Buffer.concat([cipher.update(data, 'utf8'), cipher.final()]);
    return encrypted;
  }

  private decryptData(data: Buffer): string {
    const decipher = crypto.createDecipheriv('aes-256-cbc', this.encryptionKey, this.encryptionIv);
    const decrypted = Buffer.concat([decipher.update(data), decipher.final()]);
    return decrypted.toString('utf8');
  }

  private formatRecord(record: HealthRecord) {
    return {
      id: record.id,
      userId: record.userId,
      recordType: record.recordType,
      title: record.title,
      description: record.description,
      fileUrl: record.fileUrl,
      recordedBy: record.recordedBy,
      recordedAt: record.recordedAt,
      metadata: record.metadata,
      hasSensitiveData: !!record.dataEncrypted,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    } as any;
  }
}
