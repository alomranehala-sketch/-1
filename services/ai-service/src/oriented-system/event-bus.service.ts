import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { EventEmitter2 } from 'eventemitter2';

// ─── Event Types ─────────────────────────────────────────────
export enum HealthcareEvent {
  // Patient Journey Events
  USER_SUBMITTED_SYMPTOMS = 'user_submitted_symptoms',
  TRIAGE_COMPLETED = 'triage_completed',
  RECOMMENDATION_GENERATED = 'recommendation_generated',
  APPOINTMENT_BOOKED = 'appointment_booked',
  APPOINTMENT_CANCELLED = 'appointment_cancelled',
  APPOINTMENT_RESCHEDULED = 'appointment_rescheduled',
  VISIT_STARTED = 'visit_started',
  VISIT_COMPLETED = 'visit_completed',
  FOLLOWUP_SCHEDULED = 'followup_scheduled',

  // Emergency Events
  EMERGENCY_TRIGGERED = 'emergency_triggered',
  EMERGENCY_RESOLVED = 'emergency_resolved',

  // Context Events
  LOCATION_UPDATED = 'location_updated',
  HEALTH_RECORD_UPDATED = 'health_record_updated',
  LAB_RESULTS_RECEIVED = 'lab_results_received',

  // AI Events
  AI_PIPELINE_STARTED = 'ai_pipeline_started',
  AI_PIPELINE_COMPLETED = 'ai_pipeline_completed',
  AI_PREDICTION_GENERATED = 'ai_prediction_generated',

  // System Events
  PERFORMANCE_SCORE_UPDATED = 'performance_score_updated',
  JOURNEY_STATE_CHANGED = 'journey_state_changed',
}

export interface HealthcareEventPayload {
  event: HealthcareEvent;
  userId: string;
  timestamp: Date;
  data: Record<string, any>;
  metadata?: {
    source?: string;
    correlationId?: string;
    priority?: 'low' | 'medium' | 'high' | 'emergency';
  };
}

@Injectable()
export class EventBusService implements OnModuleInit {
  private readonly logger = new Logger(EventBusService.name);
  private readonly eventHistory = new Map<string, HealthcareEventPayload[]>();
  private static correlationCounter = 0;

  constructor(private readonly emitter: EventEmitter2) {}

  onModuleInit() {
    this.logger.log('EventBus initialized — listening for healthcare events');
    // Global listener for logging
    this.emitter.onAny((event: string, payload: HealthcareEventPayload) => {
      this.logger.debug(`Event: ${event} | User: ${payload?.userId} | Priority: ${payload?.metadata?.priority || 'normal'}`);
      if (payload?.userId) {
        this.trackEvent(payload.userId, payload);
      }
    });
  }

  emit(event: HealthcareEvent, userId: string, data: Record<string, any>, priority?: 'low' | 'medium' | 'high' | 'emergency'): string {
    const correlationId = `evt-${Date.now()}-${++EventBusService.correlationCounter}`;
    const payload: HealthcareEventPayload = {
      event,
      userId,
      timestamp: new Date(),
      data,
      metadata: {
        source: 'oriented-system',
        correlationId,
        priority,
      },
    };
    this.emitter.emit(event, payload);
    return correlationId;
  }

  on(event: HealthcareEvent, listener: (payload: HealthcareEventPayload) => void) {
    this.emitter.on(event, listener);
  }

  once(event: HealthcareEvent, listener: (payload: HealthcareEventPayload) => void) {
    this.emitter.once(event, listener);
  }

  private trackEvent(userId: string, payload: HealthcareEventPayload) {
    if (!this.eventHistory.has(userId)) {
      this.eventHistory.set(userId, []);
    }
    const history = this.eventHistory.get(userId)!;
    history.push(payload);
    // Keep last 100 events per user
    if (history.length > 100) {
      history.shift();
    }
  }

  getUserEventHistory(userId: string): HealthcareEventPayload[] {
    return this.eventHistory.get(userId) || [];
  }

  getRecentEvents(userId: string, count = 10): HealthcareEventPayload[] {
    const history = this.eventHistory.get(userId) || [];
    return history.slice(-count);
  }
}
