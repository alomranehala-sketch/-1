import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('health_records')
export class HealthRecord {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId: string;

  @Column({ type: 'varchar', length: 100, name: 'record_type' })
  recordType: string;

  @Column({ type: 'varchar', length: 300 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({ type: 'bytea', nullable: true, name: 'data_encrypted' })
  dataEncrypted: Buffer | null;

  @Column({ type: 'varchar', length: 500, nullable: true, name: 'file_url' })
  fileUrl: string | null;

  @Column({ type: 'uuid', nullable: true, name: 'recorded_by' })
  recordedBy: string | null;

  @Column({ type: 'timestamptz', name: 'recorded_at', default: () => 'NOW()' })
  recordedAt: Date;

  @Column({ type: 'jsonb', default: {} })
  metadata: Record<string, any>;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt: Date;
}
