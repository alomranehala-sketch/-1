import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosInstance } from 'axios';

export enum AgentAction {
  BOOK_APPOINTMENT = 'book_appointment',
  CANCEL_APPOINTMENT = 'cancel_appointment',
  RESCHEDULE_APPOINTMENT = 'reschedule_appointment',
  FETCH_MEDICAL_DATA = 'fetch_medical_data',
  SEND_NOTIFICATION = 'send_notification',
  FETCH_LAB_RESULTS = 'fetch_lab_results',
  UPDATE_HEALTH_RECORD = 'update_health_record',
  TRIGGER_EMERGENCY = 'trigger_emergency',
}

export interface AgentTask {
  action: AgentAction;
  userId: string;
  params: Record<string, any>;
}

export interface AgentResult {
  action: AgentAction;
  status: 'completed' | 'failed' | 'partial';
  data: Record<string, any>;
  message: string;
  messageAr: string;
  executionTimeMs: number;
}

@Injectable()
export class AgentService {
  private readonly logger = new Logger(AgentService.name);
  private readonly httpClients: Record<string, AxiosInstance> = {};

  constructor(private readonly configService: ConfigService) {
    // Initialize HTTP clients for each internal microservice
    const services = {
      auth: this.configService.get('AUTH_SERVICE_URL', 'http://auth-service:3001'),
      user: this.configService.get('USER_SERVICE_URL', 'http://user-service:3003'),
      health: this.configService.get('HEALTH_SERVICE_URL', 'http://health-service:3004'),
      notification: this.configService.get('NOTIFICATION_SERVICE_URL', 'http://notification-service:3006'),
      emergency: this.configService.get('EMERGENCY_SERVICE_URL', 'http://emergency-service:3002'),
    };

    for (const [name, baseURL] of Object.entries(services)) {
      this.httpClients[name] = axios.create({
        baseURL,
        timeout: 10000,
        headers: { 'Content-Type': 'application/json' },
      });
    }
  }

  async execute(task: AgentTask): Promise<AgentResult> {
    const start = Date.now();
    this.logger.log(`Agent executing: ${task.action} for user ${task.userId}`);

    try {
      switch (task.action) {
        case AgentAction.BOOK_APPOINTMENT:
          return await this.bookAppointment(task, start);

        case AgentAction.CANCEL_APPOINTMENT:
          return await this.cancelAppointment(task, start);

        case AgentAction.RESCHEDULE_APPOINTMENT:
          return await this.rescheduleAppointment(task, start);

        case AgentAction.FETCH_MEDICAL_DATA:
          return await this.fetchMedicalData(task, start);

        case AgentAction.SEND_NOTIFICATION:
          return await this.sendNotification(task, start);

        case AgentAction.FETCH_LAB_RESULTS:
          return await this.fetchLabResults(task, start);

        case AgentAction.TRIGGER_EMERGENCY:
          return await this.triggerEmergency(task, start);

        case AgentAction.UPDATE_HEALTH_RECORD:
          return await this.updateHealthRecord(task, start);

        default:
          return {
            action: task.action,
            status: 'failed',
            data: {},
            message: `Unknown action: ${task.action}`,
            messageAr: `إجراء غير معروف: ${task.action}`,
            executionTimeMs: Date.now() - start,
          };
      }
    } catch (error: any) {
      this.logger.error(`Agent action failed: ${task.action} - ${error.message}`);
      return {
        action: task.action,
        status: 'failed',
        data: { error: error.message },
        message: `Action failed: ${error.message}`,
        messageAr: 'فشل تنفيذ الإجراء — يرجى المحاولة لاحقاً',
        executionTimeMs: Date.now() - start,
      };
    }
  }

  private async bookAppointment(task: AgentTask, start: number): Promise<AgentResult> {
    const { specialization, hospitalId, doctorId, scheduledAt, reason } = task.params;

    const response = await this.httpClients.health.post('/api/v1/appointments', {
      patientId: task.userId,
      specialization,
      hospitalId,
      doctorId,
      scheduledAt,
      reason,
    }, {
      headers: { 'x-user-id': task.userId },
    });

    return {
      action: AgentAction.BOOK_APPOINTMENT,
      status: 'completed',
      data: response.data,
      message: `Appointment booked successfully at ${scheduledAt}`,
      messageAr: `تم حجز الموعد بنجاح في ${scheduledAt}`,
      executionTimeMs: Date.now() - start,
    };
  }

  private async cancelAppointment(task: AgentTask, start: number): Promise<AgentResult> {
    const { appointmentId } = task.params;

    const response = await this.httpClients.health.patch(
      `/api/v1/appointments/${appointmentId}/cancel`,
      {},
      { headers: { 'x-user-id': task.userId } },
    );

    return {
      action: AgentAction.CANCEL_APPOINTMENT,
      status: 'completed',
      data: response.data,
      message: 'Appointment cancelled successfully',
      messageAr: 'تم إلغاء الموعد بنجاح',
      executionTimeMs: Date.now() - start,
    };
  }

  private async rescheduleAppointment(task: AgentTask, start: number): Promise<AgentResult> {
    const { appointmentId, newDate } = task.params;

    const response = await this.httpClients.health.patch(
      `/api/v1/appointments/${appointmentId}/reschedule`,
      { scheduledAt: newDate },
      { headers: { 'x-user-id': task.userId } },
    );

    return {
      action: AgentAction.RESCHEDULE_APPOINTMENT,
      status: 'completed',
      data: response.data,
      message: `Appointment rescheduled to ${newDate}`,
      messageAr: `تم تأجيل الموعد إلى ${newDate}`,
      executionTimeMs: Date.now() - start,
    };
  }

  private async fetchMedicalData(task: AgentTask, start: number): Promise<AgentResult> {
    const { dataType } = task.params;

    const response = await this.httpClients.health.get(
      `/api/v1/health-records`,
      {
        headers: { 'x-user-id': task.userId },
        params: { type: dataType, limit: 10 },
      },
    );

    return {
      action: AgentAction.FETCH_MEDICAL_DATA,
      status: 'completed',
      data: response.data,
      message: 'Medical data retrieved successfully',
      messageAr: 'تم جلب البيانات الطبية بنجاح',
      executionTimeMs: Date.now() - start,
    };
  }

  private async fetchLabResults(task: AgentTask, start: number): Promise<AgentResult> {
    const response = await this.httpClients.health.get(
      '/api/v1/health-records',
      {
        headers: { 'x-user-id': task.userId },
        params: { type: 'lab_result', limit: 5 },
      },
    );

    return {
      action: AgentAction.FETCH_LAB_RESULTS,
      status: 'completed',
      data: response.data,
      message: 'Lab results retrieved',
      messageAr: 'تم جلب نتائج التحاليل',
      executionTimeMs: Date.now() - start,
    };
  }

  private async sendNotification(task: AgentTask, start: number): Promise<AgentResult> {
    const { type, title, body, data } = task.params;

    const response = await this.httpClients.notification.post('/api/v1/notifications', {
      userId: task.userId,
      type: type || 'push',
      title,
      body,
      data: data || {},
    });

    return {
      action: AgentAction.SEND_NOTIFICATION,
      status: 'completed',
      data: response.data,
      message: 'Notification sent',
      messageAr: 'تم إرسال الإشعار',
      executionTimeMs: Date.now() - start,
    };
  }

  private async triggerEmergency(task: AgentTask, start: number): Promise<AgentResult> {
    const { severity, message, locationLat, locationLng, vitals } = task.params;

    const response = await this.httpClients.emergency.post('/api/v1/emergency/alerts', {
      userId: task.userId,
      severity: severity || 'high',
      alertType: 'ai_detected',
      message,
      locationLat,
      locationLng,
      vitalsSnapshot: vitals || {},
    });

    // Also send urgent notification
    await this.httpClients.notification.post('/api/v1/notifications', {
      userId: task.userId,
      type: 'push',
      title: '🚨 تنبيه طوارئ',
      body: message,
      severity: 'emergency',
      data: { emergencyId: response.data?.data?.id },
    }).catch(() => {}); // non-blocking

    return {
      action: AgentAction.TRIGGER_EMERGENCY,
      status: 'completed',
      data: response.data,
      message: 'Emergency alert triggered',
      messageAr: 'تم إطلاق تنبيه الطوارئ',
      executionTimeMs: Date.now() - start,
    };
  }

  private async updateHealthRecord(task: AgentTask, start: number): Promise<AgentResult> {
    const { recordData } = task.params;

    const response = await this.httpClients.health.post(
      '/api/v1/health-records',
      recordData,
      { headers: { 'x-user-id': task.userId } },
    );

    return {
      action: AgentAction.UPDATE_HEALTH_RECORD,
      status: 'completed',
      data: response.data,
      message: 'Health record updated successfully',
      messageAr: 'تم تحديث السجل الطبي بنجاح',
      executionTimeMs: Date.now() - start,
    };
  }
}
