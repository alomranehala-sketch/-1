import {
  Controller,
  Get,
  Post,
  Delete,
  Patch,
  Body,
  Param,
  Query,
  Headers,
  HttpCode,
  HttpStatus,
  ParseUUIDPipe,
  Logger,
} from '@nestjs/common';
import { ConversationService } from './conversation.service';
import { SendMessageDto } from './dto/send-message.dto';
import { CreateConversationDto } from './dto/create-conversation.dto';

@Controller('ai')
export class ConversationController {
  private readonly logger = new Logger(ConversationController.name);

  constructor(private readonly conversationService: ConversationService) {}

  /**
   * POST /api/v1/ai/conversations
   * Create a new AI conversation
   */
  @Post('conversations')
  @HttpCode(HttpStatus.CREATED)
  async createConversation(
    @Headers('x-user-id') userId: string,
    @Body() dto: CreateConversationDto,
  ) {
    const conversation = await this.conversationService.createConversation(userId, dto);
    return {
      success: true,
      data: conversation,
      statusCode: HttpStatus.CREATED,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/ai/conversations
   * List user's conversations
   */
  @Get('conversations')
  async getConversations(
    @Headers('x-user-id') userId: string,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
  ) {
    const result = await this.conversationService.getUserConversations(userId, page, limit);
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * GET /api/v1/ai/conversations/:id
   * Get a conversation with all messages
   */
  @Get('conversations/:id')
  async getConversation(
    @Headers('x-user-id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    const conversation = await this.conversationService.getConversation(userId, id);
    return {
      success: true,
      data: conversation,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * POST /api/v1/ai/conversations/:id/messages
   * Send a message to AI and get response
   */
  @Post('conversations/:id/messages')
  @HttpCode(HttpStatus.OK)
  async sendMessage(
    @Headers('x-user-id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: SendMessageDto,
  ) {
    const result = await this.conversationService.sendMessage(userId, id, dto);
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * PATCH /api/v1/ai/conversations/:id/archive
   * Archive a conversation
   */
  @Patch('conversations/:id/archive')
  async archiveConversation(
    @Headers('x-user-id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    const conversation = await this.conversationService.archiveConversation(userId, id);
    return {
      success: true,
      data: conversation,
      message: 'Conversation archived',
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * DELETE /api/v1/ai/conversations/:id
   * Delete a conversation
   */
  @Delete('conversations/:id')
  async deleteConversation(
    @Headers('x-user-id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    const result = await this.conversationService.deleteConversation(userId, id);
    return {
      success: true,
      data: result,
      statusCode: HttpStatus.OK,
      timestamp: new Date().toISOString(),
    };
  }
}
