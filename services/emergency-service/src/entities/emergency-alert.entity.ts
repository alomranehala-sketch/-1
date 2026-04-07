import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('emergency_alerts')
export class EmergencyAlert {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId: string;

  @Column({ type: 'varchar', length: 20, default: 'medium' })
  severity: string;

  @Column({ type: 'varchar', length: 20, default: 'active' })
  status: string;

  @Column({ type: 'varchar', length: 100, name: 'alert_type' })
  alertType: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ type: 'decimal', precision: 10, scale: 8, nullable: true, name: 'location_lat' })
  locationLat: number | null;

  @Column({ type: 'decimal', precision: 11, scale: 8, nullable: true, name: 'location_lng' })
  locationLng: number | null;

  @Column({ type: 'jsonb', nullable: true, name: 'vitals_snapshot' })
  vitalsSnapshot: Record<string, any> | null;

  @Column({ type: 'uuid', nullable: true, name: 'acknowledged_by' })
  acknowledgedBy: string | null;

  @Column({ type: 'timestamptz', nullable: true, name: 'acknowledged_at' })
  acknowledgedAt: Date | null;

  @Column({ type: 'timestamptz', nullable: true, name: 'resolved_at' })
  resolvedAt: Date | null;

  @Column({ type: 'text', nullable: true, name: 'resolved_notes' })
  resolvedNotes: string | null;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;
}
