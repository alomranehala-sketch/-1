import { db } from "../config/firebase.js";
import { FieldValue, Timestamp } from "firebase-admin/firestore";

const AUDIT_LOGS_COLLECTION = "audit_logs";

export type AuditAction =
  | "register"
  | "login_success"
  | "login_failed"
  | "logout"
  | "token_refresh"
  | "session_revoked"
  | "all_sessions_revoked"
  | "account_locked"
  | "password_changed"
  | "intrusion_detected"
  | "national_id_verified";

export interface AuditEntry {
  userId?: string;
  nationalId: string;
  action: AuditAction;
  ipAddress: string;
  userAgent: string;
  metadata?: Record<string, unknown>;
  timestamp: Timestamp;
  success: boolean;
}

/**
 * Log an auth action to Firestore audit_logs collection.
 * Non-blocking — errors are caught internally.
 */
export async function logAudit(
  nationalId: string,
  action: AuditAction,
  ipAddress: string,
  userAgent: string,
  success: boolean,
  userId?: string,
  metadata?: Record<string, unknown>,
): Promise<void> {
  try {
    await db.collection(AUDIT_LOGS_COLLECTION).add({
      userId: userId || null,
      nationalId,
      action,
      ipAddress: ipAddress || "unknown",
      userAgent: sanitizeUserAgent(userAgent),
      metadata: metadata || {},
      timestamp: FieldValue.serverTimestamp(),
      success,
    });
  } catch (err) {
    // Audit logging should never block auth flow
    console.error("Audit log write failed:", err);
  }
}

/**
 * Retrieve recent audit logs for a national ID.
 */
export async function getAuditLogs(
  nationalId: string,
  limit = 50,
): Promise<AuditEntry[]> {
  const snapshot = await db
    .collection(AUDIT_LOGS_COLLECTION)
    .where("nationalId", "==", nationalId)
    .orderBy("timestamp", "desc")
    .limit(limit)
    .get();

  return snapshot.docs.map((doc) => doc.data() as AuditEntry);
}

/**
 * Get failed login attempts for a national ID within a time range.
 */
export async function getRecentFailedAttempts(
  nationalId: string,
  windowMs: number,
): Promise<number> {
  const since = new Date(Date.now() - windowMs);

  const snapshot = await db
    .collection(AUDIT_LOGS_COLLECTION)
    .where("nationalId", "==", nationalId)
    .where("action", "==", "login_failed")
    .where("timestamp", ">=", since)
    .get();

  return snapshot.size;
}

function sanitizeUserAgent(ua: string): string {
  if (!ua || typeof ua !== "string") return "unknown";
  return ua.substring(0, 1000).replace(/[<>]/g, "");
}
