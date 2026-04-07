import { Module } from '@nestjs/common';
import { HealthcareGateway } from './healthcare.gateway';
import { OrchestratorModule } from '../orchestrator/orchestrator.module';

@Module({
  imports: [OrchestratorModule],
  providers: [HealthcareGateway],
  exports: [HealthcareGateway],
})
export class GatewayModule {}
