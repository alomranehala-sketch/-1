import { onRequest } from "firebase-functions/v2/https";
import { db, auth } from "../config/firebase.js";
import { hashPersonalNumber, verifyPersonalNumber } from "../utils/crypto.js";
import {
  validateNationalId,
  validatePersonalNumber,
  validateFullName,
  validateRole,
  sanitizeInput,
} from "../utils/validators.js";
import { checkRateLimit, recordFailedAttempt, clearRateLimit } from "../services/rate-limiter.js";
import { createSession, rotateRefreshToken, revokeSession, revokeAllUserSessions, getUserSessions } from "../services/session-manager.js";
import { logAudit } from "../services/audit-logger.js";
import { analyzeFailedLogin } from "../services/intrusion-detector.js";
import { FieldValue } from "firebase-admin/firestore";

const USERS_COLLECTION = "users";

// ─── CORS + Request Helpers ───────────────────────────────────────────────

function getIp(req: any): string {
  return req.headers["x-forwarded-for"]?.split(",")[0]?.trim() || req.ip || "unknown";
}

function getUserAgent(req: any): string {
  return req.headers["user-agent"] || "unknown";
}

function jsonError(res: any, status: number, message: string, details?: Record<string, unknown>) {
  return res.status(status).json({ success: false, message, ...details });
}

function jsonSuccess(res: any, data: Record<string, unknown>, status = 200) {
  return res.status(status).json({ success: true, ...data });
}

// ─── REGISTER ─────────────────────────────────────────────────────────────

export const registerUser = onRequest(
  { cors: true, region: "me-west1" },
  async (req, res) => {
    if (req.method !== "POST") {
      return jsonError(res, 405, "Method not allowed");
    }

    const ip = getIp(req);
    const ua = getUserAgent(req);

    try {
      const { nationalId, personalNumber, fullName, fullNameAr, role, phone, governorate } = req.body;

      // ── Input Validation ──
      const idCheck = validateNationalId(nationalId);
      if (!idCheck.valid) return jsonError(res, 400, idCheck.error!);

      const pinCheck = validatePersonalNumber(personalNumber);
      if (!pinCheck.valid) return jsonError(res, 400, pinCheck.error!);

      const nameCheck = validateFullName(fullName);
      if (!nameCheck.valid) return jsonError(res, 400, nameCheck.error!);

      const roleCheck = validateRole(role || "citizen");
      if (!roleCheck.valid) return jsonError(res, 400, roleCheck.error!);

      const cleanNationalId = sanitizeInput(nationalId.trim());
      const cleanFullName = sanitizeInput(fullName.trim());
      const cleanFullNameAr = fullNameAr ? sanitizeInput(fullNameAr.trim()) : null;

      // ── Check Duplicate ──
      const existing = await db
        .collection(USERS_COLLECTION)
        .where("nationalId", "==", cleanNationalId)
        .limit(1)
        .get();

      if (!existing.empty) {
        return jsonError(res, 409, "هذا الرقم الوطني مسجل مسبقاً");
      }

      // ── Hash Password ──
      const hashedPin = await hashPersonalNumber(personalNumber);

      // ── Create Firebase Auth User ──
      const firebaseUser = await auth.createUser({
        uid: cleanNationalId,
        displayName: cleanFullName,
      });

      // ── Store in Firestore ──
      await db.collection(USERS_COLLECTION).doc(firebaseUser.uid).set({
        nationalId: cleanNationalId,
        personalNumberHash: hashedPin,
        fullName: cleanFullName,
        fullNameAr: cleanFullNameAr,
        role: role || "citizen",
        phone: phone ? sanitizeInput(phone.trim()) : null,
        governorate: governorate ? sanitizeInput(governorate.trim()) : null,
        isActive: true,
        isVerified: false,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        lastLogin: null,
      });

      // ── Set Custom Claims ──
      await auth.setCustomUserClaims(firebaseUser.uid, {
        role: role || "citizen",
        nationalId: cleanNationalId,
      });

      // ── Create Session ──
      const { sessionId, refreshToken } = await createSession(
        firebaseUser.uid,
        cleanNationalId,
        ua,
        ip,
      );

      // ── Generate Custom Token ──
      const customToken = await auth.createCustomToken(firebaseUser.uid, {
        role: role || "citizen",
        nationalId: cleanNationalId,
        sessionId,
      });

      // ── Audit Log ──
      await logAudit(cleanNationalId, "register", ip, ua, true, firebaseUser.uid);

      return jsonSuccess(res, {
        message: "تم إنشاء الحساب بنجاح",
        customToken,
        refreshToken,
        sessionId,
        user: {
          uid: firebaseUser.uid,
          nationalId: cleanNationalId,
          fullName: cleanFullName,
          role: role || "citizen",
        },
      }, 201);
    } catch (error: any) {
      console.error("Register error:", error);

      if (error.code === "auth/uid-already-exists") {
        return jsonError(res, 409, "هذا الرقم الوطني مسجل مسبقاً");
      }

      return jsonError(res, 500, "حدث خطأ أثناء إنشاء الحساب");
    }
  },
);

// ─── LOGIN ────────────────────────────────────────────────────────────────

export const loginUser = onRequest(
  { cors: true, region: "me-west1" },
  async (req, res) => {
    if (req.method !== "POST") {
      return jsonError(res, 405, "Method not allowed");
    }

    const ip = getIp(req);
    const ua = getUserAgent(req);

    try {
      const { nationalId, personalNumber } = req.body;

      // ── Input Validation ──
      const idCheck = validateNationalId(nationalId);
      if (!idCheck.valid) return jsonError(res, 400, idCheck.error!);

      const pinCheck = validatePersonalNumber(personalNumber);
      if (!pinCheck.valid) return jsonError(res, 400, pinCheck.error!);

      const cleanNationalId = sanitizeInput(nationalId.trim());

      // ── Rate Limit Check ──
      const rateCheck = await checkRateLimit(cleanNationalId);
      if (!rateCheck.allowed) {
        await logAudit(cleanNationalId, "login_failed", ip, ua, false, undefined, {
          reason: "rate_limited",
          retryAfter: rateCheck.retryAfter,
        });
        return jsonError(res, 429, "تم تجاوز عدد المحاولات المسموح. حاول مجدداً لاحقاً", {
          retryAfter: rateCheck.retryAfter,
        });
      }

      // ── Find User ──
      const userDoc = await db.collection(USERS_COLLECTION).doc(cleanNationalId).get();

      if (!userDoc.exists) {
        await recordFailedAttempt(cleanNationalId);
        await logAudit(cleanNationalId, "login_failed", ip, ua, false, undefined, {
          reason: "user_not_found",
        });
        // Generic message to prevent user enumeration
        return jsonError(res, 401, "الرقم الوطني أو الرقم الشخصي غير صحيح");
      }

      const userData = userDoc.data()!;

      // ── Check Account Status ──
      if (!userData.isActive) {
        await logAudit(cleanNationalId, "login_failed", ip, ua, false, userDoc.id, {
          reason: "account_disabled",
        });
        return jsonError(res, 403, "الحساب معطل. تواصل مع الدعم الفني");
      }

      // ── Verify Password ──
      const isValid = await verifyPersonalNumber(personalNumber, userData.personalNumberHash);

      if (!isValid) {
        await recordFailedAttempt(cleanNationalId);
        await logAudit(cleanNationalId, "login_failed", ip, ua, false, userDoc.id, {
          reason: "invalid_password",
        });
        await analyzeFailedLogin(cleanNationalId, ip, ua);

        const updatedRate = await checkRateLimit(cleanNationalId);
        return jsonError(res, 401, "الرقم الوطني أو الرقم الشخصي غير صحيح", {
          remainingAttempts: updatedRate.remainingAttempts,
        });
      }

      // ── Success: Clear Rate Limit ──
      await clearRateLimit(cleanNationalId);

      // ── Create Session ──
      const { sessionId, refreshToken } = await createSession(
        userDoc.id,
        cleanNationalId,
        ua,
        ip,
      );

      // ── Generate Custom Token ──
      const customToken = await auth.createCustomToken(userDoc.id, {
        role: userData.role,
        nationalId: cleanNationalId,
        sessionId,
      });

      // ── Update Last Login ──
      await userDoc.ref.update({
        lastLogin: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      // ── Audit Log ──
      await logAudit(cleanNationalId, "login_success", ip, ua, true, userDoc.id, {
        sessionId,
      });

      return jsonSuccess(res, {
        message: "تم تسجيل الدخول بنجاح",
        customToken,
        refreshToken,
        sessionId,
        user: {
          uid: userDoc.id,
          nationalId: cleanNationalId,
          fullName: userData.fullName,
          fullNameAr: userData.fullNameAr,
          role: userData.role,
          isVerified: userData.isVerified,
        },
      });
    } catch (error: any) {
      console.error("Login error:", error);
      return jsonError(res, 500, "حدث خطأ أثناء تسجيل الدخول");
    }
  },
);

// ─── REFRESH TOKEN ────────────────────────────────────────────────────────

export const refreshAuthToken = onRequest(
  { cors: true, region: "me-west1" },
  async (req, res) => {
    if (req.method !== "POST") {
      return jsonError(res, 405, "Method not allowed");
    }

    const ip = getIp(req);
    const ua = getUserAgent(req);

    try {
      const { refreshToken: oldToken } = req.body;

      if (!oldToken || typeof oldToken !== "string") {
        return jsonError(res, 400, "رمز التحديث مطلوب");
      }

      // ── Rotate Token ──
      const result = await rotateRefreshToken(oldToken);

      if (!result) {
        return jsonError(res, 401, "رمز التحديث غير صالح أو منتهي الصلاحية");
      }

      // ── Look up user by session ──
      const sessionDoc = await db.collection("sessions").doc(result.sessionId).get();
      if (!sessionDoc.exists) {
        return jsonError(res, 401, "الجلسة غير موجودة");
      }

      const sessionData = sessionDoc.data()!;
      const userDoc = await db.collection(USERS_COLLECTION).doc(sessionData.userId).get();

      if (!userDoc.exists || !userDoc.data()!.isActive) {
        await revokeSession(result.sessionId);
        return jsonError(res, 403, "الحساب غير نشط");
      }

      const userData = userDoc.data()!;

      // ── Generate New Custom Token ──
      const customToken = await auth.createCustomToken(userDoc.id, {
        role: userData.role,
        nationalId: userData.nationalId,
        sessionId: result.sessionId,
      });

      await logAudit(userData.nationalId, "token_refresh", ip, ua, true, userDoc.id, {
        sessionId: result.sessionId,
      });

      return jsonSuccess(res, {
        customToken,
        refreshToken: result.newRefreshToken,
        sessionId: result.sessionId,
      });
    } catch (error: any) {
      console.error("Refresh token error:", error);
      return jsonError(res, 500, "حدث خطأ أثناء تحديث الرمز");
    }
  },
);

// ─── LOGOUT ───────────────────────────────────────────────────────────────

export const logoutUser = onRequest(
  { cors: true, region: "me-west1" },
  async (req, res) => {
    if (req.method !== "POST") {
      return jsonError(res, 405, "Method not allowed");
    }

    const ip = getIp(req);
    const ua = getUserAgent(req);

    try {
      const { sessionId, allDevices } = req.body;

      // Verify the caller via Firebase ID token
      const idToken = req.headers.authorization?.replace("Bearer ", "");
      if (!idToken) {
        return jsonError(res, 401, "غير مصرح");
      }

      const decoded = await auth.verifyIdToken(idToken);

      if (allDevices) {
        const count = await revokeAllUserSessions(decoded.uid);
        await auth.revokeRefreshTokens(decoded.uid);
        await logAudit(
          decoded.nationalId as string || decoded.uid,
          "all_sessions_revoked",
          ip, ua, true, decoded.uid,
          { sessionsRevoked: count },
        );
        return jsonSuccess(res, { message: "تم تسجيل الخروج من جميع الأجهزة", sessionsRevoked: count });
      }

      if (!sessionId) {
        return jsonError(res, 400, "معرف الجلسة مطلوب");
      }

      await revokeSession(sessionId);
      await logAudit(
        decoded.nationalId as string || decoded.uid,
        "logout",
        ip, ua, true, decoded.uid,
        { sessionId },
      );

      return jsonSuccess(res, { message: "تم تسجيل الخروج بنجاح" });
    } catch (error: any) {
      console.error("Logout error:", error);
      if (error.code === "auth/id-token-expired" || error.code === "auth/argument-error") {
        return jsonError(res, 401, "الرمز منتهي الصلاحية");
      }
      return jsonError(res, 500, "حدث خطأ أثناء تسجيل الخروج");
    }
  },
);

// ─── GET SESSIONS ─────────────────────────────────────────────────────────

export const listSessions = onRequest(
  { cors: true, region: "me-west1" },
  async (req, res) => {
    if (req.method !== "GET") {
      return jsonError(res, 405, "Method not allowed");
    }

    try {
      const idToken = req.headers.authorization?.replace("Bearer ", "");
      if (!idToken) {
        return jsonError(res, 401, "غير مصرح");
      }

      const decoded = await auth.verifyIdToken(idToken);
      const sessions = await getUserSessions(decoded.uid);

      return jsonSuccess(res, {
        sessions: sessions.map((s) => ({
          sessionId: s.sessionId,
          deviceInfo: s.deviceInfo,
          ipAddress: s.ipAddress,
          createdAt: s.createdAt,
          lastActivity: s.lastActivity,
        })),
      });
    } catch (error: any) {
      console.error("List sessions error:", error);
      return jsonError(res, 500, "حدث خطأ أثناء جلب الجلسات");
    }
  },
);

// ─── VALIDATE TOKEN (for NestJS backend middleware) ───────────────────────

export const validateToken = onRequest(
  { cors: true, region: "me-west1" },
  async (req, res) => {
    if (req.method !== "POST") {
      return jsonError(res, 405, "Method not allowed");
    }

    try {
      const idToken = req.headers.authorization?.replace("Bearer ", "");
      if (!idToken) {
        return jsonError(res, 401, "غير مصرح");
      }

      const decoded = await auth.verifyIdToken(idToken);

      const userDoc = await db.collection(USERS_COLLECTION).doc(decoded.uid).get();
      if (!userDoc.exists) {
        return jsonError(res, 404, "المستخدم غير موجود");
      }

      const userData = userDoc.data()!;
      if (!userData.isActive) {
        return jsonError(res, 403, "الحساب معطل");
      }

      return jsonSuccess(res, {
        uid: decoded.uid,
        nationalId: userData.nationalId,
        role: userData.role,
        fullName: userData.fullName,
        isVerified: userData.isVerified,
      });
    } catch (error: any) {
      if (error.code === "auth/id-token-expired") {
        return jsonError(res, 401, "الرمز منتهي الصلاحية");
      }
      console.error("Validate token error:", error);
      return jsonError(res, 401, "رمز غير صالح");
    }
  },
);
