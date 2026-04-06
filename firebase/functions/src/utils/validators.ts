import { AUTH_CONFIG } from "../config/constants.js";

const NATIONAL_ID_REGEX = new RegExp(AUTH_CONFIG.NATIONAL_ID_REGEX);
const PERSONAL_NUMBER_MIN = 6;
const PERSONAL_NUMBER_MAX = 128;

export interface ValidationResult {
  valid: boolean;
  error?: string;
}

export function validateNationalId(nationalId: string): ValidationResult {
  if (!nationalId || typeof nationalId !== "string") {
    return { valid: false, error: "الرقم الوطني مطلوب" };
  }

  const trimmed = nationalId.trim();

  if (!NATIONAL_ID_REGEX.test(trimmed)) {
    return { valid: false, error: "صيغة الرقم الوطني غير صحيحة - يجب أن يكون 10 أرقام" };
  }

  return { valid: true };
}

export function validatePersonalNumber(personalNumber: string): ValidationResult {
  if (!personalNumber || typeof personalNumber !== "string") {
    return { valid: false, error: "الرقم الشخصي مطلوب" };
  }

  if (personalNumber.length < PERSONAL_NUMBER_MIN) {
    return { valid: false, error: `الرقم الشخصي يجب أن يكون ${PERSONAL_NUMBER_MIN} أحرف على الأقل` };
  }

  if (personalNumber.length > PERSONAL_NUMBER_MAX) {
    return { valid: false, error: "الرقم الشخصي طويل جداً" };
  }

  return { valid: true };
}

export function validateFullName(fullName: string): ValidationResult {
  if (!fullName || typeof fullName !== "string") {
    return { valid: false, error: "الاسم الكامل مطلوب" };
  }

  const trimmed = fullName.trim();

  if (trimmed.length < 2 || trimmed.length > 200) {
    return { valid: false, error: "الاسم يجب أن يكون بين 2 و 200 حرف" };
  }

  return { valid: true };
}

export function validateRole(role: string): ValidationResult {
  const validRoles = ["citizen", "doctor", "nurse", "hospital_admin", "moh_admin", "pharmacist", "paramedic"];
  if (!role || !validRoles.includes(role)) {
    return { valid: false, error: "الدور غير صالح" };
  }
  return { valid: true };
}

export function sanitizeInput(input: string): string {
  if (typeof input !== "string") return "";
  return input.trim().replace(/[<>]/g, "");
}
