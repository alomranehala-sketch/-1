import { Injectable, Logger } from '@nestjs/common';
import { EventBusService, HealthcareEvent } from './event-bus.service';

// ─── Journey States ──────────────────────────────────────────
export enum JourneyState {
  START = 'start',
  CHECK_SYMPTOMS = 'check_symptoms',
  TRIAGE = 'triage',
  RECOMMENDATION = 'recommendation',
  APPOINTMENT = 'appointment',
  VISIT = 'visit',
  FOLLOWUP = 'followup',
  COMPLETED = 'completed',
  EMERGENCY = 'emergency',
}

// ─── Journey Actions (transitions) ──────────────────────────
export enum JourneyAction {
  SUBMIT_SYMPTOMS = 'symptoms',
  COMPLETE_TRIAGE = 'triage_done',
  GET_RECOMMENDATION = 'recommend',
  BOOK_APPOINTMENT = 'book',
  START_VISIT = 'visit',
  COMPLETE_VISIT = 'visit_done',
  SCHEDULE_FOLLOWUP = 'followup',
  COMPLETE_JOURNEY = 'complete',
  TRIGGER_EMERGENCY = 'emergency',
  RESET = 'reset',
}

export interface JourneySnapshot {
  userId: string;
  state: JourneyState;
  previousStates: { state: JourneyState; timestamp: Date }[];
  startedAt: Date;
  lastUpdatedAt: Date;
  data: {
    symptoms?: string[];
    triagePriority?: string;
    recommendedHospital?: string;
    appointmentId?: string;
    visitNotes?: string;
    followupDate?: string;
  };
}

// State machine transition table
const TRANSITIONS: Record<JourneyState, Partial<Record<JourneyAction, JourneyState>>> = {
  [JourneyState.START]: {
    [JourneyAction.SUBMIT_SYMPTOMS]: JourneyState.CHECK_SYMPTOMS,
    [JourneyAction.BOOK_APPOINTMENT]: JourneyState.APPOINTMENT,
    [JourneyAction.TRIGGER_EMERGENCY]: JourneyState.EMERGENCY,
  },
  [JourneyState.CHECK_SYMPTOMS]: {
    [JourneyAction.COMPLETE_TRIAGE]: JourneyState.TRIAGE,
    [JourneyAction.TRIGGER_EMERGENCY]: JourneyState.EMERGENCY,
  },
  [JourneyState.TRIAGE]: {
    [JourneyAction.GET_RECOMMENDATION]: JourneyState.RECOMMENDATION,
    [JourneyAction.TRIGGER_EMERGENCY]: JourneyState.EMERGENCY,
  },
  [JourneyState.RECOMMENDATION]: {
    [JourneyAction.BOOK_APPOINTMENT]: JourneyState.APPOINTMENT,
    [JourneyAction.RESET]: JourneyState.START,
  },
  [JourneyState.APPOINTMENT]: {
    [JourneyAction.START_VISIT]: JourneyState.VISIT,
    [JourneyAction.RESET]: JourneyState.START,
    [JourneyAction.TRIGGER_EMERGENCY]: JourneyState.EMERGENCY,
  },
  [JourneyState.VISIT]: {
    [JourneyAction.COMPLETE_VISIT]: JourneyState.FOLLOWUP,
  },
  [JourneyState.FOLLOWUP]: {
    [JourneyAction.SCHEDULE_FOLLOWUP]: JourneyState.FOLLOWUP,
    [JourneyAction.COMPLETE_JOURNEY]: JourneyState.COMPLETED,
    [JourneyAction.SUBMIT_SYMPTOMS]: JourneyState.CHECK_SYMPTOMS,
  },
  [JourneyState.COMPLETED]: {
    [JourneyAction.SUBMIT_SYMPTOMS]: JourneyState.CHECK_SYMPTOMS,
    [JourneyAction.BOOK_APPOINTMENT]: JourneyState.APPOINTMENT,
    [JourneyAction.RESET]: JourneyState.START,
  },
  [JourneyState.EMERGENCY]: {
    [JourneyAction.COMPLETE_VISIT]: JourneyState.FOLLOWUP,
    [JourneyAction.RESET]: JourneyState.START,
  },
};

@Injectable()
export class PatientJourneyService {
  private readonly logger = new Logger(PatientJourneyService.name);
  private readonly journeys = new Map<string, JourneySnapshot>();

  constructor(private readonly eventBus: EventBusService) {
    this.registerEventListeners();
  }

  private registerEventListeners() {
    this.eventBus.on(HealthcareEvent.USER_SUBMITTED_SYMPTOMS, (payload) => {
      this.transition(payload.userId, JourneyAction.SUBMIT_SYMPTOMS, {
        symptoms: payload.data.symptoms,
      });
    });

    this.eventBus.on(HealthcareEvent.TRIAGE_COMPLETED, (payload) => {
      this.transition(payload.userId, JourneyAction.COMPLETE_TRIAGE, {
        triagePriority: payload.data.priority,
      });
    });

    this.eventBus.on(HealthcareEvent.RECOMMENDATION_GENERATED, (payload) => {
      this.transition(payload.userId, JourneyAction.GET_RECOMMENDATION, {
        recommendedHospital: payload.data.hospitalName,
      });
    });

    this.eventBus.on(HealthcareEvent.APPOINTMENT_BOOKED, (payload) => {
      this.transition(payload.userId, JourneyAction.BOOK_APPOINTMENT, {
        appointmentId: payload.data.appointmentId,
      });
    });

    this.eventBus.on(HealthcareEvent.EMERGENCY_TRIGGERED, (payload) => {
      this.transition(payload.userId, JourneyAction.TRIGGER_EMERGENCY);
    });
  }

  getJourney(userId: string): JourneySnapshot {
    if (!this.journeys.has(userId)) {
      this.journeys.set(userId, {
        userId,
        state: JourneyState.START,
        previousStates: [],
        startedAt: new Date(),
        lastUpdatedAt: new Date(),
        data: {},
      });
    }
    return this.journeys.get(userId)!;
  }

  transition(userId: string, action: JourneyAction, data?: Record<string, any>): JourneySnapshot {
    const journey = this.getJourney(userId);
    const currentState = journey.state;

    const allowedTransitions = TRANSITIONS[currentState];
    const nextState = allowedTransitions?.[action];

    if (!nextState) {
      this.logger.warn(`Invalid transition: ${currentState} + ${action} for user ${userId}`);
      return journey;
    }

    // Record previous state
    journey.previousStates.push({ state: currentState, timestamp: new Date() });
    if (journey.previousStates.length > 20) {
      journey.previousStates.shift();
    }

    // Transition
    journey.state = nextState;
    journey.lastUpdatedAt = new Date();
    if (data) {
      Object.assign(journey.data, data);
    }

    this.logger.log(`Journey [${userId}]: ${currentState} → ${nextState} (action: ${action})`);

    // Emit state change event
    this.eventBus.emit(
      HealthcareEvent.JOURNEY_STATE_CHANGED,
      userId,
      { previousState: currentState, newState: nextState, action, journeyData: journey.data },
      'medium',
    );

    return journey;
  }

  getProgress(userId: string): { state: JourneyState; step: number; totalSteps: number; progressPercent: number } {
    const journey = this.getJourney(userId);
    const stateOrder = [
      JourneyState.START,
      JourneyState.CHECK_SYMPTOMS,
      JourneyState.TRIAGE,
      JourneyState.RECOMMENDATION,
      JourneyState.APPOINTMENT,
      JourneyState.VISIT,
      JourneyState.FOLLOWUP,
      JourneyState.COMPLETED,
    ];
    const step = stateOrder.indexOf(journey.state);
    const totalSteps = stateOrder.length - 1;
    return {
      state: journey.state,
      step: Math.max(0, step),
      totalSteps,
      progressPercent: Math.round((Math.max(0, step) / totalSteps) * 100),
    };
  }

  resetJourney(userId: string): JourneySnapshot {
    return this.transition(userId, JourneyAction.RESET);
  }
}
