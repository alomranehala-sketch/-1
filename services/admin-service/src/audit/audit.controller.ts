import { Controller, Get, Query, HttpStatus } from '@nestjs/common';
import { AuditService } from './audit.service';

@Controller('admin/audit')
export class AuditController {
  constructor(private readonly auditService: AuditService) {}

  @Get('logs')
  async getLogs(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('action') action?: string,
    @Query('resource') resource?: string,
    @Query('userId') userId?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const result = await this.auditService.getLogs(
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 50,
      action,
      resource,
      userId,
      startDate,
      endDate,
    );
    return {
      success: true,
      data: result.data,
      meta: { total: result.total, page: result.page, limit: result.limit },
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  @Get('summary')
  async getActionSummary(@Query('days') days?: string) {
    const data = await this.auditService.getActionSummary(
      days ? parseInt(days, 10) : 30,
    );
    return {
      success: true,
      data,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }
}
