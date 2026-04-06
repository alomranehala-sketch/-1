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
  private readonly openai: OpenAI;
  private readonly model: string;
  private readonly maxTokens: number;

  // System prompt for healthcare AI assistant
  private readonly SYSTEM_PROMPT = `You are a professional healthcare AI assistant. Your role is to:
1. Provide general health information and wellness tips
2. Help users understand their health data and trends
3. Suggest when they should consult a medical professional
4. Answer questions about medications, symptoms, and conditions
5. Provide mental health support and coping strategies

IMPORTANT RULES:
- Never diagnose conditions. Always recommend consulting a healthcare provider for diagnosis.
- Never prescribe medications. Only provide general information about medications.
- If a user describes emergency symptoms (chest pain, difficulty breathing, severe bleeding), 
  immediately advise calling emergency services.
- Be empathetic, clear, and professional.
- Reference evidence-based medical information only.
- Always include a disclaimer that you are an AI and not a substitute for professional medical advice.`;

  constructor(private readonly configService: ConfigService) {
    this.openai = new OpenAI({
      apiKey: this.configService.get('OPENAI_API_KEY'),
    });
    this.model = this.configService.get('OPENAI_MODEL', 'gpt-4');
    this.maxTokens = this.configService.get<number>('OPENAI_MAX_TOKENS', 2048);
  }

  /**
   * Send a chat completion request to OpenAI
   */
  async chat(messages: ChatMessage[], contextSummary?: string): Promise<LlmResponse> {
    // Build messages array with system prompt
    const fullMessages: ChatMessage[] = [
      { role: 'system', content: this.SYSTEM_PROMPT },
    ];

    // Add context summary if available (for long conversations)
    if (contextSummary) {
      fullMessages.push({
        role: 'system',
        content: `Previous conversation context: ${contextSummary}`,
      });
    }

    // Add conversation messages
    fullMessages.push(...messages);

    // Token optimization: limit context window
    const optimizedMessages = this.optimizeMessages(fullMessages);

    try {
      const completion = await this.openai.chat.completions.create({
        model: this.model,
        messages: optimizedMessages,
        max_tokens: this.maxTokens,
        temperature: 0.7,
        top_p: 0.9,
        presence_penalty: 0.1,
        frequency_penalty: 0.1,
      });

      const choice = completion.choices[0];
      return {
        content: choice.message.content || 'I apologize, I was unable to generate a response.',
        tokensUsed: completion.usage?.total_tokens || 0,
        model: completion.model,
        finishReason: choice.finish_reason || 'stop',
      };
    } catch (error: any) {
      this.logger.error(`OpenAI API error: ${error.message}`);
      throw error;
    }
  }

  /**
   * Summarize a conversation for context compression
   */
  async summarizeConversation(messages: ChatMessage[]): Promise<string> {
    const summaryPrompt: ChatMessage[] = [
      {
        role: 'system',
        content:
          'Summarize the following health conversation in 2-3 sentences, ' +
          'preserving key health topics, symptoms mentioned, and any recommendations given.',
      },
      {
        role: 'user',
        content: messages.map((m) => `${m.role}: ${m.content}`).join('\n'),
      },
    ];

    try {
      const completion = await this.openai.chat.completions.create({
        model: this.model,
        messages: summaryPrompt,
        max_tokens: 256,
        temperature: 0.3,
      });

      return completion.choices[0].message.content || '';
    } catch (error: any) {
      this.logger.error(`Error summarizing conversation: ${error.message}`);
      return messages.slice(-2).map((m) => m.content).join(' ');
    }
  }

  /**
   * Optimize messages to fit within token limits.
   * Keeps system messages and most recent conversation turns.
   */
  private optimizeMessages(messages: ChatMessage[]): ChatMessage[] {
    const MAX_MESSAGES = 20;
    if (messages.length <= MAX_MESSAGES) {
      return messages;
    }

    // Keep system messages + last N conversation messages
    const systemMessages = messages.filter((m) => m.role === 'system');
    const conversationMessages = messages.filter((m) => m.role !== 'system');
    const recentMessages = conversationMessages.slice(-(MAX_MESSAGES - systemMessages.length));

    return [...systemMessages, ...recentMessages];
  }
}
