import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { DailyTracking } from '../entities/daily-tracking.entity';
import { UpsertTrackingDto } from './dto/upsert-tracking.dto';

@Injectable()
export class TrackingService {
  private readonly logger = new Logger(TrackingService.name);

  constructor(
    @InjectRepository(DailyTracking)
    private readonly trackingRepo: Repository<DailyTracking>,
  ) {}

  /**
   * Create or update daily tracking data (upsert by user+date)
   */
  async upsertTracking(userId: string, dto: UpsertTrackingDto) {
    const trackingDate = dto.trackingDate || new Date().toISOString().split('T')[0];

    let tracking = await this.trackingRepo.findOne({
      where: { userId, trackingDate },
    });

    if (tracking) {
      // Update existing entry
      Object.assign(tracking, this.buildTrackingData(dto));
    } else {
      // Create new entry
      tracking = this.trackingRepo.create({
        userId,
        trackingDate,
        ...this.buildTrackingData(dto),
      });
    }

    const saved = await this.trackingRepo.save(tracking);
    this.logger.log(`Daily tracking saved for user ${userId} on ${trackingDate}`);
    return saved;
  }

  /**
   * Get tracking data for a specific date
   */
  async getByDate(userId: string, date: string) {
    const tracking = await this.trackingRepo.findOne({
      where: { userId, trackingDate: date },
    });
    if (!tracking) {
      throw new NotFoundException(`No tracking data for ${date}`);
    }
    return tracking;
  }

  /**
   * Get tracking data for a date range
   */
  async getRange(userId: string, startDate: string, endDate: string) {
    return this.trackingRepo.find({
      where: {
        userId,
        trackingDate: Between(startDate, endDate),
      },
      order: { trackingDate: 'ASC' },
    });
  }

  /**
   * Get latest tracking entry for a user
   */
  async getLatest(userId: string) {
    return this.trackingRepo.findOne({
      where: { userId },
      order: { trackingDate: 'DESC' },
    });
  }

  /**
   * Get summary/trends for dashboard
   */
  async getTrends(userId: string, days = 30) {
    const endDate = new Date().toISOString().split('T')[0];
    const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000)
      .toISOString()
      .split('T')[0];

    const data = await this.getRange(userId, startDate, endDate);

    // Calculate averages
    const metrics = {
      avgHeartRate: this.avg(data, 'heartRate'),
      avgBloodSugar: this.avg(data, 'bloodSugar'),
      avgSleepHours: this.avg(data, 'sleepHours'),
      avgSteps: this.avg(data, 'stepsCount'),
      avgWaterIntake: this.avg(data, 'waterIntakeMl'),
      totalEntries: data.length,
      dateRange: { startDate, endDate },
    };

    return metrics;
  }

  private buildTrackingData(dto: UpsertTrackingDto) {
    return {
      heartRate: dto.heartRate,
      bloodPressureSystolic: dto.bloodPressureSystolic,
      bloodPressureDiastolic: dto.bloodPressureDiastolic,
      bloodSugar: dto.bloodSugar,
      weight: dto.weight,
      temperature: dto.temperature,
      oxygenSaturation: dto.oxygenSaturation,
      stepsCount: dto.stepsCount,
      sleepHours: dto.sleepHours,
      waterIntakeMl: dto.waterIntakeMl,
      caloriesConsumed: dto.caloriesConsumed,
      mood: dto.mood,
      notes: dto.notes,
    };
  }

  private avg(data: DailyTracking[], field: keyof DailyTracking): number | null {
    const values = data
      .map((d) => d[field] as number | null)
      .filter((v): v is number => v !== null && v !== undefined);
    if (values.length === 0) return null;
    return Math.round((values.reduce((a, b) => a + b, 0) / values.length) * 100) / 100;
  }
}
