import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ChatOpenAI } from '@langchain/openai';
import { HumanMessage, SystemMessage, ToolMessage, BaseMessage } from '@langchain/core/messages';
import { tool } from '@langchain/core/tools';
import { z } from 'zod';
import { ContextAwareService } from './context-aware.service';
import { PatientJourneyService, JourneyState } from './patient-journey.service';
import { HospitalPerformanceService } from './hospital-performance.service';
import { EventBusService, HealthcareEvent } from './event-bus.service';

@Injectable()
export class LangChainAgentService {
  private readonly logger = new Logger(LangChainAgentService.name);
  private readonly llm: ChatOpenAI;

  constructor(
    private readonly configService: ConfigService,
    private readonly contextService: ContextAwareService,
    private readonly journeyService: PatientJourneyService,
    private readonly hospitalService: HospitalPerformanceService,
    private readonly eventBus: EventBusService,
  ) {
    // Initialize LangChain with Grok API (OpenAI-compatible)
    this.llm = new ChatOpenAI({
      openAIApiKey: this.configService.get('GROK_API_KEY'),
      modelName: this.configService.get('GROK_MODEL', 'grok-3-latest'),
      temperature: 0.4,
      maxTokens: this.configService.get<number>('GROK_MAX_TOKENS', 4096),
      configuration: {
        baseURL: 'https://api.x.ai/v1',
      },
    });

    this.logger.log('LangChain Agent initialized with Grok API');
  }

  /**
   * Build LangChain tools that operate on the Oriented System
   */
  private buildTools(userId: string) {
    const getPatientContextTool = tool(
      async () => {
        const context = this.contextService.buildAIContext(userId);
        return JSON.stringify(context, null, 2);
      },
      {
        name: 'get_patient_context',
        description: 'Get the full context of the patient including location, health state, history, and journey progress. Use this to understand who the patient is and what they need.',
        schema: z.object({}),
      },
    );

    const getJourneyProgressTool = tool(
      async () => {
        const progress = this.journeyService.getProgress(userId);
        const journey = this.journeyService.getJourney(userId);
        return JSON.stringify({
          currentState: journey.state,
          progress: `${progress.progressPercent}%`,
          step: `${progress.step}/${progress.totalSteps}`,
          data: journey.data,
          previousStates: journey.previousStates.slice(-5),
        }, null, 2);
      },
      {
        name: 'get_journey_progress',
        description: 'Get the patient journey progress through the healthcare system (symptoms → triage → recommendation → appointment → visit → followup)',
        schema: z.object({}),
      },
    );

    const getHospitalRankingTool = tool(
      async (input: any) => {
        const hospitals = input.specialization
          ? this.hospitalService.getTopHospitals(5, input.specialization)
          : this.hospitalService.getTopHospitals(5);
        return JSON.stringify(hospitals.map((h) => ({
          name: h.hospitalNameAr,
          score: h.overallScore,
          waitTime: `${h.metrics.waitTime} دقيقة`,
          satisfaction: `${h.metrics.patientSatisfaction}%`,
          specializations: h.specializations,
        })), null, 2);
      },
      {
        name: 'get_hospital_ranking',
        description: 'Get top-ranked hospitals by performance score. Optionally filter by specialization (e.g., cardiology, surgery, emergency).',
        schema: z.object({
          specialization: z.string().optional().describe('Medical specialization to filter by'),
        }),
      },
    );

    const getHospitalScoreTool = tool(
      async (input: any) => {
        const score = this.hospitalService.getScore(input.hospitalName);
        if (!score) return JSON.stringify({ error: 'Hospital not found' });
        return JSON.stringify({
          name: score.hospitalNameAr,
          overallScore: score.overallScore,
          metrics: score.metrics,
          specializations: score.specializations,
          governorate: score.governorate,
        }, null, 2);
      },
      {
        name: 'get_hospital_score',
        description: 'Get detailed performance score and metrics for a specific hospital',
        schema: z.object({
          hospitalName: z.string().describe('Hospital internal name (e.g., jordan_university_hospital, king_hussein_medical)'),
        }),
      },
    );

    const getRecentEventsTool = tool(
      async () => {
        const events = this.eventBus.getRecentEvents(userId, 10);
        return JSON.stringify(events.map((e) => ({
          event: e.event,
          timestamp: e.timestamp,
          data: e.data,
        })), null, 2);
      },
      {
        name: 'get_recent_events',
        description: 'Get recent healthcare events for this patient (symptoms submitted, triage, appointments, etc.)',
        schema: z.object({}),
      },
    );

    const emitEventTool = tool(
      async (input: any) => {
        const event = input.eventType as HealthcareEvent;
        const correlationId = this.eventBus.emit(event, userId, input.data || {}, input.priority as any);
        return JSON.stringify({ success: true, correlationId, event });
      },
      {
        name: 'emit_event',
        description: 'Emit a healthcare event to trigger system actions (e.g., user_submitted_symptoms, appointment_booked)',
        schema: z.object({
          eventType: z.string().describe('Event type from HealthcareEvent enum'),
          data: z.record(z.string(), z.any()).optional().describe('Event payload data'),
          priority: z.enum(['low', 'medium', 'high', 'emergency']).optional().describe('Event priority'),
        }),
      },
    );

    return [
      getPatientContextTool,
      getJourneyProgressTool,
      getHospitalRankingTool,
      getHospitalScoreTool,
      getRecentEventsTool,
      emitEventTool,
    ];
  }

  /**
   * Process a user message through LangChain agent with tool-use
   */
  async process(userId: string, message: string, requestContext?: Record<string, any>): Promise<{
    response: string;
    toolsUsed: string[];
    journeyState: JourneyState;
  }> {
    const tools = this.buildTools(userId);
    const llmWithTools = this.llm.bindTools(tools);

    // Build enriched context
    const context = this.contextService.buildAIContext(userId);

    const systemPrompt = `أنت وكيل صحي ذكي في نظام "نبض" — النظام الصحي الذكي الأردني.

## نظام Oriented System
أنت تعمل ضمن نظام موجّه (Oriented System) يتتبع:
1. **رحلة المريض** (Patient Journey): ${context.journeyState} — التقدم: ${context.journeyProgress}%
2. **السياق الكامل**: الموقع (${context.governorate || 'غير محدد'})، الأمراض المزمنة، التاريخ الطبي
3. **أداء المستشفيات**: تقييمات حية لكل مستشفى أردني
4. **الأحداث**: كل تفاعل يُسجّل كحدث في النظام

## قواعد:
- أجب بالعربي (اللهجة الأردنية مقبولة)
- استخدم الأدوات المتاحة لفهم حالة المريض قبل الإجابة
- لا تشخّص — وجّه للطبيب المختص
- حالة طارئة = اتصل 911 فوراً
- كن مختصراً ومهنياً وودّياً
- أذكر تقدم الرحلة إذا كان مهماً
- اقترح المستشفيات بناءً على تقييمات الأداء الحقيقية

## سياق المريض الحالي:
- الموقع: ${context.governorate || 'غير محدد'}
- الأعراض الحالية: ${context.currentSymptoms?.join('، ') || 'لا يوجد'}
- أمراض مزمنة: ${context.chronicConditions?.join('، ') || 'لا يوجد'}
- زيارات سابقة: ${context.totalVisits || 0}
- مرحلة الرحلة: ${context.journeyState} (${context.journeyProgress}%)`;

    const messages: BaseMessage[] = [
      new SystemMessage(systemPrompt),
      new HumanMessage(message),
    ];

    const toolsUsed: string[] = [];

    try {
      // First call — might request tool use
      let aiResponse = await llmWithTools.invoke(messages);

      // Tool-use loop (max 3 iterations)
      let iterations = 0;
      while (aiResponse.tool_calls && aiResponse.tool_calls.length > 0 && iterations < 3) {
        iterations++;
        messages.push(aiResponse);

        for (const toolCall of aiResponse.tool_calls) {
          this.logger.debug(`LangChain tool call: ${toolCall.name}`);
          toolsUsed.push(toolCall.name);

          const matchedTool = tools.find((t) => t.name === toolCall.name);
          if (matchedTool) {
            const toolResult = await (matchedTool as any).invoke(toolCall.args);
            const resultStr = typeof toolResult === 'string' ? toolResult : JSON.stringify(toolResult);
            messages.push(new ToolMessage({
              content: resultStr,
              tool_call_id: toolCall.id!,
            }));
          }
        }

        // Get next response after tool results
        aiResponse = await llmWithTools.invoke(messages);
      }

      const responseText = typeof aiResponse.content === 'string'
        ? aiResponse.content
        : (aiResponse.content as any[])?.map((c: any) => c.text || '').join('') || 'لا يوجد رد';

      // Emit AI pipeline completed event
      this.eventBus.emit(HealthcareEvent.AI_PIPELINE_COMPLETED, userId, {
        toolsUsed,
        responseLength: responseText.length,
        iterations,
      });

      return {
        response: responseText,
        toolsUsed,
        journeyState: this.journeyService.getJourney(userId).state,
      };
    } catch (error: any) {
      this.logger.error(`LangChain agent error: ${error.message}`);

      // Fallback to direct LLM without tools
      try {
        const fallbackResponse = await this.llm.invoke([
          new SystemMessage(systemPrompt),
          new HumanMessage(message),
        ]);
        const content = typeof fallbackResponse.content === 'string'
          ? fallbackResponse.content
          : 'عذراً، حصل خطأ تقني. يرجى المحاولة مرة أخرى.';

        return {
          response: content,
          toolsUsed: ['fallback_direct_llm'],
          journeyState: this.journeyService.getJourney(userId).state,
        };
      } catch {
        return {
          response: 'عذراً، النظام غير متاح حالياً. يرجى المحاولة لاحقاً أو الاتصال بـ 911 في حالة الطوارئ.',
          toolsUsed: ['offline_fallback'],
          journeyState: this.journeyService.getJourney(userId).state,
        };
      }
    }
  }
}
