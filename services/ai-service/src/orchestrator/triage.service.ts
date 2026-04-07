import { Injectable, Logger } from '@nestjs/common';
import { LlmService, ChatMessage } from '../llm/llm.service';

export enum TriagePriority {
  EMERGENCY = 'emergency',
  HIGH = 'high',
  MEDIUM = 'medium',
  LOW = 'low',
}

export interface TriageResult {
  priority: TriagePriority;
  confidence: number;
  reasoning: string;
  recommendedAction: string;
  estimatedWaitMinutes: number;
  requiresER: boolean;
  suggestedSpecialization: string;
  warningFlags: string[];
}

const TRIAGE_SYSTEM_PROMPT = `أنت نموذج فرز طبي (Triage) في نظام صحي ذكي أردني. مهمتك تقييم الحالة الطبية بناءً على الأعراض المقدمة.

صنّف الحالة إلى:
- emergency: حالة تهدد الحياة (ألم صدر حاد، صعوبة تنفس شديدة، نزيف حاد، فقدان وعي، جلطة، سكتة)
- high: حالة خطيرة تحتاج رعاية عاجلة خلال ساعات (حرارة عالية جداً > 39.5، ألم شديد، كسور، حروق متوسطة)
- medium: حالة تحتاج رعاية خلال يوم أو يومين (ألم مزمن، التهابات، حرارة متوسطة)
- low: حالة بسيطة يمكن الانتظار (رشح، صداع خفيف، فحص دوري)

أجب فقط بـ JSON:
{
  "priority": "emergency|high|medium|low",
  "confidence": 0.0-1.0,
  "reasoning": "سبب التصنيف بالعربي",
  "recommendedAction": "الإجراء المطلوب بالعربي",
  "estimatedWaitMinutes": number,
  "requiresER": true/false,
  "suggestedSpecialization": "التخصص المطلوب بالإنجليزي",
  "warningFlags": ["أي تحذيرات مهمة"]
}

قواعد مهمة:
- أنت لا تشخّص، بل تصنّف مستوى الاستعجال
- أعراض القلب والتنفس والنزيف = emergency دائماً
- الأطفال وكبار السن يحصلون على أولوية أعلى
- الحوامل لهن أولوية خاصة`;

@Injectable()
export class TriageService {
  private readonly logger = new Logger(TriageService.name);

  constructor(private readonly llmService: LlmService) {}

  async assess(symptoms: string[], additionalContext?: string): Promise<TriageResult> {
    const symptomText = symptoms.join('، ');
    let userMessage = `الأعراض: ${symptomText}`;
    if (additionalContext) {
      userMessage += `\nمعلومات إضافية: ${additionalContext}`;
    }

    const messages: ChatMessage[] = [
      { role: 'user', content: userMessage },
    ];

    try {
      return await this.llmService.chatJSON<TriageResult>(messages, TRIAGE_SYSTEM_PROMPT);
    } catch (error: any) {
      this.logger.error(`Triage assessment failed: ${error.message}`);
      // Default to medium priority on failure for safety
      return {
        priority: TriagePriority.MEDIUM,
        confidence: 0,
        reasoning: 'تعذّر التقييم التلقائي — يرجى مراجعة طبيب',
        recommendedAction: 'مراجعة أقرب مركز صحي',
        estimatedWaitMinutes: 60,
        requiresER: false,
        suggestedSpecialization: 'internal_medicine',
        warningFlags: ['فشل التقييم التلقائي'],
      };
    }
  }
}
