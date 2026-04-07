import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BullModule } from '@nestjs/bullmq';
import { ConversationController } from './conversation.controller';
import { ConversationService } from './conversation.service';
import { Conversation } from '../entities/conversation.entity';
import { Message } from '../entities/message.entity';
import { LlmModule } from '../llm/llm.module';
import { AiProcessor } from './ai.processor';

@Module({
  imports: [
    TypeOrmModule.forFeature([Conversation, Message]),
    BullModule.registerQueue({ name: 'ai-processing' }),
    LlmModule,
  ],
  controllers: [ConversationController],
  providers: [ConversationService, AiProcessor],
})
export class ConversationModule {}
