import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK (uses default service account in Cloud Functions)
admin.initializeApp();

export const db = admin.firestore();
export const auth = admin.auth();

// Firestore collection references
export const COLLECTIONS = {
  USERS: "users",
  SESSIONS: "sessions",
  AUDIT_LOGS: "audit_logs",
  RATE_LIMITS: "rate_limits",
  LOCKOUTS: "lockouts",
} as const;
