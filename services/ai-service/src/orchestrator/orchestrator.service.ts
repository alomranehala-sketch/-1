import { Injectable, Logger } from '@nestjs/common';
import { NlpService, IntentType, NlpResult } from './nlp.service';
import { TriageService, TriagePriority, TriageResult } from './triage.service';
import { RecommendationService, RecommendationResult } from './recommendation.service';
import { PredictionService, PredictionResult } from './prediction.service';
import { AgentService, AgentAction, AgentResult } from './agent.service';
import { LlmService, ChatMessage } from '../llm/llm.service';
import {
  EventBusService,
  HealthcareEvent,
  ContextAwareService,
  PatientJourneyService,
  HospitalPerformanceService,
  LangChainAgentService,
} from '../oriented-system';

export interface OrchestratorRequest {
  userId: string;
  message: string;
  context?: {
    governorate?: string;
    age?: number;
    gender?: string;
    chronicConditions?: string[];
    insuranceProvider?: string;
    locationLat?: number;
    locationLng?: number;
    appointmentId?: string;
  };
}

export interface OrchestratorResponse {
  intent: string;
  priority: string;
  action: string;
  data: {
    nlp?: NlpResult;
    triage?: TriageResult;
    recommendation?: RecommendationResult;
    prediction?: PredictionResult;
    agentResult?: AgentResult;
    conversationalReply?: string;
  };
  next_steps: string[];
  responseMessage: string;
  responseMessageAr: string;
  executionTimeMs: number;
  pipelineSteps: string[];
  // Oriented System data
  journey?: {
    state: string;
    progressPercent: number;
    step: number;
    totalSteps: number;
  };
  context?: Record<string, any>;
  hospitalRanking?: { hospitalNameAr: string; score: number }[];
  toolsUsed?: string[];
}

const CONVERSATIONAL_SYSTEM_PROMPT = `أنت مساعد صحي ذكي في نظام "نبض" — النظام الصحي الذكي الأردني.

قواعد:
- أجب بالعربي (اللهجة الأردنية مقبولة)
- كن مختصراً ومهنياً
- لا تشخّص أمراض — وجّه المريض للطبيب المختص
- إذا كانت الحالة طارئة، اطلب الاتصال بالإسعاف فوراً (911)
- استخدم تعبيرات ودّية ومطمئنة
- أضف إخلاء مسؤولية أنك ذكاء اصطناعي وليس بديلاً عن الطبيب`;

@Injectable()
export class OrchestratorService {
  private readonly logger = new Logger(OrchestratorService.name);

  constructor(
    private readonly nlpService: NlpService,
    private readonly triageService: TriageService,
    private readonly recommendationService: RecommendationService,
    private readonly predictionService: PredictionService,
    private readonly agentService: AgentService,
    private readonly llmService: LlmService,
    private readonly eventBus: EventBusService,
    private readonly contextService: ContextAwareService,
    private readonly journeyService: PatientJourneyService,
    private readonly hospitalService: HospitalPerformanceService,
    private readonly langChainAgent: LangChainAgentService,
  ) {}

  async process(request: OrchestratorRequest): Promise<OrchestratorResponse> {
    const start = Date.now();
    const pipelineSteps: string[] = [];

    // ─── Oriented System: Emit pipeline start event ──────────
    this.eventBus.emit(HealthcareEvent.AI_PIPELINE_STARTED, request.userId, {
      message: request.message,
    });

    // ─── Oriented System: Enrich request with context ────────
    if (request.context?.locationLat && request.context?.locationLng) {
      this.contextService.updateLocation(
        request.userId,
        request.context.locationLat,
        request.context.locationLng,
        request.context.governorate,
      );
    }
    if (request.context?.age || request.context?.gender) {
      this.contextService.updateDemographics(request.userId, {
        age: request.context?.age,
        gender: request.context?.gender,
      });
    }

    // ─── STEP 1: NLP — Understand Intent ─────────────────────
    pipelineSteps.push('nlp');
    const nlpResult = await this.nlpService.analyze(request.message);
    this.logger.log(`Intent: ${nlpResult.intent} (confidence: ${nlpResult.confidence})`);

    const response: OrchestratorResponse = {
      intent: nlpResult.intent,
      priority: 'low',
      action: 'none',
      data: { nlp: nlpResult },
      next_steps: [],
      responseMessage: '',
      responseMessageAr: '',
      executionTimeMs: 0,
      pipelineSteps,
    };

    // ─── STEP 2: Route by Intent ─────────────────────────────
    switch (nlpResult.intent) {
      case IntentType.EMERGENCY:
        await this.handleEmergency(request, nlpResult, response, pipelineSteps);
        break;

      case IntentType.SYMPTOMS:
        await this.handleSymptoms(request, nlpResult, response, pipelineSteps);
        break;

      case IntentType.BOOKING:
        await this.handleBooking(request, nlpResult, response, pipelineSteps);
        break;

      case IntentType.CANCEL:
        await this.handleCancel(request, nlpResult, response, pipelineSteps);
        break;

      case IntentType.RESCHEDULE:
        await this.handleReschedule(request, nlpResult, response, pipelineSteps);
        break;

      case IntentType.DATA_REQUEST:
      case IntentType.LAB_RESULTS:
        await this.handleDataRequest(request, nlpResult, response, pipelineSteps);
        break;

      case IntentType.GENERAL_QUESTION:
      case IntentType.MEDICATION_INFO:
      case IntentType.GREETING:
      default:
        await this.handleGeneralConversation(request, nlpResult, response, pipelineSteps);
        break;
    }

    response.executionTimeMs = Date.now() - start;
    response.pipelineSteps = pipelineSteps;

    // ─── Oriented System: Attach journey & context ───────────
    const progress = this.journeyService.getProgress(request.userId);
    response.journey = {
      state: progress.state,
      progressPercent: progress.progressPercent,
      step: progress.step,
      totalSteps: progress.totalSteps,
    };
    response.context = this.contextService.buildAIContext(request.userId);
    response.hospitalRanking = this.hospitalService.getTopHospitals(3).map((h) => ({
      hospitalNameAr: h.hospitalNameAr,
      score: h.overallScore,
    }));

    // Emit completion event
    this.eventBus.emit(HealthcareEvent.AI_PIPELINE_COMPLETED, request.userId, {
      intent: nlpResult.intent,
      executionTimeMs: response.executionTimeMs,
      pipelineSteps,
    });

    this.logger.log(`Orchestrator completed in ${response.executionTimeMs}ms — pipeline: ${pipelineSteps.join(' → ')}`);
    return response;
  }

  // ─── EMERGENCY HANDLER ──────────────────────────────────────
  private async handleEmergency(
    request: OrchestratorRequest,
    nlp: NlpResult,
    response: OrchestratorResponse,
    steps: string[],
  ): Promise<void> {
    steps.push('triage');
    const symptoms = nlp.entities.symptoms || [request.message];

    let triage: TriageResult;
    try {
      triage = await this.triageService.assess(symptoms);
    } catch (error: any) {
      this.logger.error(`Triage failed in emergency: ${error.message}`);
      triage = {
        priority: TriagePriority.EMERGENCY,
        confidence: 0,
        reasoning: 'حالة طوارئ — لم يتم التقييم التلقائي',
        recommendedAction: 'اتصل بالإسعاف فوراً 911',
        estimatedWaitMinutes: 0,
        suggestedSpecialization: 'emergency',
        warningFlags: ['triage_failed'],
        requiresER: true,
      };
    }
    response.data.triage = triage;
    response.priority = 'emergency';
    response.action = 'trigger_emergency';

    // Trigger emergency alert via agent
    steps.push('agent:trigger_emergency');
    try {
      const agentResult = await this.agentService.execute({
        action: AgentAction.TRIGGER_EMERGENCY,
        userId: request.userId,
        params: {
          severity: 'critical',
          message: `حالة طوارئ — ${nlp.normalizedText}`,
          locationLat: request.context?.locationLat,
          locationLng: request.context?.locationLng,
        },
      });
      response.data.agentResult = agentResult;
    } catch (error: any) {
      this.logger.error(`Emergency agent failed: ${error.message}`);
    }

    response.responseMessageAr = `🚨 تم تسجيل حالة طوارئ!\n${triage.recommendedAction}\nاتصل بالإسعاف فوراً: 911`;
    response.responseMessage = `🚨 Emergency alert triggered! ${triage.recommendedAction}. Call 911 immediately.`;
    response.next_steps = ['call_911', 'dispatch_ambulance', 'notify_nearest_er'];
  }

  // ─── SYMPTOMS HANDLER ───────────────────────────────────────
  private async handleSymptoms(
    request: OrchestratorRequest,
    nlp: NlpResult,
    response: OrchestratorResponse,
    steps: string[],
  ): Promise<void> {
    // Emit event for Oriented System
    const symptoms = nlp.entities.symptoms || [request.message];
    this.eventBus.emit(HealthcareEvent.USER_SUBMITTED_SYMPTOMS, request.userId, { symptoms }, 'medium');

    // Triage the symptoms
    steps.push('triage');
    let additionalContext = '';
    if (request.context?.age) additionalContext += `العمر: ${request.context.age}. `;
    if (request.context?.chronicConditions?.length) {
      additionalContext += `أمراض مزمنة: ${request.context.chronicConditions.join('، ')}. `;
    }

    let triage: TriageResult;
    try {
      triage = await this.triageService.assess(symptoms, additionalContext || undefined);
    } catch (error: any) {
      this.logger.error(`Triage failed: ${error.message}`);
      triage = {
        priority: TriagePriority.MEDIUM,
        confidence: 0,
        reasoning: 'تعذّر التقييم التلقائي — يرجى مراجعة الطبيب',
        recommendedAction: 'راجع طبيبك في أقرب وقت',
        estimatedWaitMinutes: 0,
        suggestedSpecialization: 'internal_medicine',
        warningFlags: ['triage_failed'],
        requiresER: false,
      };
    }
    response.data.triage = triage;
    response.priority = triage.priority;

    // Emit triage completed event
    this.eventBus.emit(HealthcareEvent.TRIAGE_COMPLETED, request.userId, {
      priority: triage.priority,
      specialization: triage.suggestedSpecialization,
    }, triage.priority === TriagePriority.EMERGENCY ? 'emergency' : 'medium');

    // If urgent, also recommend a hospital
    if (triage.priority === TriagePriority.EMERGENCY || triage.priority === TriagePriority.HIGH) {
      steps.push('recommendation');
      const recommendation = await this.recommendationService.recommend({
        specialization: triage.suggestedSpecialization || nlp.entities.specialization || 'internal_medicine',
        governorate: nlp.entities.governorate || request.context?.governorate,
        urgency: triage.priority,
        insuranceProvider: request.context?.insuranceProvider,
        patientAge: request.context?.age,
      });
      response.data.recommendation = recommendation;
      response.action = 'recommend_hospital';
      response.next_steps = ['visit_recommended_hospital', 'book_appointment'];

      if (triage.priority === TriagePriority.EMERGENCY) {
        steps.push('agent:trigger_emergency');
        const agentResult = await this.agentService.execute({
          action: AgentAction.TRIGGER_EMERGENCY,
          userId: request.userId,
          params: {
            severity: 'high',
            message: `أعراض خطيرة: ${symptoms.join('، ')}`,
            locationLat: request.context?.locationLat,
            locationLng: request.context?.locationLng,
          },
        });
        response.data.agentResult = agentResult;
      }
    } else {
      response.action = 'provide_guidance';
      response.next_steps = ['monitor_symptoms', 'book_appointment_if_persists'];
    }

    response.responseMessageAr = `${triage.reasoning}\n\n${triage.recommendedAction}`;
    response.responseMessage = triage.reasoning;
  }

  // ─── BOOKING HANDLER ────────────────────────────────────────
  private async handleBooking(
    request: OrchestratorRequest,
    nlp: NlpResult,
    response: OrchestratorResponse,
    steps: string[],
  ): Promise<void> {
    const specialization = nlp.entities.specialization || 'general';

    // Get recommendation
    steps.push('recommendation');
    const recommendation = await this.recommendationService.recommend({
      specialization,
      governorate: nlp.entities.governorate || request.context?.governorate,
      urgency: 'medium',
      preferredDate: nlp.entities.date,
      insuranceProvider: request.context?.insuranceProvider,
      patientAge: request.context?.age,
    });
    response.data.recommendation = recommendation;

    // Emit recommendation event
    this.eventBus.emit(HealthcareEvent.RECOMMENDATION_GENERATED, request.userId, {
      hospitalName: recommendation.bestMatch.hospitalName,
      specialization,
    });

    // Book via agent
    steps.push('agent:book_appointment');
    const best = recommendation.bestMatch;
    let agentResult: AgentResult;
    try {
      agentResult = await this.agentService.execute({
        action: AgentAction.BOOK_APPOINTMENT,
        userId: request.userId,
        params: {
          specialization,
          hospitalId: best.hospitalName,
          doctorId: best.suggestedDoctor,
          scheduledAt: best.suggestedTimeSlot || nlp.entities.date,
          reason: nlp.normalizedText,
        },
      });
    } catch (error: any) {
      this.logger.error(`Booking agent failed: ${error.message}`);
      agentResult = {
        action: AgentAction.BOOK_APPOINTMENT,
        status: 'failed',
        data: {},
        message: `Booking failed: ${error.message}`,
        messageAr: 'تعذّر الحجز — يرجى المحاولة لاحقاً',
        executionTimeMs: 0,
      };
    }
    response.data.agentResult = agentResult;

    // Send confirmation notification
    steps.push('agent:send_notification');
    await this.agentService.execute({
      action: AgentAction.SEND_NOTIFICATION,
      userId: request.userId,
      params: {
        type: 'push',
        title: 'تأكيد حجز موعد',
        body: `تم حجز موعد ${specialization} في ${best.hospitalNameAr}`,
        data: { appointmentId: agentResult.data?.data?.id },
      },
    });

    response.priority = 'medium';
    response.action = 'appointment_booked';

    // Emit appointment booked event
    this.eventBus.emit(HealthcareEvent.APPOINTMENT_BOOKED, request.userId, {
      appointmentId: agentResult.data?.data?.id,
      hospitalName: best.hospitalName,
      specialization,
    });

    response.responseMessageAr = `✅ تم حجز موعدك!\n🏥 ${best.hospitalNameAr}\n📅 ${best.suggestedTimeSlot || nlp.entities.date || 'سيتم تحديده'}\n⏱️ وقت الانتظار المتوقع: ${best.estimatedWaitMinutes} دقيقة`;
    response.responseMessage = `Appointment booked at ${best.hospitalName}`;
    response.next_steps = ['confirm_attendance', 'prepare_medical_documents'];
  }

  // ─── CANCEL HANDLER ─────────────────────────────────────────
  private async handleCancel(
    request: OrchestratorRequest,
    nlp: NlpResult,
    response: OrchestratorResponse,
    steps: string[],
  ): Promise<void> {
    steps.push('agent:cancel_appointment');
    const agentResult = await this.agentService.execute({
      action: AgentAction.CANCEL_APPOINTMENT,
      userId: request.userId,
      params: { appointmentId: request.context?.appointmentId || 'latest' },
    });
    response.data.agentResult = agentResult;

    response.priority = 'low';
    response.action = 'appointment_cancelled';
    response.responseMessageAr = '✅ تم إلغاء الموعد بنجاح';
    response.responseMessage = 'Appointment cancelled successfully';
    response.next_steps = ['rebook_if_needed'];
  }

  // ─── RESCHEDULE HANDLER ─────────────────────────────────────
  private async handleReschedule(
    request: OrchestratorRequest,
    nlp: NlpResult,
    response: OrchestratorResponse,
    steps: string[],
  ): Promise<void> {
    steps.push('agent:reschedule_appointment');
    const agentResult = await this.agentService.execute({
      action: AgentAction.RESCHEDULE_APPOINTMENT,
      userId: request.userId,
      params: {
        appointmentId: 'latest',
        newDate: nlp.entities.date,
      },
    });
    response.data.agentResult = agentResult;

    response.priority = 'low';
    response.action = 'appointment_rescheduled';
    response.responseMessageAr = `✅ تم تأجيل الموعد إلى ${nlp.entities.date || 'التاريخ الجديد'}`;
    response.responseMessage = `Appointment rescheduled to ${nlp.entities.date}`;
    response.next_steps = ['confirm_new_date'];
  }

  // ─── DATA REQUEST HANDLER ──────────────────────────────────
  private async handleDataRequest(
    request: OrchestratorRequest,
    nlp: NlpResult,
    response: OrchestratorResponse,
    steps: string[],
  ): Promise<void> {
    const action = nlp.intent === IntentType.LAB_RESULTS
      ? AgentAction.FETCH_LAB_RESULTS
      : AgentAction.FETCH_MEDICAL_DATA;

    steps.push(`agent:${action}`);
    const agentResult = await this.agentService.execute({
      action,
      userId: request.userId,
      params: { dataType: nlp.entities.bodyPart || 'all' },
    });
    response.data.agentResult = agentResult;

    // Simplify the data using AI
    steps.push('ai_simplify');
    const simplifyMessages: ChatMessage[] = [
      {
        role: 'user',
        content: `اشرح هذه البيانات الطبية للمريض بشكل مبسّط بالعربي:\n${JSON.stringify(agentResult.data).substring(0, 3000)}`,
      },
    ];
    const simplified = await this.llmService.chat(simplifyMessages, CONVERSATIONAL_SYSTEM_PROMPT);
    response.data.conversationalReply = simplified.content;

    response.priority = 'low';
    response.action = 'data_retrieved';
    response.responseMessageAr = simplified.content;
    response.responseMessage = 'Medical data retrieved and simplified';
    response.next_steps = ['review_with_doctor'];
  }

  // ─── GENERAL CONVERSATION HANDLER (LangChain Agent) ─────────
  private async handleGeneralConversation(
    request: OrchestratorRequest,
    nlp: NlpResult,
    response: OrchestratorResponse,
    steps: string[],
  ): Promise<void> {
    steps.push('langchain_agent');

    const result = await this.langChainAgent.process(
      request.userId,
      request.message,
      request.context,
    );

    response.data.conversationalReply = result.response;
    response.toolsUsed = result.toolsUsed;

    response.priority = 'low';
    response.action = 'conversational_reply';
    response.responseMessageAr = result.response;
    response.responseMessage = result.response;
    response.next_steps = [];
  }
}
