import { Injectable, Logger } from '@nestjs/common';
import { LlmService, ChatMessage } from '../llm/llm.service';

export interface PredictionRequest {
  type: 'disease_spread' | 'hospital_load' | 'seasonal_trends' | 'resource_demand';
  governorate?: string;
  timeframeDays?: number;
  historicalData?: Record<string, any>;
}

export interface PredictionResult {
  type: string;
  prediction: Record<string, any>;
  confidence: number;
  riskLevel: 'low' | 'medium' | 'high' | 'critical';
  insights: string[];
  recommendations: string[];
  dataPoints: Array<{ label: string; value: number }>;
}

const PREDICTION_SYSTEM_PROMPT = `أنت نموذج تنبؤ وتحليل أنماط في نظام صحي أردني حكومي. مهمتك:
1. تحليل أنماط انتشار الأمراض
2. توقع الحمل على المستشفيات
3. تحليل الاتجاهات الموسمية
4. توقع الطلب على الموارد الطبية

أجب فقط بـ JSON:
{
  "type": "نوع التنبؤ",
  "prediction": { "key": "value" },
  "confidence": 0.0-1.0,
  "riskLevel": "low|medium|high|critical",
  "insights": ["ملاحظة 1 بالعربي", "ملاحظة 2"],
  "recommendations": ["توصية 1 بالعربي", "توصية 2"],
  "dataPoints": [{"label": "يناير", "value": 120}]
}

ملاحظة: استخدم بيانات واقعية للأردن عندما تكون متاحة.`;

@Injectable()
export class PredictionService {
  private readonly logger = new Logger(PredictionService.name);

  constructor(private readonly llmService: LlmService) {}

  async predict(request: PredictionRequest): Promise<PredictionResult> {
    let userMessage = `نوع التنبؤ: ${request.type}`;
    if (request.governorate) userMessage += `\nالمحافظة: ${request.governorate}`;
    if (request.timeframeDays) userMessage += `\nالفترة الزمنية: ${request.timeframeDays} يوم`;
    if (request.historicalData) {
      userMessage += `\nبيانات تاريخية: ${JSON.stringify(request.historicalData)}`;
    }

    const messages: ChatMessage[] = [
      { role: 'user', content: userMessage },
    ];

    try {
      return await this.llmService.chatJSON<PredictionResult>(messages, PREDICTION_SYSTEM_PROMPT);
    } catch (error: any) {
      this.logger.error(`Prediction failed: ${error.message}`);
      return {
        type: request.type,
        prediction: {},
        confidence: 0,
        riskLevel: 'medium',
        insights: ['تعذّر التحليل — بيانات غير كافية'],
        recommendations: ['يرجى المراجعة يدوياً'],
        dataPoints: [],
      };
    }
  }
}
