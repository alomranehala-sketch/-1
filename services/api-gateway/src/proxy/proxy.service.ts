import { Injectable, Logger, HttpException, HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosRequestConfig, Method } from 'axios';

// Service routing map
interface ServiceRoute {
  url: string;
  requiresAuth: boolean;
}

@Injectable()
export class ProxyService {
  private readonly logger = new Logger(ProxyService.name);
  private readonly serviceMap: Record<string, ServiceRoute>;

  constructor(private readonly configService: ConfigService) {
    const authUrl = configService.get('AUTH_SERVICE_URL', 'http://auth-service:3001');
    const userUrl = configService.get('USER_SERVICE_URL', 'http://user-service:3003');
    const healthUrl = configService.get('HEALTH_SERVICE_URL', 'http://health-service:3004');
    const aiUrl = configService.get('AI_SERVICE_URL', 'http://ai-service:3005');
    const notifUrl = configService.get('NOTIFICATION_SERVICE_URL', 'http://notification-service:3006');
    const emergencyUrl = configService.get('EMERGENCY_SERVICE_URL', 'http://emergency-service:3002');
    const adminUrl = configService.get('ADMIN_SERVICE_URL', 'http://admin-service:3007');

    this.serviceMap = {
      auth: { url: authUrl, requiresAuth: false },
      users: { url: userUrl, requiresAuth: true },
      health: { url: healthUrl, requiresAuth: true },
      ai: { url: aiUrl, requiresAuth: true },
      notifications: { url: notifUrl, requiresAuth: true },
      emergency: { url: emergencyUrl, requiresAuth: true },
      admin: { url: adminUrl, requiresAuth: true },
    };
  }

  /**
   * Resolve which downstream service handles a given path
   */
  resolveService(path: string): { service: ServiceRoute; serviceName: string } | null {
    // Strip /api/v1/ prefix
    const cleanPath = path.replace(/^\/api\/v1\//, '');
    const serviceName = cleanPath.split('/')[0];
    const service = this.serviceMap[serviceName];
    if (!service) return null;
    return { service, serviceName };
  }

  /**
   * Verify token with auth service
   */
  async verifyToken(token: string): Promise<{ userId: string; email: string; role: string }> {
    try {
      const response = await axios.post(
        `${this.serviceMap.auth.url}/api/v1/auth/verify`,
        {},
        {
          headers: { Authorization: `Bearer ${token}` },
          timeout: 5000,
        },
      );
      return response.data.data;
    } catch (error: any) {
      throw new HttpException(
        'Unauthorized - Invalid or expired token',
        HttpStatus.UNAUTHORIZED,
      );
    }
  }

  /**
   * Forward request to downstream service
   */
  async forwardRequest(
    method: string,
    path: string,
    body: any,
    headers: Record<string, string>,
    query: Record<string, string>,
  ): Promise<any> {
    const resolved = this.resolveService(path);
    if (!resolved) {
      throw new HttpException('Service not found', HttpStatus.NOT_FOUND);
    }

    const { service } = resolved;

    // Check auth requirement
    if (service.requiresAuth) {
      const authHeader = headers['authorization'];
      if (!authHeader) {
        throw new HttpException('Authorization required', HttpStatus.UNAUTHORIZED);
      }
      const token = authHeader.replace('Bearer ', '');
      const userData = await this.verifyToken(token);

      // Inject user info into headers for downstream services
      headers['x-user-id'] = userData.userId;
      headers['x-user-email'] = userData.email;
      headers['x-user-role'] = userData.role;
    }

    // Build target URL
    const targetUrl = `${service.url}${path}`;
    this.logger.debug(`Proxying ${method} ${path} -> ${targetUrl}`);

    const config: AxiosRequestConfig = {
      method: method as Method,
      url: targetUrl,
      data: body,
      params: query,
      headers: {
        'content-type': headers['content-type'] || 'application/json',
        authorization: headers['authorization'] || '',
        'x-user-id': headers['x-user-id'] || '',
        'x-user-email': headers['x-user-email'] || '',
        'x-user-role': headers['x-user-role'] || '',
        'x-request-id': headers['x-request-id'] || crypto.randomUUID(),
      },
      timeout: 30000,
      validateStatus: () => true, // Don't throw on non-2xx
    };

    try {
      const response = await axios(config);
      return { status: response.status, data: response.data };
    } catch (error: any) {
      this.logger.error(`Proxy error: ${error.message}`);
      throw new HttpException(
        'Service temporarily unavailable',
        HttpStatus.SERVICE_UNAVAILABLE,
      );
    }
  }
}
