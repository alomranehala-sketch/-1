import { UserRole, AgentType, TriageLevel } from './constants';

// Standard API response wrapper
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  messageAr?: string; // Arabic message
  error?: string;
  statusCode: number;
  timestamp: string;
}

// Pagination
export interface PaginationParams {
  page: number;
  limit: number;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

// JWT Payload (enhanced for national system)
export interface JwtPayload {
  sub: string; // user id
  phone: string;
  nationalId?: string;
  role: UserRole;
  governorate?: string;
  iat?: number;
  exp?: number;
}

// Token response
export interface TokenResponse {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

// User
export interface UserDto {
  id: string;
  nationalId?: string;
  email?: string;
  phone: string;
  firstName: string;
  lastName: string;
  firstNameAr?: string;
  lastNameAr?: string;
  dateOfBirth?: string;
  gender?: string;
  avatarUrl?: string;
  role: UserRole;
  isActive: boolean;
  isPhoneVerified: boolean;
  isIdentityVerified: boolean;
  preferredLanguage: string;
  governorate?: string;
  bloodType?: string;
  insuranceProvider?: string;
  createdAt: string;
}

// Hospital
export interface HospitalDto {
  id: string;
  name: string;
  nameAr: string;
  type: string;
  governorate: string;
  city: string;
  locationLat?: number;
  locationLng?: number;
  totalBeds: number;
  availableBeds: number;
  icuBeds: number;
  availableIcuBeds: number;
  erCapacity: number;
  currentErLoad: number;
  specialties: string[];
  isActive: boolean;
  rating: number;
}

// Hospital Capacity (real-time)
export interface HospitalCapacityDto {
  hospitalId: string;
  availableBeds: number;
  availableIcuBeds: number;
  currentErLoad: number;
  erWaitMinutes: number;
  ventilatorsAvailable: number;
  staffOnDuty: Record<string, number>;
  snapshotAt: string;
}

// Health Record
export interface HealthRecordDto {
  id: string;
  userId: string;
  recordType: string;
  title: string;
  description?: string;
  fileUrl?: string;
  recordedBy?: string;
  recordedAt: string;
  metadata?: Record<string, any>;
  createdAt: string;
}

// Daily Tracking
export interface DailyTrackingDto {
  id: string;
  userId: string;
  trackingDate: string;
  heartRate?: number;
  bloodPressureSystolic?: number;
  bloodPressureDiastolic?: number;
  bloodSugar?: number;
  weight?: number;
  temperature?: number;
  oxygenSaturation?: number;
  stepsCount?: number;
  sleepHours?: number;
  waterIntakeMl?: number;
  caloriesConsumed?: number;
  mood?: string;
  notes?: string;
}

// Emergency Alert
export interface EmergencyAlertDto {
  id: string;
  userId: string;
  severity: string;
  status: string;
  alertType: string;
  message: string;
  locationLat?: number;
  locationLng?: number;
  vitalsSnapshot?: Record<string, any>;
  createdAt: string;
}

// AI Conversation
export interface ConversationDto {
  id: string;
  userId: string;
  title?: string;
  status: string;
  model: string;
  totalTokensUsed: number;
  createdAt: string;
}

export interface AIMessageDto {
  id: string;
  conversationId: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  tokensUsed: number;
  createdAt: string;
}

// AI Agent Action
export interface AgentActionDto {
  id: string;
  agentType: AgentType;
  userId?: string;
  actionType: string;
  status: string;
  inputData: Record<string, any>;
  decisionReasoning?: string;
  outputData?: Record<string, any>;
  confidenceScore?: number;
  executionTimeMs?: number;
  createdAt: string;
  completedAt?: string;
}

// Smart Scheduling
export interface SchedulingRequest {
  patientId: string;
  specialization: string;
  reason: string;
  governorate?: string;
  preferredDate?: string;
  isUrgent: boolean;
}

export interface SchedulingResult {
  appointmentId: string;
  hospitalId: string;
  hospitalName: string;
  doctorId: string;
  doctorName: string;
  scheduledAt: string;
  priorityScore: number;
  scoringFactors: Record<string, number>;
  triageLevel: TriageLevel;
  estimatedWaitMinutes: number;
}

// Prescription
export interface PrescriptionDto {
  id: string;
  patientId: string;
  doctorId: string;
  hospitalId?: string;
  medicationName: string;
  medicationNameAr?: string;
  dosage: string;
  dosageAr?: string;
  quantity: number;
  refillsAllowed: number;
  refillsUsed: number;
  instructions?: string;
  status: string;
  prescribedAt: string;
  expiresAt?: string;
  barcode?: string;
}

// Family Link
export interface FamilyLinkDto {
  id: string;
  guardianId: string;
  dependentId: string;
  relationship: string;
  status: string;
  permissions: string[];
  expiresAt?: string;
}

// Medical Wallet (QR offline)
export interface MedicalWalletData {
  userId: string;
  nationalId?: string;
  fullName: string;
  bloodType?: string;
  chronicConditions: string[];
  allergies: string[];
  currentMedications: string[];
  emergencyContacts: { name: string; phone: string; relationship: string }[];
  recentVitals?: Record<string, any>;
  generatedAt: string;
  expiresAt: string;
}

// Disease Surveillance
export interface DiseaseSurveillanceDto {
  id: string;
  diseaseCode: string;
  diseaseName: string;
  diseaseNameAr?: string;
  governorate: string;
  reportedCases: number;
  confirmedCases: number;
  recovered: number;
  deaths: number;
  trend: string;
  alertLevel: string;
  aiPrediction?: Record<string, any>;
  reportingPeriodStart: string;
  reportingPeriodEnd: string;
}
