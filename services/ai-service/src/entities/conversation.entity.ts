import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { Message } from './message.entity';

@Entity('ai_conversations')
export class Conversation {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @Column({ type: 'varchar', length: 300, nullable: true })
  title!: string | null;

  @Column({ type: 'varchar', length: 20, default: 'active' })
  status!: string;

  @Column({ type: 'varchar', length: 50, default: 'gpt-4' })
  model!: string;

  @Column({ type: 'integer', default: 0, name: 'total_tokens_used' })
  totalTokensUsed!: number;

  @Column({ type: 'text', nullable: true, name: 'context_summary' })
  contextSummary!: string | null;

  @OneToMany(() => Message, (message) => message.conversation, { cascade: true })
  messages!: Message[];

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt!: Date;
}
