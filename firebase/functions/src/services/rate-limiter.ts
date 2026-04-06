import { db } from "../config/firebase.js";
import { AUTH_CONFIG } from "../config/constants.js";
import { FieldValue, Timestamp } from "firebase-admin/firestore";

const RATE_LIMITS_COLLECTION = "rate_limits";

interface RateLimitDoc {
  attempts: number;
  firstAttempt: Timestamp;
  lockedUntil?: Timestamp;
}

/**
 * Check if a national ID is currently rate-limited or locked out.
 * Returns { allowed: true } if the request can proceed,
 * or { allowed: false, retryAfter } if blocked.
 */
export async function checkRateLimit(
  nationalId: string,
): Promise<{ allowed: boolean; retryAfter?: number; remainingAttempts?: number }> {
  const docRef = db.collection(RATE_LIMITS_COLLECTION).doc(nationalId);
  const doc = await docRef.get();

  if (!doc.exists) {
    return { allowed: true, remainingAttempts: AUTH_CONFIG.MAX_LOGIN_ATTEMPTS };
  }

  const data = doc.data() as RateLimitDoc;
  const now = Date.now();

  // Check lockout
  if (data.lockedUntil) {
    const lockExpiry = data.lockedUntil.toMillis();
    if (now < lockExpiry) {
      const retryAfter = Math.ceil((lockExpiry - now) / 1000);
      return { allowed: false, retryAfter, remainingAttempts: 0 };
    }
    // Lockout expired — reset
    await docRef.delete();
    return { allowed: true, remainingAttempts: AUTH_CONFIG.MAX_LOGIN_ATTEMPTS };
  }

  // Check sliding window
  const windowStart = data.firstAttempt.toMillis();
  const windowEnd = windowStart + AUTH_CONFIG.RATE_LIMIT_WINDOW_MS;

  if (now > windowEnd) {
    // Window expired — reset
    await docRef.delete();
    return { allowed: true, remainingAttempts: AUTH_CONFIG.MAX_LOGIN_ATTEMPTS };
  }

  const remaining = AUTH_CONFIG.MAX_LOGIN_ATTEMPTS - data.attempts;
  if (remaining <= 0) {
    return { allowed: false, retryAfter: Math.ceil((windowEnd - now) / 1000), remainingAttempts: 0 };
  }

  return { allowed: true, remainingAttempts: remaining };
}

/**
 * Record a failed login attempt. If max attempts reached, apply lockout.
 */
export async function recordFailedAttempt(nationalId: string): Promise<void> {
  const docRef = db.collection(RATE_LIMITS_COLLECTION).doc(nationalId);

  await db.runTransaction(async (tx) => {
    const doc = await tx.get(docRef);

    if (!doc.exists) {
      tx.set(docRef, {
        attempts: 1,
        firstAttempt: FieldValue.serverTimestamp(),
      });
      return;
    }

    const data = doc.data() as RateLimitDoc;
    const now = Date.now();
    const windowStart = data.firstAttempt.toMillis();
    const windowEnd = windowStart + AUTH_CONFIG.RATE_LIMIT_WINDOW_MS;

    if (now > windowEnd) {
      // Window expired — start fresh
      tx.set(docRef, {
        attempts: 1,
        firstAttempt: FieldValue.serverTimestamp(),
      });
      return;
    }

    const newAttempts = data.attempts + 1;

    if (newAttempts >= AUTH_CONFIG.MAX_LOGIN_ATTEMPTS) {
      // Lock account
      const lockUntil = new Date(now + AUTH_CONFIG.LOCKOUT_DURATION_MS);
      tx.update(docRef, {
        attempts: newAttempts,
        lockedUntil: lockUntil,
      });
    } else {
      tx.update(docRef, { attempts: newAttempts });
    }
  });
}

/**
 * Clear rate limit record after a successful login.
 */
export async function clearRateLimit(nationalId: string): Promise<void> {
  await db.collection(RATE_LIMITS_COLLECTION).doc(nationalId).delete();
}
