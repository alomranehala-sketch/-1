import { Controller, Get, Query, HttpStatus } from '@nestjs/common';
import { DashboardService } from './dashboard.service';

@Controller('admin/dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get('overview')
  async getOverview() {
    const data = await this.dashboardService.getOverviewStats();
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Get('user-growth')
  async getUserGrowth(@Query('days') days?: string) {
    const data = await this.dashboardService.getUserGrowth(
      days ? parseInt(days, 10) : 30,
    );
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Get('users-by-role')
  async getUsersByRole() {
    const data = await this.dashboardService.getUsersByRole();
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Get('appointments')
  async getAppointmentStats(@Query('days') days?: string) {
    const data = await this.dashboardService.getAppointmentStats(
      days ? parseInt(days, 10) : 30,
    );
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Get('notifications')
  async getNotificationStats() {
    const data = await this.dashboardService.getNotificationStats();
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Get('emergencies')
  async getEmergencyStats(@Query('days') days?: string) {
    const data = await this.dashboardService.getEmergencyStats(
      days ? parseInt(days, 10) : 30,
    );
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Get('system-health')
  async getSystemHealth() {
    const data = await this.dashboardService.getSystemHealth();
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }
}
