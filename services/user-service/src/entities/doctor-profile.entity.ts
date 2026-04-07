import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

@Entity('doctor_profiles')
export class DoctorProfile {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', unique: true, name: 'user_id' })
  userId: string;

  @OneToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ type: 'varchar', length: 200 })
  specialization: string;

  @Column({ type: 'varchar', length: 100, unique: true, name: 'license_number' })
  licenseNumber: string;

  @Column({ type: 'varchar', length: 300, nullable: true, name: 'hospital_affiliation' })
  hospitalAffiliation: string | null;

  @Column({ type: 'integer', default: 0, name: 'years_of_experience' })
  yearsOfExperience: number;

  @Column({ type: 'text', nullable: true })
  bio: string | null;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true, name: 'consultation_fee' })
  consultationFee: number | null;

  @Column({ type: 'boolean', default: true, name: 'is_available' })
  isAvailable: boolean;

  @Column({ type: 'boolean', default: false, name: 'is_verified' })
  isVerified: boolean;

  @Column({ type: 'decimal', precision: 3, scale: 2, default: 0, name: 'rating' })
  rating: number;

  @Column({ type: 'integer', default: 0, name: 'total_reviews' })
  totalReviews: number;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;
}
