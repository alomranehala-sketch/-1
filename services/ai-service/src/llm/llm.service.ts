import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';

export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface LlmResponse {
  content: string;
  tokensUsed: number;
  model: string;
  finishReason: string;
}

@Injectable()
export class LlmService {
  private readonly logger = new Logger(LlmService.name);
  private readonly grok: OpenAI;
  private readonly model: string;
  private readonly maxTokens: number;

  constructor(private readonly configService: ConfigService) {
    // Grok API uses OpenAI-compatible SDK with x.ai base URL
    this.grok = new OpenAI({
      apiKey: this.configService.get('GROK_API_KEY'),
      baseURL: 'https://api.x.ai/v1',
      timeout: 30000,
    });
    this.model = this.configService.get('GROK_MODEL', 'grok-3-latest');
    this.maxTokens = this.configService.get<number>('GROK_MAX_TOKENS', 4096);
  }

  /**
   * Send a chat completion request to Grok API
   */
  async chat(messages: ChatMessage[], systemPrompt?: string): Promise<LlmResponse> {
    const fullMessages: ChatMessage[] = [];

    if (systemPrompt) {
      fullMessages.push({ role: 'system', content: systemPrompt });
    }

    fullMessages.push(...messages);

    const optimizedMessages = this.optimizeMessages(fullMessages);

    try {
      const completion = await this.grok.chat.completions.create({
        model: this.model,
        messages: optimizedMessages,
        max_tokens: this.maxTokens,
        temperature: 0.4,
        top_p: 0.9,
      });

      const choice = completion.choices[0];
      return {
        content: choice.message.content || '',
        tokensUsed: completion.usage?.total_tokens || 0,
        model: completion.model,
        finishReason: choice.finish_reason || 'stop',
      };
    } catch (error: any) {
      this.logger.error(`Grok API error: ${error.message}`);
      throw error;
    }
  }

  /**
   * Structured JSON output from Grok
   */
  async chatJSON<T = any>(messages: ChatMessage[], systemPrompt: string): Promise<T> {
    const jsonSystemPrompt = systemPrompt + '\n\nIMPORTANT: Return ONLY valid JSON. No markdown, no explanation, no code fences.';

    const response = await this.chat(messages, jsonSystemPrompt);
    try {
      // Strip markdown code fences if present
      let content = response.content.trim();
      if (content.startsWith('```')) {
        content = content.replace(/^```(?:json)?\n?/, '').replace(/\n?```$/, '');
      }
      return JSON.parse(content);
    } catch {
      this.logger.error(`Failed to parse JSON from Grok: ${response.content.substring(0, 200)}`);
      throw new Error('AI returned invalid JSON response');
    }
  }

  /**
   * Summarize a conversation for context compression
   */
  async summarizeConversation(messages: ChatMessage[]): Promise<string> {
    const summaryPrompt: ChatMessage[] = [
      {
        role: 'user',
        content: messages.map((m) => `${m.role}: ${m.content}`).join('\n'),
      },
    ];

    try {
      const response = await this.chat(
        summaryPrompt,
        'Summarize the following health conversation in 2-3 sentences in Arabic, preserving key health topics, symptoms, and recommendations.',
      );
      return response.content;
    } catch (error: any) {
      this.logger.error(`Error summarizing conversation: ${error.message}`);
      return messages.slice(-2).map((m) => m.content).join(' ');
    }
  }

  /**
   * Optimize messages to fit within token limits
   */
  private optimizeMessages(messages: ChatMessage[]): ChatMessage[] {
    const MAX_MESSAGES = 30;
    if (messages.length <= MAX_MESSAGES) return messages;

    const systemMessages = messages.filter((m) => m.role === 'system');
    const conversationMessages = messages.filter((m) => m.role !== 'system');
    const recentMessages = conversationMessages.slice(-(MAX_MESSAGES - systemMessages.length));

    return [...systemMessages, ...recentMessages];
  }
}
