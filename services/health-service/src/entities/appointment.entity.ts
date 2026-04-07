import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('appointments')
export class Appointment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', name: 'patient_id' })
  patientId: string;

  @Column({ type: 'uuid', name: 'doctor_id' })
  doctorId: string;

  @Column({ type: 'timestamptz', name: 'scheduled_at' })
  scheduledAt: Date;

  @Column({ type: 'integer', default: 30, name: 'duration_minutes' })
  durationMinutes: number;

  @Column({ type: 'varchar', length: 20, default: 'scheduled' })
  status: string;

  @Column({ type: 'text', nullable: true })
  reason: string | null;

  @Column({ type: 'text', nullable: true })
  notes: string | null;

  @Column({ type: 'varchar', length: 500, nullable: true, name: 'meeting_url' })
  meetingUrl: string | null;

  @Column({ type: 'text', nullable: true, name: 'cancelled_reason' })
  cancelledReason: string | null;

  @Column({ type: 'uuid', nullable: true, name: 'cancelled_by' })
  cancelledBy: string | null;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;
}
