import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Req,
  HttpCode,
  HttpStatus,
  Logger,
  Headers,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { VerifyNationalIdDto } from './dto/verify-national-id.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

@Controller('auth')
export class AuthController {
  private readonly logger = new Logger(AuthController.name);

  constructor(private readonly authService: AuthService) {}

  /**
   * POST /api/v1/auth/register
   * Register a new user
   */
  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  async register(@Body() registerDto: RegisterDto) {
    const result = await this.authService.register(registerDto);
    return {
      success: true,
      data: result,
      message: 'Registration successful',
      statusCode: HttpStatus.CREATED,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * POST /api/v1/auth/login
   * Login with email and password
   */
  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: LoginDto) {
    const result = await this.authService.login(loginDto);
    return {
      success: true,
      data: result,
      message: 'Login successful',
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * POST /api/v1/auth/refresh
   * Refresh access token
   */
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  async refreshToken(@Body() refreshTokenDto: RefreshTokenDto) {
    const result = await this.authService.refreshTokens(refreshTokenDto);
    return {
      success: true,
      data: result,
      message: 'Token refreshed',
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * POST /api/v1/auth/logout
   * Logout current user
   */
  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async logout(@Req() req: any) {
    const result = await this.authService.logout(req.user.id);
    return {
      success: true,
      data: result,
      message: 'Logged out',
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * POST /api/v1/auth/verify
   * Verify a token (used internally by API gateway)
   */
  @Post('verify')
  @HttpCode(HttpStatus.OK)
  async verifyToken(@Headers('authorization') authHeader: string) {
    const token = authHeader?.replace('Bearer ', '');
    if (!token) {
      return {
        success: false,
        message: 'No token provided',
        statusCode: HttpStatus.UNAUTHORIZED,
        timestamp: new Date().toISOString(),
      };
    }
    const result = await this.authService.verifyToken(token);
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/auth/me
   * Get current user profile
   */
  @Get('me')
  @UseGuards(JwtAuthGuard)
  async getProfile(@Req() req: any) {
    return {
      success: true,
      data: req.user,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  // ─── OTP Auth (Primary for مسار الصحة الذكي) ─────────

  /**
   * POST /api/v1/auth/otp/request
   * Request OTP code via SMS
   */
  @Post('otp/request')
  @HttpCode(HttpStatus.OK)
  async requestOtp(@Body() dto: RequestOtpDto) {
    const result = await this.authService.requestOtp(dto.phone);
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * POST /api/v1/auth/otp/verify
   * Verify OTP and login/register
   */
  @Post('otp/verify')
  @HttpCode(HttpStatus.OK)
  async verifyOtp(@Body() dto: VerifyOtpDto) {
    const result = await this.authService.verifyOtp(dto.phone, dto.otp);
    return {
      success: true,
      data: result,
      message: result.isNewUser ? 'تم إنشاء حساب جديد' : 'تم تسجيل الدخول بنجاح',
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * POST /api/v1/auth/verify-identity
   * Verify national ID (for authenticated users)
   */
  @Post('verify-identity')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async verifyNationalId(@Req() req: any, @Body() dto: VerifyNationalIdDto) {
    const result = await this.authService.verifyNationalId(
      req.user.id,
      dto.nationalId,
      dto.firstName,
      dto.lastName,
    );
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }
}
