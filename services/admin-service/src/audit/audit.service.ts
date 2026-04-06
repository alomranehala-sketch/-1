import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AuditLog } from '../entities/audit-log.entity';

@Injectable()
export class AuditService {
  constructor(
    @InjectRepository(AuditLog)
    private readonly auditLogRepo: Repository<AuditLog>,
  ) {}

  async getLogs(
    page = 1,
    limit = 50,
    action?: string,
    resource?: string,
    userId?: string,
    startDate?: string,
    endDate?: string,
  ): Promise<{ data: AuditLog[]; total: number; page: number; limit: number }> {
    const qb = this.auditLogRepo.createQueryBuilder('log');

    if (action) {
      qb.andWhere('log.action = :action', { action });
    }

    if (resource) {
      qb.andWhere('log.resourceType = :resource', { resource });
    }

    if (userId) {
      qb.andWhere('log.user_id = :userId', { userId });
    }

    if (startDate) {
      qb.andWhere('log.created_at >= :startDate', { startDate });
    }

    if (endDate) {
      qb.andWhere('log.created_at <= :endDate', { endDate });
    }

    const [data, total] = await qb
      .skip((page - 1) * limit)
      .take(limit)
      .orderBy('log.created_at', 'DESC')
      .getManyAndCount();

    return { data, total, page, limit };
  }

  async createLog(
    userId: string,
    action: string,
    resourceType: string,
    resourceId?: string,
    details?: Record<string, any>,
    ipAddress?: string,
    userAgent?: string,
  ): Promise<AuditLog> {
    const log = this.auditLogRepo.create({
      userId,
      action,
      resourceType,
      resourceId,
      details,
      ipAddress,
      userAgent,
    });

    return this.auditLogRepo.save(log);
  }

  async getActionSummary(days = 30): Promise<{ action: string; count: number }[]> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const result = await this.auditLogRepo
      .createQueryBuilder('log')
      .select('log.action as action')
      .addSelect('COUNT(*) as count')
      .where('log.created_at >= :startDate', { startDate })
      .groupBy('log.action')
      .orderBy('count', 'DESC')
      .getRawMany();

    return result.map((r) => ({ action: r.action, count: parseInt(r.count, 10) }));
  }
}
