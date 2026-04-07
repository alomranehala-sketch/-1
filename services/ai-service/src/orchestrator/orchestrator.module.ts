import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { LlmModule } from '../llm/llm.module';
import { OrchestratorController } from './orchestrator.controller';
import { OrchestratorService } from './orchestrator.service';
import { NlpService } from './nlp.service';
import { TriageService } from './triage.service';
import { RecommendationService } from './recommendation.service';
import { PredictionService } from './prediction.service';
import { AgentService } from './agent.service';

@Module({
  imports: [ConfigModule, LlmModule],
  controllers: [OrchestratorController],
  providers: [
    OrchestratorService,
    NlpService,
    TriageService,
    RecommendationService,
    PredictionService,
    AgentService,
  ],
  exports: [OrchestratorService],
})
export class OrchestratorModule {}
