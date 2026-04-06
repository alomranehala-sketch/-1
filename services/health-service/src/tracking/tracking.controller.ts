import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  Headers,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { TrackingService } from './tracking.service';
import { UpsertTrackingDto } from './dto/upsert-tracking.dto';

@Controller('health/tracking')
export class TrackingController {
  constructor(private readonly trackingService: TrackingService) {}

  /**
   * POST /api/v1/health/tracking
   * Create or update daily tracking
   */
  @Post()
  @HttpCode(HttpStatus.OK)
  async upsert(
    @Headers('x-user-id') userId: string,
    @Body() dto: UpsertTrackingDto,
  ) {
    const tracking = await this.trackingService.upsertTracking(userId, dto);
    return {
      success: true,
      data: tracking,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/health/tracking/today
   * Get today's tracking data
   */
  @Get('today')
  async getToday(@Headers('x-user-id') userId: string) {
    const today = new Date().toISOString().split('T')[0];
    const tracking = await this.trackingService.getByDate(userId, today);
    return {
      success: true,
      data: tracking,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/health/tracking/latest
   * Get latest tracking entry
   */
  @Get('latest')
  async getLatest(@Headers('x-user-id') userId: string) {
    const tracking = await this.trackingService.getLatest(userId);
    return {
      success: true,
      data: tracking,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/health/tracking/range?start=2024-01-01&end=2024-01-31
   */
  @Get('range')
  async getRange(
    @Headers('x-user-id') userId: string,
    @Query('start') startDate: string,
    @Query('end') endDate: string,
  ) {
    const data = await this.trackingService.getRange(userId, startDate, endDate);
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/health/tracking/trends?days=30
   * Get health trends summary
   */
  @Get('trends')
  async getTrends(
    @Headers('x-user-id') userId: string,
    @Query('days') days = 30,
  ) {
    const trends = await this.trackingService.getTrends(userId, days);
    return {
      success: true,
      data: trends,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }
}
