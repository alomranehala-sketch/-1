import {
  Injectable,
  Logger,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { Conversation } from '../entities/conversation.entity';
import { Message } from '../entities/message.entity';
import { LlmService, ChatMessage } from '../llm/llm.service';
import { SendMessageDto } from './dto/send-message.dto';
import { CreateConversationDto } from './dto/create-conversation.dto';

// Maximum messages before triggering context summarization
const CONTEXT_COMPRESSION_THRESHOLD = 30;

@Injectable()
export class ConversationService {
  private readonly logger = new Logger(ConversationService.name);

  constructor(
    @InjectRepository(Conversation)
    private readonly conversationRepo: Repository<Conversation>,
    @InjectRepository(Message)
    private readonly messageRepo: Repository<Message>,
    private readonly llmService: LlmService,
    @InjectQueue('ai-processing')
    private readonly aiQueue: Queue,
  ) {}

  /**
   * Create a new conversation
   */
  async createConversation(userId: string, dto: CreateConversationDto) {
    const conversation = this.conversationRepo.create({
      userId,
      title: dto.title || 'New Conversation',
      model: dto.model || 'grok-3-latest',
      status: 'active',
    });

    const saved = await this.conversationRepo.save(conversation);
    this.logger.log(`Conversation created: ${saved.id} for user ${userId}`);
    return saved;
  }

  /**
   * Get all conversations for a user
   */
  async getUserConversations(userId: string, page = 1, limit = 20) {
    const [items, total] = await this.conversationRepo.findAndCount({
      where: { userId },
      order: { updatedAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });

    return {
      items,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  /**
   * Get a single conversation with messages
   */
  async getConversation(userId: string, conversationId: string) {
    const conversation = await this.conversationRepo.findOne({
      where: { id: conversationId },
      relations: ['messages'],
    });

    if (!conversation) {
      throw new NotFoundException('Conversation not found');
    }

    if (conversation.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    // Sort messages by creation time
    conversation.messages = conversation.messages || [];
    conversation.messages.sort(
      (a, b) => a.createdAt.getTime() - b.createdAt.getTime(),
    );

    return conversation;
  }

  /**
   * Send a message and get AI response
   */
  async sendMessage(userId: string, conversationId: string, dto: SendMessageDto) {
    // Verify conversation ownership
    const conversation = await this.getConversation(userId, conversationId);

    if (conversation.status !== 'active') {
      throw new ForbiddenException('Conversation is archived');
    }

    // Save user message
    const userMessage = this.messageRepo.create({
      conversationId,
      role: 'user',
      content: dto.message,
      tokensUsed: 0,
    });
    await this.messageRepo.save(userMessage);

    // Build chat history for LLM
    const chatHistory: ChatMessage[] = conversation.messages.map((m) => ({
      role: m.role as 'user' | 'assistant' | 'system',
      content: m.content,
    }));
    chatHistory.push({ role: 'user', content: dto.message });

    // Get AI response
    const HEALTHCARE_PROMPT = `أنت مساعد صحي ذكي في نظام نبض الأردني. أجب بالعربي بشكل مختصر ومهني. لا تشخّص — وجّه للطبيب. في الطوارئ اطلب الاتصال بـ 911.`;
    const llmResponse = await this.llmService.chat(
      chatHistory,
      HEALTHCARE_PROMPT + (conversation.contextSummary ? `\nسياق سابق: ${conversation.contextSummary}` : ''),
    );

    // Save assistant message
    const assistantMessage = this.messageRepo.create({
      conversationId,
      role: 'assistant',
      content: llmResponse.content,
      tokensUsed: llmResponse.tokensUsed,
      metadata: {
        model: llmResponse.model,
        finishReason: llmResponse.finishReason,
      },
    });
    await this.messageRepo.save(assistantMessage);

    // Update conversation token count
    conversation.totalTokensUsed += llmResponse.tokensUsed;

    // Auto-set title from first message if not set
    if (conversation.title === 'New Conversation') {
      conversation.title = dto.message.substring(0, 100);
    }

    await this.conversationRepo.save(conversation);

    // Check if we need to compress context (async via queue)
    const messageCount = conversation.messages.length + 2; // +2 for new messages
    if (messageCount > CONTEXT_COMPRESSION_THRESHOLD) {
      try {
        await this.aiQueue.add('compress-context', {
          conversationId,
          userId,
        });
      } catch (error: any) {
        this.logger.warn(`Failed to queue context compression: ${error.message}`);
      }
    }

    return {
      userMessage,
      assistantMessage,
      tokensUsed: llmResponse.tokensUsed,
    };
  }

  /**
   * Compress conversation context (called by queue processor)
   */
  async compressContext(conversationId: string) {
    const conversation = await this.conversationRepo.findOne({
      where: { id: conversationId },
      relations: ['messages'],
    });

    if (!conversation) return;

    const messages: ChatMessage[] = conversation.messages
      .sort((a, b) => a.createdAt.getTime() - b.createdAt.getTime())
      .map((m) => ({
        role: m.role as 'user' | 'assistant',
        content: m.content,
      }));

    // Summarize older messages, keeping recent ones intact
    const olderMessages = messages.slice(0, -10);
    if (olderMessages.length > 0) {
      const summary = await this.llmService.summarizeConversation(olderMessages);
      conversation.contextSummary = summary;
      await this.conversationRepo.save(conversation);
      this.logger.log(`Context compressed for conversation ${conversationId}`);
    }
  }

  /**
   * Archive a conversation
   */
  async archiveConversation(userId: string, conversationId: string) {
    const conversation = await this.getConversation(userId, conversationId);
    conversation.status = 'archived';
    return this.conversationRepo.save(conversation);
  }

  /**
   * Delete a conversation
   */
  async deleteConversation(userId: string, conversationId: string) {
    const conversation = await this.getConversation(userId, conversationId);
    await this.conversationRepo.remove(conversation);
    return { message: 'Conversation deleted' };
  }
}
