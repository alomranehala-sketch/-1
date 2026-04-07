import { Module, Global } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { EventEmitter2 } from 'eventemitter2';
import { EventBusService } from './event-bus.service';
import { PatientJourneyService } from './patient-journey.service';
import { ContextAwareService } from './context-aware.service';
import { HospitalPerformanceService } from './hospital-performance.service';
import { LangChainAgentService } from './langchain-agent.service';

@Global()
@Module({
  imports: [ConfigModule],
  providers: [
    {
      provide: EventEmitter2,
      useFactory: () => new EventEmitter2({ wildcard: true, maxListeners: 50 }),
    },
    EventBusService,
    PatientJourneyService,
    ContextAwareService,
    HospitalPerformanceService,
    LangChainAgentService,
  ],
  exports: [
    EventBusService,
    PatientJourneyService,
    ContextAwareService,
    HospitalPerformanceService,
    LangChainAgentService,
  ],
})
export class OrientedSystemModule {}
