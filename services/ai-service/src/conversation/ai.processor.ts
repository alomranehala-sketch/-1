import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { ConversationService } from './conversation.service';

@Processor('ai-processing')
export class AiProcessor extends WorkerHost {
  private readonly logger = new Logger(AiProcessor.name);

  constructor(private readonly conversationService: ConversationService) {
    super();
  }

  async process(job: Job): Promise<void> {
    switch (job.name) {
      case 'compress-context':
        this.logger.log(`Compressing context for conversation: ${job.data.conversationId}`);
        await this.conversationService.compressContext(job.data.conversationId);
        break;

      default:
        this.logger.warn(`Unknown job: ${job.name}`);
    }
  }
}
