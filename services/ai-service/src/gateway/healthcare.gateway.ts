import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { OrchestratorService, OrchestratorRequest } from '../orchestrator/orchestrator.service';
import {
  EventBusService,
  HealthcareEvent,
  PatientJourneyService,
  ContextAwareService,
  HospitalPerformanceService,
} from '../oriented-system';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
  namespace: '/ws',
})
export class HealthcareGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(HealthcareGateway.name);
  private connectedClients = new Map<string, { userId: string; connectedAt: Date }>();

  constructor(
    private readonly orchestratorService: OrchestratorService,
    private readonly eventBus: EventBusService,
    private readonly journeyService: PatientJourneyService,
    private readonly contextService: ContextAwareService,
    private readonly hospitalService: HospitalPerformanceService,
  ) {
    // Forward journey state changes to Socket.IO clients
    this.eventBus.on(HealthcareEvent.JOURNEY_STATE_CHANGED, (payload) => {
      this.server?.to(`user:${payload.userId}`).emit('journey:update', {
        previousState: payload.data.previousState,
        newState: payload.data.newState,
        action: payload.data.action,
        journeyData: payload.data.journeyData,
        timestamp: payload.timestamp,
      });
    });

    // Forward performance score updates
    this.eventBus.on(HealthcareEvent.PERFORMANCE_SCORE_UPDATED, (payload) => {
      this.server?.emit('hospital:score-update', {
        hospitalName: payload.data.hospitalName,
        overallScore: payload.data.overallScore,
        timestamp: payload.timestamp,
      });
    });
  }

  // ─── CONNECTION LIFECYCLE ─────────────────────────────────
  handleConnection(client: Socket) {
    const userId = client.handshake.query['userId'] as string || 'anonymous';
    this.connectedClients.set(client.id, { userId, connectedAt: new Date() });
    client.join(`user:${userId}`);

    this.logger.log(`Client connected: ${client.id} (user: ${userId}) — Total: ${this.connectedClients.size}`);

    client.emit('connected', {
      message: 'مرحبا بك في نظام نبض الصحي الذكي 👋',
      socketId: client.id,
      timestamp: new Date().toISOString(),
    });
  }

  handleDisconnect(client: Socket) {
    const info = this.connectedClients.get(client.id);
    this.connectedClients.delete(client.id);
    this.logger.log(`Client disconnected: ${client.id} (user: ${info?.userId}) — Total: ${this.connectedClients.size}`);
  }

  // ─── AI CHAT — Main orchestrator pipeline via Socket ──────
  @SubscribeMessage('chat:message')
  async handleChatMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { message: string; context?: Record<string, any> },
  ) {
    const clientInfo = this.connectedClients.get(client.id);
    const userId = clientInfo?.userId || 'anonymous';

    if (!data?.message?.trim()) {
      client.emit('chat:error', { error: 'الرسالة فارغة' });
      return;
    }

    this.logger.log(`[${userId}] chat:message → "${data.message.substring(0, 80)}"`);

    // Emit typing indicator
    client.emit('chat:typing', { isTyping: true });

    try {
      const request: OrchestratorRequest = {
        userId,
        message: data.message,
        context: data.context,
      };

      const result = await this.orchestratorService.process(request);

      client.emit('chat:typing', { isTyping: false });
      client.emit('chat:response', {
        intent: result.intent,
        priority: result.priority,
        action: result.action,
        message: result.responseMessageAr,
        messageEn: result.responseMessage,
        data: result.data,
        next_steps: result.next_steps,
        executionTimeMs: result.executionTimeMs,
        pipelineSteps: result.pipelineSteps,
        // Oriented System data
        journey: result.journey,
        hospitalRanking: result.hospitalRanking,
        toolsUsed: result.toolsUsed,
        timestamp: new Date().toISOString(),
      });
    } catch (error: any) {
      this.logger.error(`Chat error for ${userId}: ${error.message}`);
      client.emit('chat:typing', { isTyping: false });
      client.emit('chat:error', {
        error: 'حصل خطأ — يرجى المحاولة مرة أخرى',
        details: error.message,
      });
    }
  }

  // ─── EMERGENCY ALERT — broadcast to admins ────────────────
  @SubscribeMessage('emergency:alert')
  async handleEmergencyAlert(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { message: string; locationLat?: number; locationLng?: number },
  ) {
    const clientInfo = this.connectedClients.get(client.id);
    const userId = clientInfo?.userId || 'anonymous';

    this.logger.warn(`🚨 EMERGENCY from ${userId}: ${data.message}`);

    // Process through orchestrator as emergency
    try {
      const result = await this.orchestratorService.process({
        userId,
        message: `طوارئ: ${data.message}`,
        context: {
          locationLat: data.locationLat,
          locationLng: data.locationLng,
        },
      });

      // Respond to sender
      client.emit('emergency:response', {
        status: 'received',
        message: result.responseMessageAr,
        priority: result.priority,
      });

      // Broadcast to admin room
      this.server.to('role:admin').emit('emergency:broadcast', {
        userId,
        message: data.message,
        priority: 'emergency',
        location: { lat: data.locationLat, lng: data.locationLng },
        timestamp: new Date().toISOString(),
      });
    } catch (error: any) {
      client.emit('emergency:response', {
        status: 'error',
        message: 'تعذّر إرسال تنبيه الطوارئ — اتصل بـ 911',
      });
    }
  }

  // ─── NOTIFICATIONS — push to specific user ────────────────
  sendNotificationToUser(userId: string, notification: Record<string, any>) {
    this.server.to(`user:${userId}`).emit('notification', {
      ...notification,
      timestamp: new Date().toISOString(),
    });
  }

  // ─── APPOINTMENT UPDATE — real-time status ────────────────
  sendAppointmentUpdate(userId: string, appointment: Record<string, any>) {
    this.server.to(`user:${userId}`).emit('appointment:update', {
      ...appointment,
      timestamp: new Date().toISOString(),
    });
  }

  // ─── JOIN ROOM — for role-based broadcasting ──────────────
  @SubscribeMessage('room:join')
  handleJoinRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { room: string },
  ) {
    if (data?.room) {
      client.join(data.room);
      this.logger.log(`${client.id} joined room: ${data.room}`);
    }
  }

  // ─── PING/PONG — heartbeat check ─────────────────────────
  @SubscribeMessage('ping')
  handlePing(@ConnectedSocket() client: Socket) {
    client.emit('pong', { timestamp: new Date().toISOString() });
  }

  // ─── STATS — online users count ───────────────────────────
  @SubscribeMessage('stats:online')
  handleOnlineStats(@ConnectedSocket() client: Socket) {
    client.emit('stats:online', {
      onlineUsers: this.connectedClients.size,
      timestamp: new Date().toISOString(),
    });
  }

  // ─── JOURNEY — get patient journey state ──────────────────
  @SubscribeMessage('journey:status')
  handleJourneyStatus(@ConnectedSocket() client: Socket) {
    const clientInfo = this.connectedClients.get(client.id);
    const userId = clientInfo?.userId || 'anonymous';
    const journey = this.journeyService.getJourney(userId);
    const progress = this.journeyService.getProgress(userId);
    client.emit('journey:status', {
      state: journey.state,
      progressPercent: progress.progressPercent,
      step: progress.step,
      totalSteps: progress.totalSteps,
      data: journey.data,
      previousStates: journey.previousStates.slice(-5),
      timestamp: new Date().toISOString(),
    });
  }

  // ─── HOSPITALS — get performance ranking ──────────────────
  @SubscribeMessage('hospitals:ranking')
  handleHospitalRanking(@ConnectedSocket() client: Socket) {
    const ranking = this.hospitalService.getRanking();
    client.emit('hospitals:ranking', {
      ranking,
      timestamp: new Date().toISOString(),
    });
  }

  // ─── CONTEXT — update user location ───────────────────────
  @SubscribeMessage('context:location')
  handleLocationUpdate(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { lat: number; lng: number; governorate?: string },
  ) {
    const clientInfo = this.connectedClients.get(client.id);
    const userId = clientInfo?.userId || 'anonymous';
    this.contextService.updateLocation(userId, data.lat, data.lng, data.governorate);
    this.eventBus.emit(HealthcareEvent.LOCATION_UPDATED, userId, data);
    client.emit('context:updated', { field: 'location', timestamp: new Date().toISOString() });
  }
}
