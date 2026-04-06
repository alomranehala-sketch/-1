import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Unique,
} from 'typeorm';

@Entity('daily_tracking')
@Unique(['userId', 'trackingDate'])
export class DailyTracking {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId: string;

  @Column({ type: 'date', name: 'tracking_date' })
  trackingDate: string;

  @Column({ type: 'integer', nullable: true, name: 'heart_rate' })
  heartRate: number | null;

  @Column({ type: 'integer', nullable: true, name: 'blood_pressure_systolic' })
  bloodPressureSystolic: number | null;

  @Column({ type: 'integer', nullable: true, name: 'blood_pressure_diastolic' })
  bloodPressureDiastolic: number | null;

  @Column({ type: 'decimal', precision: 6, scale: 2, nullable: true, name: 'blood_sugar' })
  bloodSugar: number | null;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  weight: number | null;

  @Column({ type: 'decimal', precision: 4, scale: 1, nullable: true })
  temperature: number | null;

  @Column({ type: 'decimal', precision: 4, scale: 1, nullable: true, name: 'oxygen_saturation' })
  oxygenSaturation: number | null;

  @Column({ type: 'integer', default: 0, name: 'steps_count' })
  stepsCount: number;

  @Column({ type: 'decimal', precision: 4, scale: 2, nullable: true, name: 'sleep_hours' })
  sleepHours: number | null;

  @Column({ type: 'integer', default: 0, name: 'water_intake_ml' })
  waterIntakeMl: number;

  @Column({ type: 'integer', nullable: true, name: 'calories_consumed' })
  caloriesConsumed: number | null;

  @Column({ type: 'varchar', length: 20, nullable: true })
  mood: string | null;

  @Column({ type: 'text', nullable: true })
  notes: string | null;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;
}
