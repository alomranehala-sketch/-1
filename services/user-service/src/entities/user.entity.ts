import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 20, unique: true, nullable: true, name: 'national_id' })
  nationalId: string | null;

  @Column({ type: 'varchar', length: 255, unique: true, nullable: true })
  email: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'password_hash' })
  passwordHash: string | null;

  @Column({ type: 'varchar', length: 20, unique: true })
  phone: string;

  @Column({ type: 'varchar', length: 100, name: 'first_name' })
  firstName: string;

  @Column({ type: 'varchar', length: 100, name: 'last_name' })
  lastName: string;

  @Column({ type: 'varchar', length: 100, nullable: true, name: 'first_name_ar' })
  firstNameAr: string | null;

  @Column({ type: 'varchar', length: 100, nullable: true, name: 'last_name_ar' })
  lastNameAr: string | null;

  @Column({ type: 'date', nullable: true, name: 'date_of_birth' })
  dateOfBirth: Date | null;

  @Column({ type: 'varchar', length: 20, nullable: true })
  gender: string | null;

  @Column({ type: 'varchar', length: 500, nullable: true, name: 'avatar_url' })
  avatarUrl: string | null;

  @Column({ type: 'varchar', length: 20, default: 'citizen' })
  role: string;

  @Column({ type: 'varchar', length: 20, default: 'otp', name: 'auth_provider' })
  authProvider: string;

  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive: boolean;

  @Column({ type: 'boolean', default: false, name: 'is_phone_verified' })
  isPhoneVerified: boolean;

  @Column({ type: 'boolean', default: false, name: 'is_identity_verified' })
  isIdentityVerified: boolean;

  @Column({ type: 'timestamptz', nullable: true, name: 'identity_verified_at' })
  identityVerifiedAt: Date | null;

  @Column({ type: 'varchar', length: 500, nullable: true, name: 'biometric_hash' })
  biometricHash: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'otp_secret' })
  otpSecret: string | null;

  @Column({ type: 'timestamptz', nullable: true, name: 'last_login_at' })
  lastLoginAt: Date | null;

  @Column({ type: 'inet', nullable: true, name: 'last_login_ip' })
  lastLoginIp: string | null;

  @Column({ type: 'varchar', length: 10, default: 'ar', name: 'preferred_language' })
  preferredLanguage: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  governorate: string | null;

  @Column({ type: 'varchar', length: 100, nullable: true })
  city: string | null;

  @Column({ type: 'text', nullable: true })
  address: string | null;

  @Column({ type: 'varchar', length: 5, nullable: true, name: 'blood_type' })
  bloodType: string | null;

  @Column({ type: 'jsonb', default: '[]', name: 'chronic_conditions' })
  chronicConditions: any[];

  @Column({ type: 'varchar', length: 200, nullable: true, name: 'insurance_provider' })
  insuranceProvider: string | null;

  @Column({ type: 'varchar', length: 100, nullable: true, name: 'insurance_number' })
  insuranceNumber: string | null;

  @Column({ type: 'text', nullable: true, name: 'medical_wallet_qr' })
  medicalWalletQr: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'refresh_token_hash' })
  refreshTokenHash: string | null;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;
}
