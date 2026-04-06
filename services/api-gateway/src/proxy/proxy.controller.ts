import {
  Controller,
  All,
  Req,
  Res,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { ProxyService } from './proxy.service';

@Controller()
export class ProxyController {
  private readonly logger = new Logger(ProxyController.name);

  constructor(private readonly proxyService: ProxyService) {}

  /**
   * Catch-all route that proxies requests to downstream services.
   * Routes are determined by the first path segment after /api/v1/
   *
   * Examples:
   *   GET  /api/v1/auth/login      -> Auth Service
   *   POST /api/v1/health/records  -> Health Data Service
   *   POST /api/v1/ai/chat         -> AI Service
   */
  @All('*')
  async proxyRequest(@Req() req: Request, @Res() res: Response) {
    try {
      const result = await this.proxyService.forwardRequest(
        req.method,
        req.originalUrl,
        req.body,
        req.headers as Record<string, string>,
        req.query as Record<string, string>,
      );

      res.status(result.status).json(result.data);
    } catch (error: any) {
      const status = error.status || 500;
      res.status(status).json({
        success: false,
        statusCode: status,
        message: error.message || 'Internal gateway error',
        timestamp: new Date().toISOString(),
      });
    }
  }
}
