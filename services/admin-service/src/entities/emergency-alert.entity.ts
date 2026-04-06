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

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({
    type: 'enum',
    enum: ['critical', 'high', 'medium', 'low'],
    default: 'medium',
  })
  severity: string;

  @Column({
    type: 'enum',
    enum: ['active', 'acknowledged', 'resolved', 'false_alarm'],
    default: 'active',
  })
  status: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
