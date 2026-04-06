import { db } from "../config/firebase.js";
import { AUTH_CONFIG } from "../config/constants.js";
import { v4 as uuidv4 } from "uuid";
import { FieldValue, Timestamp } from "firebase-admin/firestore";

const SESSIONS_COLLECTION = "sessions";

export interface Session {
  sessionId: string;
  userId: string;
  nationalId: string;
  refreshToken: string;
  deviceInfo: string;
  ipAddress: string;
  createdAt: Timestamp;
  expiresAt: Date;
  lastActivity: Timestamp;
  isActive: boolean;
}

/**
 * Create a new session for a user. Enforces MAX_SESSIONS limit
 * by evicting the oldest session when the cap is reached.
 */
export async function createSession(
  userId: string,
  nationalId: string,
  deviceInfo: string,
  ipAddress: string,
): Promise<{ sessionId: string; refreshToken: string }> {
  const sessionId = uuidv4();
  const refreshToken = uuidv4();
  const expiresAt = new Date(Date.now() + AUTH_CONFIG.REFRESH_TOKEN_EXPIRY_DAYS * 24 * 60 * 60 * 1000);

  // Enforce max sessions — evict oldest if at capacity
  const existingSessions = await db
    .collection(SESSIONS_COLLECTION)
    .where("userId", "==", userId)
    .where("isActive", "==", true)
    .orderBy("createdAt", "asc")
    .get();

  const batch = db.batch();

  if (existingSessions.size >= AUTH_CONFIG.MAX_ACTIVE_SESSIONS) {
    const sessionsToRemove = existingSessions.size - AUTH_CONFIG.MAX_ACTIVE_SESSIONS + 1;
    for (let i = 0; i < sessionsToRemove; i++) {
      batch.update(existingSessions.docs[i].ref, { isActive: false });
    }
  }

  const sessionRef = db.collection(SESSIONS_COLLECTION).doc(sessionId);
  batch.set(sessionRef, {
    sessionId,
    userId,
    nationalId,
    refreshToken,
    deviceInfo: sanitizeDeviceInfo(deviceInfo),
    ipAddress,
    createdAt: FieldValue.serverTimestamp(),
    expiresAt,
    lastActivity: FieldValue.serverTimestamp(),
    isActive: true,
  });

  await batch.commit();

  return { sessionId, refreshToken };
}

/**
 * Validate a refresh token and return the associated session.
 */
export async function validateRefreshToken(
  refreshToken: string,
): Promise<Session | null> {
  const snapshot = await db
    .collection(SESSIONS_COLLECTION)
    .where("refreshToken", "==", refreshToken)
    .where("isActive", "==", true)
    .limit(1)
    .get();

  if (snapshot.empty) return null;

  const session = snapshot.docs[0].data() as Session;

  // Check expiry
  if (new Date(session.expiresAt as unknown as string) < new Date()) {
    await snapshot.docs[0].ref.update({ isActive: false });
    return null;
  }

  // Update last activity
  await snapshot.docs[0].ref.update({
    lastActivity: FieldValue.serverTimestamp(),
  });

  return session;
}

/**
 * Rotate a refresh token (issue new token, invalidate old).
 */
export async function rotateRefreshToken(
  oldRefreshToken: string,
): Promise<{ newRefreshToken: string; sessionId: string } | null> {
  const snapshot = await db
    .collection(SESSIONS_COLLECTION)
    .where("refreshToken", "==", oldRefreshToken)
    .where("isActive", "==", true)
    .limit(1)
    .get();

  if (snapshot.empty) return null;

  const newRefreshToken = uuidv4();
    const newExpiry = new Date(Date.now() + AUTH_CONFIG.REFRESH_TOKEN_EXPIRY_DAYS * 24 * 60 * 60 * 1000);
  const docRef = snapshot.docs[0].ref;
  const sessionId = snapshot.docs[0].data().sessionId;

  await docRef.update({
    refreshToken: newRefreshToken,
    expiresAt: newExpiry,
    lastActivity: FieldValue.serverTimestamp(),
  });

  return { newRefreshToken, sessionId };
}

/**
 * Revoke a specific session.
 */
export async function revokeSession(sessionId: string): Promise<void> {
  await db.collection(SESSIONS_COLLECTION).doc(sessionId).update({
    isActive: false,
  });
}

/**
 * Revoke all sessions for a user (e.g., on password change or security event).
 */
export async function revokeAllUserSessions(userId: string): Promise<number> {
  const snapshot = await db
    .collection(SESSIONS_COLLECTION)
    .where("userId", "==", userId)
    .where("isActive", "==", true)
    .get();

  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.update(doc.ref, { isActive: false });
  });

  await batch.commit();
  return snapshot.size;
}

/**
 * Get all active sessions for a user.
 */
export async function getUserSessions(
  userId: string,
): Promise<Session[]> {
  const snapshot = await db
    .collection(SESSIONS_COLLECTION)
    .where("userId", "==", userId)
    .where("isActive", "==", true)
    .orderBy("lastActivity", "desc")
    .get();

  return snapshot.docs.map((doc) => doc.data() as Session);
}

function sanitizeDeviceInfo(info: string): string {
  if (!info || typeof info !== "string") return "unknown";
  return info.substring(0, 500).replace(/[<>]/g, "");
}
