import { Injectable, Logger } from '@nestjs/common';
import { EventBusService, HealthcareEvent } from './event-bus.service';
import { PatientJourneyService, JourneyState } from './patient-journey.service';

// ─── User Context ────────────────────────────────────────────
export interface UserContext {
  userId: string;

  // Location awareness
  location?: {
    lat: number;
    lng: number;
    governorate?: string;
    city?: string;
    lastUpdated: Date;
  };

  // Health state awareness
  healthState?: {
    currentSymptoms: string[];
    chronicConditions: string[];
    recentDiagnoses: string[];
    activeMedications: string[];
    allergies: string[];
    lastVisitDate?: Date;
  };

  // History awareness
  history?: {
    totalVisits: number;
    totalEmergencies: number;
    preferredHospital?: string;
    preferredDoctor?: string;
    insuranceProvider?: string;
    lastBookedSpecialization?: string;
  };

  // Demographics
  demographics?: {
    age?: number;
    gender?: string;
    bloodType?: string;
    language?: string;
  };

  // Journey state
  journeyState: JourneyState;

  lastUpdated: Date;
}

@Injectable()
export class ContextAwareService {
  private readonly logger = new Logger(ContextAwareService.name);
  private readonly contexts = new Map<string, UserContext>();

  constructor(
    private readonly eventBus: EventBusService,
    private readonly journeyService: PatientJourneyService,
  ) {
    this.registerEventListeners();
  }

  private registerEventListeners() {
    // Update context when location changes
    this.eventBus.on(HealthcareEvent.LOCATION_UPDATED, (payload) => {
      this.updateLocation(
        payload.userId,
        payload.data.lat,
        payload.data.lng,
        payload.data.governorate,
      );
    });

    // Update context when symptoms submitted
    this.eventBus.on(HealthcareEvent.USER_SUBMITTED_SYMPTOMS, (payload) => {
      const ctx = this.getContext(payload.userId);
      if (!ctx.healthState) {
        ctx.healthState = { currentSymptoms: [], chronicConditions: [], recentDiagnoses: [], activeMedications: [], allergies: [] };
      }
      ctx.healthState.currentSymptoms = payload.data.symptoms || [];
      ctx.lastUpdated = new Date();
    });

    // Update context when health records change
    this.eventBus.on(HealthcareEvent.HEALTH_RECORD_UPDATED, (payload) => {
      const ctx = this.getContext(payload.userId);
      if (!ctx.healthState) {
        ctx.healthState = { currentSymptoms: [], chronicConditions: [], recentDiagnoses: [], activeMedications: [], allergies: [] };
      }
      if (payload.data.chronicConditions) ctx.healthState.chronicConditions = payload.data.chronicConditions;
      if (payload.data.medications) ctx.healthState.activeMedications = payload.data.medications;
      if (payload.data.allergies) ctx.healthState.allergies = payload.data.allergies;
      ctx.lastUpdated = new Date();
    });

    // Update history when appointment booked
    this.eventBus.on(HealthcareEvent.APPOINTMENT_BOOKED, (payload) => {
      const ctx = this.getContext(payload.userId);
      if (!ctx.history) {
        ctx.history = { totalVisits: 0, totalEmergencies: 0 };
      }
      ctx.history.totalVisits++;
      if (payload.data.hospitalName) ctx.history.preferredHospital = payload.data.hospitalName;
      if (payload.data.specialization) ctx.history.lastBookedSpecialization = payload.data.specialization;
      ctx.lastUpdated = new Date();
    });

    // Track emergencies
    this.eventBus.on(HealthcareEvent.EMERGENCY_TRIGGERED, (payload) => {
      const ctx = this.getContext(payload.userId);
      if (!ctx.history) {
        ctx.history = { totalVisits: 0, totalEmergencies: 0 };
      }
      ctx.history.totalEmergencies++;
      ctx.lastUpdated = new Date();
    });

    // Sync journey state
    this.eventBus.on(HealthcareEvent.JOURNEY_STATE_CHANGED, (payload) => {
      const ctx = this.getContext(payload.userId);
      ctx.journeyState = payload.data.newState;
      ctx.lastUpdated = new Date();
    });
  }

  getContext(userId: string): UserContext {
    if (!this.contexts.has(userId)) {
      const journey = this.journeyService.getJourney(userId);
      this.contexts.set(userId, {
        userId,
        journeyState: journey.state,
        lastUpdated: new Date(),
      });
    }
    return this.contexts.get(userId)!;
  }

  updateLocation(userId: string, lat: number, lng: number, governorate?: string) {
    const ctx = this.getContext(userId);
    ctx.location = {
      lat,
      lng,
      governorate,
      lastUpdated: new Date(),
    };
    ctx.lastUpdated = new Date();
    this.logger.debug(`Location updated for ${userId}: ${lat},${lng} (${governorate || 'unknown'})`);
  }

  updateDemographics(userId: string, demographics: Partial<UserContext['demographics']>) {
    const ctx = this.getContext(userId);
    ctx.demographics = { ...ctx.demographics, ...demographics };
    ctx.lastUpdated = new Date();
  }

  /**
   * Build enriched context for AI pipeline — the system "knows" about the user
   */
  buildAIContext(userId: string): Record<string, any> {
    const ctx = this.getContext(userId);
    const journey = this.journeyService.getJourney(userId);
    const progress = this.journeyService.getProgress(userId);
    const recentEvents = this.eventBus.getRecentEvents(userId, 5);

    return {
      // Who
      userId: ctx.userId,
      age: ctx.demographics?.age,
      gender: ctx.demographics?.gender,
      language: ctx.demographics?.language || 'ar',

      // Where
      locationLat: ctx.location?.lat,
      locationLng: ctx.location?.lng,
      governorate: ctx.location?.governorate,

      // Health state
      currentSymptoms: ctx.healthState?.currentSymptoms || [],
      chronicConditions: ctx.healthState?.chronicConditions || [],
      activeMedications: ctx.healthState?.activeMedications || [],
      allergies: ctx.healthState?.allergies || [],

      // History
      totalVisits: ctx.history?.totalVisits || 0,
      totalEmergencies: ctx.history?.totalEmergencies || 0,
      preferredHospital: ctx.history?.preferredHospital,
      insuranceProvider: ctx.history?.insuranceProvider,

      // Journey
      journeyState: journey.state,
      journeyProgress: progress.progressPercent,
      journeyStep: progress.step,
      journeyData: journey.data,

      // Recent activity
      recentEvents: recentEvents.map((e) => ({
        event: e.event,
        timestamp: e.timestamp,
      })),
    };
  }
}
