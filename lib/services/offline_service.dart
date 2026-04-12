import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

// ═══════════════════════════════════════════════════════════════
//  TERYAQ SMART HEALTH — Offline Service
//  Full offline mode: caches all critical health data locally
//  Works without internet — emergency QR always available
// ═══════════════════════════════════════════════════════════════

class OfflineService {
  static const _keyProfile = 'offline_profile';
  static const _keyRecord = 'offline_health_record';
  static const _keyAppointments = 'offline_appointments';
  static const _keyMedications = 'offline_medications';
  static const _keyLabResults = 'offline_lab_results';
  static const _keyNotifications = 'offline_notifications';
  static const _keyLastSync = 'offline_last_sync';
  static const _keyWalletQr = 'offline_wallet_qr';
  static const _keyTips = 'offline_tips';

  /// Sync all critical data from server for offline use (Feature 3)
  static Future<void> syncAll() async {
    try {
      final profile = await ApiService.getProfile();
      if (profile.isNotEmpty) await cacheProfile(profile);

      final record = await ApiService.getHealthRecord();
      if (record.isNotEmpty) await cacheHealthRecord(record);

      final meds = await ApiService.getMedications();
      if (meds.isNotEmpty) await cacheMedications(meds);

      final labs = await ApiService.getLabResults();
      if (labs.isNotEmpty) await cacheLabResults(labs);

      final wallet = await ApiService.getOfflineWalletData();
      if (wallet.isNotEmpty) {
        final p = await SharedPreferences.getInstance();
        await p.setString(_keyWalletQr, jsonEncode(wallet));
      }

      final tips = await ApiService.getDailyTips();
      if (tips.isNotEmpty) {
        final p = await SharedPreferences.getInstance();
        await p.setString(_keyTips, jsonEncode(tips));
      }

      await _updateSync();
    } catch (_) {}
  }

  /// Get cached wallet QR data (for offline QR generation)
  static Future<Map<String, dynamic>> getWalletData() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_keyWalletQr);
    if (raw != null) return jsonDecode(raw) as Map<String, dynamic>;
    return {};
  }

  /// Get cached daily tips
  static Future<Map<String, dynamic>> getTips() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_keyTips);
    if (raw != null) return jsonDecode(raw) as Map<String, dynamic>;
    return {'tips': []};
  }

  // ── Save data to local cache ──────────────────────────────
  static Future<void> cacheProfile(Map<String, dynamic> data) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyProfile, jsonEncode(data));
    await _updateSync();
  }

  static Future<void> cacheHealthRecord(Map<String, dynamic> data) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyRecord, jsonEncode(data));
  }

  static Future<void> cacheAppointments(List<Map<String, dynamic>> data) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyAppointments, jsonEncode(data));
  }

  static Future<void> cacheMedications(List<Map<String, dynamic>> data) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyMedications, jsonEncode(data));
  }

  static Future<void> cacheLabResults(List<Map<String, dynamic>> data) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyLabResults, jsonEncode(data));
  }

  static Future<void> cacheNotifications(
    List<Map<String, dynamic>> data,
  ) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyNotifications, jsonEncode(data));
  }

  // ── Load from cache ───────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_keyProfile);
    if (raw == null) return _defaultProfile();
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getHealthRecord() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_keyRecord);
    if (raw == null) return _defaultRecord();
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getAppointments() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_keyAppointments);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
  }

  static Future<List<Map<String, dynamic>>> getMedications() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_keyMedications);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
  }

  static Future<List<Map<String, dynamic>>> getLabResults() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_keyLabResults);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
  }

  // ── Sync timestamp ────────────────────────────────────────
  static Future<void> _updateSync() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyLastSync, DateTime.now().toIso8601String());
  }

  static Future<String> getLastSync() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_keyLastSync);
    if (raw == null) return 'لم تتم المزامنة بعد';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'غير معروف';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  static Future<bool> hasCache() async {
    final p = await SharedPreferences.getInstance();
    return p.containsKey(_keyProfile);
  }

  // ── Emergency QR data (always offline) ───────────────────
  static Future<Map<String, dynamic>> getEmergencyQrData() async {
    final profile = await getProfile();
    final record = await getHealthRecord();
    return {
      'name': profile['name'] ?? '',
      'nationalId': profile['nationalId'] ?? '',
      'bloodType': record['bloodType'] ?? '',
      'allergies': record['allergies'] ?? [],
      'chronicDiseases': record['chronicDiseases'] ?? [],
      'emergencyContact': profile['emergencyContact'] ?? '',
      'insuranceId': profile['insuranceId'] ?? '',
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  // ── Default fallback data ─────────────────────────────────
  static Map<String, dynamic> _defaultProfile() => {
    'name': 'مستخدم ترياق',
    'nationalId': '',
    'bloodType': 'غير معروف',
    'phone': '',
    'email': '',
    'emergencyContact': '',
    'insuranceId': '',
  };

  static Map<String, dynamic> _defaultRecord() => {
    'bloodType': 'غير معروف',
    'allergies': <String>[],
    'chronicDiseases': <String>[],
    'medications': <String>[],
    'vaccinations': <String>[],
  };
}
