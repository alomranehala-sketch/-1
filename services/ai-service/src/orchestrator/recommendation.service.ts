import { Injectable, Logger } from '@nestjs/common';
import { LlmService, ChatMessage } from '../llm/llm.service';

export interface RecommendationRequest {
  specialization: string;
  governorate?: string;
  urgency: string;
  preferredDate?: string;
  patientAge?: number;
  patientGender?: string;
  insuranceProvider?: string;
}

export interface HospitalRecommendation {
  hospitalName: string;
  hospitalNameAr: string;
  hospitalType: string;
  governorate: string;
  specialization: string;
  estimatedWaitMinutes: number;
  matchScore: number;
  reasoning: string;
  suggestedDoctor?: string;
  suggestedTimeSlot?: string;
}

export interface RecommendationResult {
  recommendations: HospitalRecommendation[];
  bestMatch: HospitalRecommendation;
  totalOptions: number;
}

const RECOMMENDATION_SYSTEM_PROMPT = `أنت نموذج توصية ذكي في نظام صحي أردني. مهمتك اقتراح أفضل مستشفى/طبيب/موعد بناءً على:
- التخصص المطلوب
- المحافظة / الموقع
- مستوى الاستعجال
- التاريخ المفضل
- التأمين الصحي

المستشفيات المتاحة في الأردن (مرجع):
- مستشفى الجامعة الأردنية (عمان) - حكومي - جميع التخصصات
- مستشفى الملك المؤسس عبدالله الجامعي (إربد) - حكومي - جميع التخصصات
- مستشفى البشير (عمان) - حكومي - طوارئ وجراحة
- المدينة الطبية الملكية (عمان) - عسكري - جميع التخصصات
- مستشفى الأمير حمزة (عمان) - حكومي
- مستشفى الاستقلال (عمان) - حكومي
- مستشفى الخالدي (عمان) - خاص
- مستشفى العبدلي (عمان) - خاص
- مستشفى الإسراء (عمان) - خاص
- مستشفى الأردن (عمان) - خاص
- مستشفى الأميرة بسمة (إربد) - حكومي
- مستشفى الأميرة رحمة (إربد) - حكومي
- مستشفى الزرقاء الحكومي (الزرقاء) - حكومي
- مستشفى الكرك الحكومي (الكرك) - حكومي

أجب فقط بـ JSON:
{
  "recommendations": [
    {
      "hospitalName": "...",
      "hospitalNameAr": "...",
      "hospitalType": "public|private|military|university",
      "governorate": "...",
      "specialization": "...",
      "estimatedWaitMinutes": number,
      "matchScore": 0.0-1.0,
      "reasoning": "سبب الاختيار بالعربي",
      "suggestedDoctor": "اسم الطبيب اذا معروف",
      "suggestedTimeSlot": "2026-04-07T09:00:00"
    }
  ],
  "bestMatch": { ... },
  "totalOptions": number
}

قدّم 3 خيارات على الأقل مرتّبة بالأفضلية.`;

@Injectable()
export class RecommendationService {
  private readonly logger = new Logger(RecommendationService.name);

  constructor(private readonly llmService: LlmService) {}

  async recommend(request: RecommendationRequest): Promise<RecommendationResult> {
    let userMessage = `التخصص: ${request.specialization}`;
    if (request.governorate) userMessage += `\nالمحافظة: ${request.governorate}`;
    userMessage += `\nالاستعجال: ${request.urgency}`;
    if (request.preferredDate) userMessage += `\nالتاريخ المفضل: ${request.preferredDate}`;
    if (request.insuranceProvider) userMessage += `\nالتأمين: ${request.insuranceProvider}`;
    if (request.patientAge) userMessage += `\nالعمر: ${request.patientAge}`;

    const messages: ChatMessage[] = [
      { role: 'user', content: userMessage },
    ];

    try {
      return await this.llmService.chatJSON<RecommendationResult>(
        messages,
        RECOMMENDATION_SYSTEM_PROMPT,
      );
    } catch (error: any) {
      this.logger.error(`Recommendation failed: ${error.message}`);
      const fallback: HospitalRecommendation = {
        hospitalName: 'Jordan University Hospital',
        hospitalNameAr: 'مستشفى الجامعة الأردنية',
        hospitalType: 'public',
        governorate: request.governorate || 'عمان',
        specialization: request.specialization,
        estimatedWaitMinutes: 120,
        matchScore: 0.5,
        reasoning: 'توصية افتراضية — تعذّرت التوصية الذكية',
      };
      return {
        recommendations: [fallback],
        bestMatch: fallback,
        totalOptions: 1,
      };
    }
  }
}
