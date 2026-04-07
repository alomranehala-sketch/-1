import { Injectable, Logger } from '@nestjs/common';
import { LlmService, ChatMessage } from '../llm/llm.service';

export enum IntentType {
  BOOKING = 'booking',
  CANCEL = 'cancel',
  RESCHEDULE = 'reschedule',
  SYMPTOMS = 'symptoms',
  EMERGENCY = 'emergency',
  DATA_REQUEST = 'data_request',
  GENERAL_QUESTION = 'general_question',
  MEDICATION_INFO = 'medication_info',
  LAB_RESULTS = 'lab_results',
  NOTIFICATION = 'notification',
  GREETING = 'greeting',
  UNKNOWN = 'unknown',
}

export interface NlpResult {
  intent: IntentType;
  confidence: number;
  entities: {
    symptoms?: string[];
    specialization?: string;
    date?: string;
    time?: string;
    hospital?: string;
    doctor?: string;
    medication?: string;
    bodyPart?: string;
    governorate?: string;
    severity_hint?: string;
  };
  language: 'ar' | 'en';
  originalText: string;
  normalizedText: string;
}

const NLP_SYSTEM_PROMPT = `أنت محلل لغة طبيعية في نظام صحي ذكي أردني. مهمتك تحليل رسائل المستخدمين (عربي/أردني/إنجليزي) واستخراج:
1. النية (intent): booking, cancel, reschedule, symptoms, emergency, data_request, general_question, medication_info, lab_results, notification, greeting, unknown
2. الكيانات المستخرجة (entities): أعراض، تخصص، تاريخ، وقت، مستشفى، طبيب، دواء، عضو جسم، محافظة، مؤشر خطورة
3. اللغة: ar أو en
4. النص المُعدّل (normalizedText): النص مُصحّح إملائياً

قواعد:
- "احجزلي" / "بدي موعد" / "ابي أحجز" = booking
- "لغيلي" / "لا أريد" / "الغِ" = cancel
- "أجّلي" / "غيّر الموعد" / "حوّلي" = reschedule
- "عندي ألم" / "بوجعني" / "أحس بـ" = symptoms
- "إسعاف" / "طوارئ" / "مو قادر أتنفس" / "ألم صدر شديد" = emergency
- "بياناتي" / "سجلي" / "تحاليلي" / "نتائجي" = data_request
- "شو هو" / "كيف" / "ليش" = general_question
- "دوا" / "حبوب" / "علاج" = medication_info
- استخرج التخصص: "قلب" → cardiology، "عظام" → orthopedics، "أطفال" → pediatrics، "عيون" → ophthalmology، "جلدية" → dermatology، "أعصاب" → neurology، "نسائية" → gynecology، "باطنية" → internal_medicine، "أسنان" → dentistry

أجب فقط بـ JSON:
{
  "intent": "...",
  "confidence": 0.0-1.0,
  "entities": { ... },
  "language": "ar|en",
  "normalizedText": "..."
}`;

@Injectable()
export class NlpService {
  private readonly logger = new Logger(NlpService.name);

  constructor(private readonly llmService: LlmService) {}

  async analyze(text: string): Promise<NlpResult> {
    const messages: ChatMessage[] = [
      { role: 'user', content: text },
    ];

    try {
      const result = await this.llmService.chatJSON<Omit<NlpResult, 'originalText'>>(
        messages,
        NLP_SYSTEM_PROMPT,
      );

      return {
        ...result,
        originalText: text,
      };
    } catch (error: any) {
      this.logger.error(`NLP analysis failed: ${error.message}`);
      return {
        intent: IntentType.UNKNOWN,
        confidence: 0,
        entities: {},
        language: 'ar',
        originalText: text,
        normalizedText: text,
      };
    }
  }
}
