import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({
    type: 'enum',
    enum: ['email', 'sms', 'push'],
  })
  type: string;

  @Column({ length: 300 })
  title: string;

  @Column({ type: 'text' })
  body: string;

  @Column({ type: 'jsonb', default: {} })
  data: Record<string, any>;

  @Column({
    type: 'enum',
    enum: ['pending', 'sent', 'failed', 'read'],
    default: 'pending',
  })
  status: string;

  @Column({ type: 'timestamptz', nullable: true, name: 'sent_at' })
  sentAt: Date;

  @Column({ type: 'timestamptz', nullable: true, name: 'read_at' })
  readAt: Date;

  @Column({ name: 'retry_count', default: 0 })
  retryCount: number;

  @Column({ name: 'max_retries', default: 3 })
  maxRetries: number;

  @Column({ type: 'text', nullable: true, name: 'error_message' })
  errorMessage: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
