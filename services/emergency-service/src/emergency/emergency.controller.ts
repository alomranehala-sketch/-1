import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  Headers,
  HttpCode,
  HttpStatus,
  ParseUUIDPipe,
} from '@nestjs/common';
import { EmergencyService } from './emergency.service';
import { CreateAlertDto } from './dto/create-alert.dto';
import { UpdateAlertDto } from './dto/update-alert.dto';

@Controller('emergency/alerts')
export class EmergencyController {
  constructor(private readonly emergencyService: EmergencyService) {}

  /**
   * POST /api/v1/emergency/alerts
   * Create a new emergency alert
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createAlert(
    @Headers('x-user-id') userId: string,
    @Body() dto: CreateAlertDto,
  ) {
    const alert = await this.emergencyService.createAlert(userId, dto);
    return {
      success: true,
      data: alert,
      statusCode: HttpStatus.CREATED,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/emergency/alerts/active
   * Get active alerts for the current user
   */
  @Get('active')
  async getActiveAlerts(@Headers('x-user-id') userId: string) {
    const alerts = await this.emergencyService.getActiveAlerts(userId);
    return {
      success: true,
      data: alerts,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/emergency/alerts/monitoring
   * Get all active alerts (doctor/admin monitoring dashboard)
   */
  @Get('monitoring')
  async getMonitoringAlerts(
    @Query('page') page = 1,
    @Query('limit') limit = 50,
  ) {
    const result = await this.emergencyService.getAllActiveAlerts(page, limit);
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/emergency/alerts/history
   * Get alert history for current user
   */
  @Get('history')
  async getAlertHistory(
    @Headers('x-user-id') userId: string,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
  ) {
    const result = await this.emergencyService.getAlertHistory(userId, page, limit);
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * PATCH /api/v1/emergency/alerts/:id/acknowledge
   * Acknowledge an alert (doctor/admin)
   */
  @Patch(':id/acknowledge')
  async acknowledgeAlert(
    @Headers('x-user-id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    const alert = await this.emergencyService.acknowledgeAlert(id, userId);
    return {
      success: true,
      data: alert,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * PATCH /api/v1/emergency/alerts/:id/resolve
   * Resolve an alert
   */
  @Patch(':id/resolve')
  async resolveAlert(
    @Headers('x-user-id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateAlertDto,
  ) {
    const alert = await this.emergencyService.resolveAlert(id, dto, userId);
    return {
      success: true,
      data: alert,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }
}
