import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  Logger,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { User, UserRole, AuthProvider } from '../entities/user.entity';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { OtpService } from './otp.service';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly BCRYPT_ROUNDS = 12;

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly otpService: OtpService,
  ) {}

  /**
   * Register a new user with email/password
   */
  async register(registerDto: RegisterDto) {
    const { email, password, firstName, lastName, phone, role } = registerDto;

    // Check if user already exists
    const existingUser = await this.userRepository.findOne({ where: { email } });
    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, this.BCRYPT_ROUNDS);

    // Create user
    const user = this.userRepository.create({
      email,
      passwordHash,
      firstName,
      lastName,
      phone: phone || '',
      role: role || UserRole.CITIZEN,
      authProvider: AuthProvider.OTP,
    } as Partial<User>);

    const savedUser = await this.userRepository.save(user);
    this.logger.log(`User registered: ${(savedUser as User).email}`);

    // Generate tokens
    const tokens = await this.generateTokens(savedUser);
    await this.updateRefreshToken(savedUser.id, tokens.refreshToken);

    return {
      user: this.sanitizeUser(savedUser),
      ...tokens,
    };
  }

  /**
   * Authenticate with email/password
   */
  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;

    const user = await this.userRepository.findOne({ where: { email } });
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.isActive) {
      throw new ForbiddenException('Account is deactivated');
    }

    if (user.authProvider !== AuthProvider.OTP || !user.passwordHash) {
      throw new UnauthorizedException(
        'يرجى استخدام رمز التحقق لتسجيل الدخول',
      );
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Update last login
    user.lastLoginAt = new Date();
    await this.userRepository.save(user);

    // Generate tokens
    const tokens = await this.generateTokens(user);
    await this.updateRefreshToken(user.id, tokens.refreshToken);

    this.logger.log(`User logged in: ${user.email}`);

    return {
      user: this.sanitizeUser(user),
      ...tokens,
    };
  }

  /**
   * Refresh access token using refresh token
   */
  async refreshTokens(refreshTokenDto: RefreshTokenDto) {
    const { refreshToken } = refreshTokenDto;

    let payload: any;
    try {
      payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get('JWT_REFRESH_SECRET'),
      });
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const user = await this.userRepository.findOne({
      where: { id: payload.sub },
    });

    if (!user || !user.refreshTokenHash) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    // Verify refresh token matches stored hash
    const isRefreshTokenValid = await bcrypt.compare(
      refreshToken,
      user.refreshTokenHash,
    );
    if (!isRefreshTokenValid) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const tokens = await this.generateTokens(user);
    await this.updateRefreshToken(user.id, tokens.refreshToken);

    return tokens;
  }

  /**
   * Logout - invalidate refresh token
   */
  async logout(userId: string) {
    await this.userRepository.update(userId, { refreshTokenHash: null });
    this.logger.log(`User logged out: ${userId}`);
    return { message: 'Logged out successfully' };
  }

  /**
   * Validate user by ID (used by JWT strategy)
   */
  async validateUser(userId: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: { id: userId, isActive: true },
    });
  }

  /**
   * Verify a token and return user info (used by API gateway)
   */
  async verifyToken(token: string) {
    try {
      const payload = this.jwtService.verify(token);
      const user = await this.validateUser(payload.sub);
      if (!user) {
        throw new UnauthorizedException('User not found');
      }
      return {
        userId: user.id,
        email: user.email,
        role: user.role,
      };
    } catch {
      throw new UnauthorizedException('Invalid token');
    }
  }

  // ─── Private Helpers ─────────────────────────────

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

  private async generateTokens(user: User) {
    const payload = {
      sub: user.id,
      phone: user.phone,
      nationalId: user.nationalId,
      role: user.role,
      governorate: user.governorate,
    };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: this.configService.get('JWT_SECRET'),
        expiresIn: this.configService.get('JWT_EXPIRATION', '15m'),
      }),
      this.jwtService.signAsync(payload, {
        secret: this.configService.get('JWT_REFRESH_SECRET'),
        expiresIn: this.configService.get('JWT_REFRESH_EXPIRATION', '7d'),
      }),
    ]);

    return {
      accessToken,
      refreshToken,
      expiresIn: 900,
    };
  }

  private async updateRefreshToken(userId: string, refreshToken: string) {
    const hash = await bcrypt.hash(refreshToken, this.BCRYPT_ROUNDS);
    await this.userRepository.update(userId, { refreshTokenHash: hash });
  }

  private sanitizeUser(user: User) {
    return {
      id: user.id,
      nationalId: user.nationalId,
      email: user.email,
      phone: user.phone,
      firstName: user.firstName,
      lastName: user.lastName,
      firstNameAr: user.firstNameAr,
      lastNameAr: user.lastNameAr,
      avatarUrl: user.avatarUrl,
      role: user.role,
      isActive: user.isActive,
      isPhoneVerified: user.isPhoneVerified,
      isIdentityVerified: user.isIdentityVerified,
      preferredLanguage: user.preferredLanguage,
      governorate: user.governorate,
      bloodType: user.bloodType,
      createdAt: user.createdAt,
    };
  }

  // ─── OTP Authentication (Primary for Jordan) ─────────

  /**
   * Step 1: Request OTP — sends a 6-digit code via SMS
   */
  async requestOtp(phone: string) {
    const normalizedPhone = this.normalizePhone(phone);
    const result = await this.otpService.generateOtp(normalizedPhone);

    this.logger.log(`OTP requested for ${normalizedPhone.slice(0, 6)}****`);

    return {
      message: 'تم إرسال رمز التحقق',
      messageEn: 'OTP sent successfully',
      expiresIn: result.expiresIn,
      // Remove in production:
      ...(this.configService.get('NODE_ENV') === 'development' ? { otp: result.otp } : {}),
    };
  }

  /**
   * Step 2: Verify OTP — validates code and creates/logs in user
   */
  async verifyOtp(phone: string, otp: string) {
    const normalizedPhone = this.normalizePhone(phone);

    const isValid = await this.otpService.verifyOtp(normalizedPhone, otp);
    if (!isValid) {
      throw new UnauthorizedException('رمز التحقق غير صحيح');
    }

    let user = await this.userRepository.findOne({ where: { phone: normalizedPhone } });
    let isNewUser = false;

    if (!user) {
      user = this.userRepository.create({
        phone: normalizedPhone,
        firstName: 'مستخدم',
        lastName: 'جديد',
        role: UserRole.CITIZEN,
        authProvider: AuthProvider.OTP,
        isPhoneVerified: true,
        preferredLanguage: 'ar',
      });
      user = await this.userRepository.save(user);
      isNewUser = true;
      this.logger.log(`New citizen registered via OTP: ${normalizedPhone.slice(0, 6)}****`);
    }

    if (!user.isActive) {
      throw new ForbiddenException('الحساب معطل');
    }

    if (!user.isPhoneVerified) {
      user.isPhoneVerified = true;
    }
    user.lastLoginAt = new Date();
    await this.userRepository.save(user);

    const tokens = await this.generateTokens(user);
    await this.updateRefreshToken(user.id, tokens.refreshToken);

    return {
      user: this.sanitizeUser(user),
      isNewUser,
      ...tokens,
    };
  }

  /**
   * Verify national ID against government system
   */
  async verifyNationalId(userId: string, nationalId: string, firstName: string, lastName: string) {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new UnauthorizedException('المستخدم غير موجود');
    }

    const existing = await this.userRepository.findOne({ where: { nationalId } });
    if (existing && existing.id !== userId) {
      throw new ConflictException('الرقم الوطني مسجل مسبقاً');
    }

    // TODO: In production, call Jordanian Civil Status API
    const verified = true;

    if (!verified) {
      throw new BadRequestException('فشل التحقق من الهوية الوطنية');
    }

    user.nationalId = nationalId;
    user.firstName = firstName;
    user.lastName = lastName;
    user.isIdentityVerified = true;
    user.identityVerifiedAt = new Date();
    await this.userRepository.save(user);

    this.logger.log(`National ID verified for user ${userId}`);

    return {
      message: 'تم التحقق من الهوية بنجاح',
      user: this.sanitizeUser(user),
    };
  }
}
