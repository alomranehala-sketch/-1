export const AUTH_CONFIG = {
  // Bcrypt cost factor (higher = slower = more secure)
  BCRYPT_ROUNDS: 12,

  // Custom token expiry (Firebase custom tokens are valid for max 1 hour)
  CUSTOM_TOKEN_EXPIRY_SECONDS: 3600,

  // Refresh token expiry (30 days)
  REFRESH_TOKEN_EXPIRY_DAYS: 30,

  // Session limits
  MAX_ACTIVE_SESSIONS: 5, // max devices per user

  // Rate limiting
  MAX_LOGIN_ATTEMPTS: 5,       // per window
  RATE_LIMIT_WINDOW_MS: 900000, // 15 minutes in ms
  LOCKOUT_DURATION_MS: 1800000, // 30 minutes lockout after max attempts

  // National ID format: exactly 10 digits (Jordanian)
  NATIONAL_ID_REGEX: /^\d{10}$/,

  // Personal number: minimum 6 chars, must include number + letter
  PERSONAL_NUMBER_MIN_LENGTH: 6,
  PERSONAL_NUMBER_MAX_LENGTH: 64,
} as const;

export const ROLES = {
  PATIENT: "patient",
  DOCTOR: "doctor",
  ADMIN: "admin",
  NURSE: "nurse",
  PHARMACIST: "pharmacist",
} as const;

export type UserRole = typeof ROLES[keyof typeof ROLES];
