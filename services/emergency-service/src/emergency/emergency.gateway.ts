import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';

/**
 * WebSocket Gateway for real-time emergency alerts.
 * 
 * Events:
 *   Client -> Server:
 *     - 'join'             : Join user's alert room (data: { userId })
 *     - 'join-monitoring'  : Join monitoring room (for doctors/admins)
 *     - 'acknowledge'      : Acknowledge an alert (data: { alertId, userId })
 * 
 *   Server -> Client:
 *     - 'new-alert'        : New emergency alert created
 *     - 'alert-update'     : Alert status changed
 *     - 'alert-acknowledged': Alert was acknowledged
 *     - 'alert-resolved'   : Alert was resolved
 */
@WebSocketGateway({
  cors: {
    origin: '*',
  },
  namespace: '/emergency',
})
export class EmergencyGateway implements OnGatewayConnection, OnGatewayDisconnect {
  private readonly logger = new Logger(EmergencyGateway.name);

  @WebSocketServer()
  server: Server;

  // Track connected users -> socket mapping
  private connectedUsers = new Map<string, Set<string>>(); // userId -> Set<socketId>

  handleConnection(client: Socket) {
    this.logger.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
    // Remove from all user rooms
    for (const [userId, sockets] of this.connectedUsers.entries()) {
      if (sockets.delete(client.id) && sockets.size === 0) {
        this.connectedUsers.delete(userId);
      }
    }
  }

  /**
   * User joins their personal alert room
   */
  @SubscribeMessage('join')
  handleJoin(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { userId: string },
  ) {
    const { userId } = data;
    client.join(`user:${userId}`);

    if (!this.connectedUsers.has(userId)) {
      this.connectedUsers.set(userId, new Set());
    }
    this.connectedUsers.get(userId)!.add(client.id);

    this.logger.log(`User ${userId} joined alert room`);
    return { event: 'joined', data: { userId, room: `user:${userId}` } };
  }

  /**
   * Doctor/Admin joins monitoring room to receive all alerts
   */
  @SubscribeMessage('join-monitoring')
  handleJoinMonitoring(@ConnectedSocket() client: Socket) {
    client.join('monitoring');
    this.logger.log(`Client ${client.id} joined monitoring room`);
    return { event: 'joined-monitoring', data: { room: 'monitoring' } };
  }

  /**
   * Broadcast new emergency alert
   */
  broadcastNewAlert(alert: any) {
    // Send to the user's room
    this.server.to(`user:${alert.userId}`).emit('new-alert', alert);
    // Send to monitoring room (doctors/admins)
    this.server.to('monitoring').emit('new-alert', alert);
    this.logger.warn(`EMERGENCY ALERT broadcast: ${alert.id} - Severity: ${alert.severity}`);
  }

  /**
   * Broadcast alert status update
   */
  broadcastAlertUpdate(alert: any) {
    this.server.to(`user:${alert.userId}`).emit('alert-update', alert);
    this.server.to('monitoring').emit('alert-update', alert);
  }

  /**
   * Notify that alert was acknowledged
   */
  broadcastAlertAcknowledged(alert: any) {
    this.server.to(`user:${alert.userId}`).emit('alert-acknowledged', {
      alertId: alert.id,
      acknowledgedBy: alert.acknowledgedBy,
      acknowledgedAt: alert.acknowledgedAt,
    });
    this.server.to('monitoring').emit('alert-acknowledged', alert);
  }

  /**
   * Notify that alert was resolved
   */
  broadcastAlertResolved(alert: any) {
    this.server.to(`user:${alert.userId}`).emit('alert-resolved', {
      alertId: alert.id,
      resolvedAt: alert.resolvedAt,
      resolvedNotes: alert.resolvedNotes,
    });
    this.server.to('monitoring').emit('alert-resolved', alert);
  }

  /**
   * Check if a user is currently connected
   */
  isUserOnline(userId: string): boolean {
    return this.connectedUsers.has(userId) && this.connectedUsers.get(userId)!.size > 0;
  }

  /**
   * Get count of online users
   */
  getOnlineUserCount(): number {
    return this.connectedUsers.size;
  }
}
