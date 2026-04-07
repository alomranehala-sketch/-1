import * as bcrypt from "bcrypt";
import { AUTH_CONFIG } from "../config/constants.js";

/**
 * Hash a personal number (password) using bcrypt
 */
export async function hashPersonalNumber(personalNumber: string): Promise<string> {
  return bcrypt.hash(personalNumber, AUTH_CONFIG.BCRYPT_ROUNDS);
}

/**
 * Compare a plaintext personal number against the stored hash
 * Uses constant-time comparison to prevent timing attacks
 */
export async function verifyPersonalNumber(
  personalNumber: string,
  storedHash: string,
): Promise<boolean> {
  return bcrypt.compare(personalNumber, storedHash);
}
