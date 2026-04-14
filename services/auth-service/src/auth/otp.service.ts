import { Injectable, Logger, BadRequestException, HttpException, HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';
import * as crypto from 'crypto';

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);
  private readonly redis: Redis;
  private readonly OTP_TTL = 300; // 5 minutes
  private readonly MAX_ATTEMPTS = 5;
  private readonly RATE_LIMIT_TTL = 60; // 1 request per minute
  private readonly OTP_LENGTH = 6;

  constructor(private readonly configService: ConfigService) {
    this.redis = new Redis({
      host: configService.get('REDIS_HOST', 'redis'),
      port: configService.get('REDIS_PORT', 6379),
    });
  }

  /**
   * Generate and store an OTP for a phone number
   */
  async generateOtp(phone: string): Promise<{ otp: string; expiresIn: number }> {
    const normalizedPhone = this.normalizePhone(phone);

    // Rate limiting: 1 OTP per minute per phone
    const rateLimitKey = `otp:ratelimit:${normalizedPhone}`;
    const isRateLimited = await this.redis.exists(rateLimitKey);
    if (isRateLimited) {
      throw new HttpException(
        'يرجى الانتظار دقيقة واحدة قبل طلب رمز جديد', // Please wait 1 minute
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    // Generate cryptographically secure 6-digit OTP
    const otp = this.generateSecureOtp();

    // Store OTP hash (not plaintext) in Redis
    const otpHash = this.hashOtp(otp);
    const otpKey = `otp:${normalizedPhone}`;
    const attemptsKey = `otp:attempts:${normalizedPhone}`;

    await this.redis.setex(otpKey, this.OTP_TTL, otpHash);
    await this.redis.setex(rateLimitKey, this.RATE_LIMIT_TTL, '1');
    await this.redis.del(attemptsKey); // Reset attempts on new OTP

    this.logger.log(`OTP generated for ${normalizedPhone.slice(0, 6)}****`);

    // In production, send via SMS gateway (Twilio, Nexmo, local Jordanian provider)
    // For development, we return the OTP
    return { otp, expiresIn: this.OTP_TTL };
  }

  /**
   * Verify an OTP
   */
  async verifyOtp(phone: string, otp: string): Promise<boolean> {
    const normalizedPhone = this.normalizePhone(phone);
    const otpKey = `otp:${normalizedPhone}`;
    const attemptsKey = `otp:attempts:${normalizedPhone}`;

    // Check attempt count
    const attempts = parseInt(await this.redis.get(attemptsKey) || '0', 10);
    if (attempts >= this.MAX_ATTEMPTS) {
      await this.redis.del(otpKey); // Invalidate OTP after max attempts
      throw new BadRequestException(
        'تم تجاوز الحد الأقصى للمحاولات. يرجى طلب رمز جديد', // Max attempts exceeded
      );
    }

    // Get stored OTP hash
    const storedHash = await this.redis.get(otpKey);
    if (!storedHash) {
      throw new BadRequestException(
        'رمز التحقق منتهي الصلاحية أو غير موجود', // OTP expired or not found
      );
    }

    // Increment attempts
    await this.redis.incr(attemptsKey);
    await this.redis.expire(attemptsKey, this.OTP_TTL);

    // Compare hashes (constant-time)
    const inputHash = this.hashOtp(otp);
    const isValid = crypto.timingSafeEqual(
      Buffer.from(storedHash, 'hex'),
      Buffer.from(inputHash, 'hex'),
    );

    if (isValid) {
      await this.redis.del(otpKey);
      await this.redis.del(attemptsKey);
      this.logger.log(`OTP verified for ${normalizedPhone.slice(0, 6)}****`);
    }

    return isValid;
  }

  /**
   * Normalize Jordanian phone numbers to +962 format
   */
  private normalizePhone(phone: string): string {
    let normalized = phone.replace(/[\s-]/g, '');
    if (normalized.startsWith('07')) {
      normalized = '+962' + normalized.slice(1);
    }
    if (normalized.startsWith('962')) {
      normalized = '+' + normalized;
    }
    return normalized;
  }

  /**
   * Generate a cryptographically secure N-digit OTP
   */
  private generateSecureOtp(): string {
    const buffer = crypto.randomBytes(4);
    const num = buffer.readUInt32BE(0) % Math.pow(10, this.OTP_LENGTH);
    return num.toString().padStart(this.OTP_LENGTH, '0');
  }

  /**
   * Hash OTP using SHA-256
   */
  private hashOtp(otp: string): string {
    return crypto.createHash('sha256').update(otp).digest('hex');
  }
}
