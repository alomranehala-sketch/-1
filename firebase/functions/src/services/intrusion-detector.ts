import { db } from "../config/firebase.js";
import { logAudit } from "./audit-logger.js";
import { revokeAllUserSessions } from "./session-manager.js";
import { FieldValue, Timestamp } from "firebase-admin/firestore";

const INTRUSION_COLLECTION = "intrusion_events";

interface IntrusionEvent {
  nationalId: string;
  eventType: IntrusionType;
  ipAddress: string;
  severity: "low" | "medium" | "high" | "critical";
  details: Record<string, unknown>;
  timestamp: Timestamp;
  resolved: boolean;
}

type IntrusionType =
  | "brute_force"
  | "credential_stuffing"
  | "impossible_travel"
  | "unusual_device"
  | "mass_failed_logins"
  | "session_hijack_attempt";

// Thresholds
const BRUTE_FORCE_THRESHOLD = 10; // failed attempts in 15 min
const CREDENTIAL_STUFFING_IPS = 5; // same national ID from 5+ IPs in 1 hour
const MASS_FAILED_WINDOW_MS = 60 * 60 * 1000; // 1 hour

/**
 * Analyze a failed login for intrusion patterns.
 */
export async function analyzeFailedLogin(
  nationalId: string,
  ipAddress: string,
  userAgent: string,
): Promise<void> {
  try {
    await Promise.all([
      detectBruteForce(nationalId, ipAddress, userAgent),
      detectCredentialStuffing(nationalId, ipAddress, userAgent),
    ]);
  } catch (err) {
    console.error("Intrusion analysis error:", err);
  }
}

/**
 * Detect brute force: many failed logins from a single IP in a short window.
 */
async function detectBruteForce(
  nationalId: string,
  ipAddress: string,
  userAgent: string,
): Promise<void> {
  const since = new Date(Date.now() - 15 * 60 * 1000); // 15 minutes

  const snapshot = await db
    .collection("audit_logs")
    .where("nationalId", "==", nationalId)
    .where("action", "==", "login_failed")
    .where("ipAddress", "==", ipAddress)
    .where("timestamp", ">=", since)
    .get();

  if (snapshot.size >= BRUTE_FORCE_THRESHOLD) {
    await recordIntrusion(nationalId, "brute_force", ipAddress, "high", {
      failedAttempts: snapshot.size,
      windowMinutes: 15,
      userAgent,
    });

    // Auto-remediate: revoke all sessions for this user
    const userSnapshot = await db
      .collection("users")
      .where("nationalId", "==", nationalId)
      .limit(1)
      .get();

    if (!userSnapshot.empty) {
      const userId = userSnapshot.docs[0].id;
      await revokeAllUserSessions(userId);
      await logAudit(
        nationalId,
        "intrusion_detected",
        ipAddress,
        userAgent,
        true,
        userId,
        { type: "brute_force", sessionsRevoked: true },
      );
    }
  }
}

/**
 * Detect credential stuffing: same national ID targeted from many different IPs.
 */
async function detectCredentialStuffing(
  nationalId: string,
  ipAddress: string,
  userAgent: string,
): Promise<void> {
  const since = new Date(Date.now() - MASS_FAILED_WINDOW_MS);

  const snapshot = await db
    .collection("audit_logs")
    .where("nationalId", "==", nationalId)
    .where("action", "==", "login_failed")
    .where("timestamp", ">=", since)
    .get();

  // Count distinct IPs
  const uniqueIps = new Set(snapshot.docs.map((doc) => doc.data().ipAddress));

  if (uniqueIps.size >= CREDENTIAL_STUFFING_IPS) {
    await recordIntrusion(nationalId, "credential_stuffing", ipAddress, "critical", {
      uniqueIpCount: uniqueIps.size,
      totalAttempts: snapshot.size,
      windowHours: 1,
      userAgent,
    });
  }
}

/**
 * Record an intrusion event to Firestore.
 */
async function recordIntrusion(
  nationalId: string,
  eventType: IntrusionType,
  ipAddress: string,
  severity: IntrusionEvent["severity"],
  details: Record<string, unknown>,
): Promise<void> {
  // Prevent duplicate alerts within 5 minutes
  const recentCheck = new Date(Date.now() - 5 * 60 * 1000);
  const existing = await db
    .collection(INTRUSION_COLLECTION)
    .where("nationalId", "==", nationalId)
    .where("eventType", "==", eventType)
    .where("timestamp", ">=", recentCheck)
    .limit(1)
    .get();

  if (!existing.empty) return;

  await db.collection(INTRUSION_COLLECTION).add({
    nationalId,
    eventType,
    ipAddress,
    severity,
    details,
    timestamp: FieldValue.serverTimestamp(),
    resolved: false,
  });
}

/**
 * Get unresolved intrusion events (for admin dashboard).
 */
export async function getUnresolvedIntrusions(
  limit = 100,
): Promise<IntrusionEvent[]> {
  const snapshot = await db
    .collection(INTRUSION_COLLECTION)
    .where("resolved", "==", false)
    .orderBy("timestamp", "desc")
    .limit(limit)
    .get();

  return snapshot.docs.map((doc) => ({ ...doc.data() } as IntrusionEvent));
}
