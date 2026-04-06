// مسار الصحة الذكي - Shared constants across all microservices

export const SERVICE_PORTS = {
  API_GATEWAY: 3000,
  AUTH_SERVICE: 3001,
  EMERGENCY_SERVICE: 3002,
  USER_SERVICE: 3003,
  HEALTH_SERVICE: 3004,
  AI_SERVICE: 3005,
  NOTIFICATION_SERVICE: 3006,
  ADMIN_SERVICE: 3007,
} as const;

export const SERVICE_URLS = {
  AUTH_SERVICE: `http://auth-service:${SERVICE_PORTS.AUTH_SERVICE}`,
  EMERGENCY_SERVICE: `http://emergency-service:${SERVICE_PORTS.EMERGENCY_SERVICE}`,
  USER_SERVICE: `http://user-service:${SERVICE_PORTS.USER_SERVICE}`,
  HEALTH_SERVICE: `http://health-service:${SERVICE_PORTS.HEALTH_SERVICE}`,
  AI_SERVICE: `http://ai-service:${SERVICE_PORTS.AI_SERVICE}`,
  NOTIFICATION_SERVICE: `http://notification-service:${SERVICE_PORTS.NOTIFICATION_SERVICE}`,
  ADMIN_SERVICE: `http://admin-service:${SERVICE_PORTS.ADMIN_SERVICE}`,
} as const;

// ─── Jordanian Governorates ─────────────────────────────────────
export const GOVERNORATES = [
  'عمان', 'إربد', 'الزرقاء', 'المفرق', 'عجلون', 'جرش',
  'مادبا', 'البلقاء', 'الكرك', 'الطفيلة', 'معان', 'العقبة',
] as const;

// ─── Enums matching database ────────────────────────────────────

export enum UserRole {
  CITIZEN = 'citizen',
  DOCTOR = 'doctor',
  NURSE = 'nurse',
  HOSPITAL_ADMIN = 'hospital_admin',
  MOH_ADMIN = 'moh_admin',
  PHARMACIST = 'pharmacist',
  PARAMEDIC = 'paramedic',
}

export enum AuthProvider {
  OTP = 'otp',
  BIOMETRIC = 'biometric',
  NATIONAL_ID = 'national_id',
}

export enum AppointmentStatus {
  SCHEDULED = 'scheduled',
  CONFIRMED = 'confirmed',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
  NO_SHOW = 'no_show',
  RESCHEDULED = 'rescheduled',
}

export enum NotificationType {
  EMAIL = 'email',
  SMS = 'sms',
  PUSH = 'push',
  WHATSAPP = 'whatsapp',
}

export enum NotificationStatus {
  PENDING = 'pending',
  SENT = 'sent',
  FAILED = 'failed',
  READ = 'read',
}

export enum NotificationSeverity {
  INFO = 'info',
  WARNING = 'warning',
  CRITICAL = 'critical',
  EMERGENCY = 'emergency',
}

export enum EmergencySeverity {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  CRITICAL = 'critical',
}

export enum EmergencyStatus {
  ACTIVE = 'active',
  DISPATCHED = 'dispatched',
  ACKNOWLEDGED = 'acknowledged',
  RESOLVED = 'resolved',
  FALSE_ALARM = 'false_alarm',
}

export enum TrackingMood {
  EXCELLENT = 'excellent',
  GOOD = 'good',
  NEUTRAL = 'neutral',
  BAD = 'bad',
  TERRIBLE = 'terrible',
}

export enum ConversationStatus {
  ACTIVE = 'active',
  ARCHIVED = 'archived',
}

export enum HospitalType {
  PUBLIC = 'public',
  PRIVATE = 'private',
  MILITARY = 'military',
  UNIVERSITY = 'university',
}

export enum AgentType {
  PERSONAL = 'personal',
  HOSPITAL = 'hospital',
  GOVERNMENT = 'government',
}

export enum AgentActionStatus {
  PENDING = 'pending',
  EXECUTING = 'executing',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
}

export enum PrescriptionStatus {
  ACTIVE = 'active',
  DISPENSED = 'dispensed',
  EXPIRED = 'expired',
  CANCELLED = 'cancelled',
}

export enum FamilyLinkStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  REVOKED = 'revoked',
}

export enum TriageLevel {
  IMMEDIATE = 'immediate', // Red — life-threatening
  URGENT = 'urgent',       // Orange — serious
  DELAYED = 'delayed',     // Yellow — can wait
  MINOR = 'minor',         // Green — minor issues
  EXPECTANT = 'expectant', // Black — palliative
}

// ─── AI Scheduling Constants ────────────────────────────────────

export const PRIORITY_WEIGHTS = {
  SEVERITY: 0.35,        // medical condition severity
  WAIT_TIME: 0.20,       // how long patient has been waiting
  AGE_FACTOR: 0.10,      // elderly/children get priority
  CHRONIC_CONDITIONS: 0.15, // existing chronic diseases
  DISTANCE: 0.10,        // travel distance to hospital
  FAIRNESS: 0.10,        // fair distribution across patients
} as const;

export const MAX_PRIORITY_SCORE = 100;
export const AUTO_RESCHEDULE_THRESHOLD = 0.8; // reschedule if hospital load > 80%
