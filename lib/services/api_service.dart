import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════
//  TERYAQ SMART HEALTH — API Service Layer
//  Centralized gateway to all backend microservices
// ═══════════════════════════════════════════════════════════════

class ApiService {
  // Android emulator: 10.0.2.2 maps to host machine's localhost
  // iOS simulator: localhost works directly
  // Real devices: replace with your machine's LAN IP (e.g., 192.168.1.x)
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    return 'http://$host:3000/api';
  }

  static String get _baseUrl => baseUrl;

  static String? _token;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static void setToken(String token) => _token = token;
  static void clearToken() => _token = null;
  static String? get token => _token;

  /// Restore token from SharedPreferences on app start
  static Future<void> restoreToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('auth_token');
      if (saved != null && saved.isNotEmpty) {
        _token = saved;
      }
    } catch (_) {}
  }

  // ── Auth ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['token'] != null) {
        _token = data['token'];
      }
      return data;
    } catch (_) {
      return {'success': false, 'error': 'فشل الاتصال'};
    }
  }

  static Future<Map<String, dynamic>> loginWithNationalId(String id) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/national-id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nationalId': id}),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['token'] != null) {
        _token = data['token'] as String;
      }
      return data;
    } catch (_) {
      return {'success': false, 'error': 'فشل الاتصال'};
    }
  }

  // ── User Profile ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/user/profile'),
        headers: _headers,
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  // ── Hospitals (Real Data) ────────────────────────────────
  static Future<List<Map<String, dynamic>>> getHospitals({
    String? governorate,
    String? specialty,
    String? search,
  }) async {
    try {
      final params = <String, String>{};
      if (governorate != null) params['governorate'] = governorate;
      if (specialty != null) params['specialty'] = specialty;
      if (search != null) params['search'] = search;
      final uri = Uri.parse(
        '$_baseUrl/hospitals',
      ).replace(queryParameters: params.isNotEmpty ? params : null);
      final res = await http.get(uri, headers: _headers);
      return List<Map<String, dynamic>>.from(jsonDecode(res.body) as List);
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getHospital(String id) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/hospitals/$id'),
        headers: _headers,
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  // ── Doctors (Real Data) ──────────────────────────────────
  static Future<List<Map<String, dynamic>>> getDoctors({
    String? specialization,
    String? hospitalId,
    String? search,
  }) async {
    try {
      final params = <String, String>{};
      if (specialization != null) params['specialization'] = specialization;
      if (hospitalId != null) params['hospitalId'] = hospitalId;
      if (search != null) params['search'] = search;
      final uri = Uri.parse(
        '$_baseUrl/doctors',
      ).replace(queryParameters: params.isNotEmpty ? params : null);
      final res = await http.get(uri, headers: _headers);
      return List<Map<String, dynamic>>.from(jsonDecode(res.body) as List);
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getDoctorSlots(
    String doctorId, {
    String? date,
  }) async {
    try {
      final params = <String, String>{};
      if (date != null) params['date'] = date;
      final uri = Uri.parse(
        '$_baseUrl/doctors/$doctorId/slots',
      ).replace(queryParameters: params.isNotEmpty ? params : null);
      final res = await http.get(uri, headers: _headers);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'slots': []};
    }
  }

  // ── Appointments ─────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getAppointments() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/health/appointments'),
        headers: _headers,
      );
      return List<Map<String, dynamic>>.from(jsonDecode(res.body) as List);
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> bookAppointment({
    required String hospitalId,
    required String department,
    String? doctorId,
    required String date,
    required String time,
    String? reason,
    String? type,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/health/appointments'),
        headers: _headers,
        body: jsonEncode({
          'hospitalId': hospitalId,
          'department': department,
          'doctorId': ?doctorId,
          'date': date,
          'time': time,
          'reason': ?reason,
          'type': ?type,
        }),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'error': 'فشل الاتصال بالسيرفر'};
    }
  }

  static Future<bool> cancelAppointment(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('$_baseUrl/health/appointments/$id'),
        headers: _headers,
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Health Records ───────────────────────────────────────
  static Future<Map<String, dynamic>> getHealthRecord() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/health/records'),
        headers: _headers,
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getLabResults() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/health/lab-results'),
        headers: _headers,
      );
      return List<Map<String, dynamic>>.from(jsonDecode(res.body) as List);
    } catch (_) {
      return [];
    }
  }

  // ── Medications ──────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getMedications() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/health/medications'),
        headers: _headers,
      );
      return List<Map<String, dynamic>>.from(jsonDecode(res.body) as List);
    } catch (_) {
      return [];
    }
  }

  // ── Notifications ────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/notifications'),
        headers: _headers,
      );
      return List<Map<String, dynamic>>.from(jsonDecode(res.body) as List);
    } catch (_) {
      return [];
    }
  }

  // ── Emergency ────────────────────────────────────────────
  static Future<Map<String, dynamic>> triggerEmergency({
    required double lat,
    required double lng,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/emergency/trigger'),
        headers: _headers,
        body: jsonEncode({'latitude': lat, 'longitude': lng}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }

  // ── AI Agent (smart booking + full context) ──────────────
  static Future<Map<String, dynamic>> chatWithAgent(
    List<Map<String, String>> messages, {
    double? lat,
    double? lng,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/ai/chat'),
        headers: _headers,
        body: jsonEncode({
          'messages': messages,
          if (lat != null && lng != null)
            'userLocation': {'lat': lat, 'lng': lng},
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return {'reply': 'عذراً، حدث خطأ. حاول مرة أخرى.', 'actions': []};
    } catch (_) {
      return {
        'reply': 'تعذر الاتصال بالسيرفر. تحقق من الإنترنت.',
        'actions': [],
      };
    }
  }

  // Legacy wrapper — routes through server AI agent
  static Future<String> chat(List<Map<String, String>> messages) async {
    final result = await chatWithAgent(messages);
    return result['reply'] as String? ?? 'حدث خطأ.';
  }

  // ── OTP Auth (Feature 1) ─────────────────────────────────
  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/otp/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'error': 'فشل الاتصال'};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
    String phone,
    String code,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/otp/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'code': code}),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['token'] != null)
        _token = data['token'] as String;
      return data;
    } catch (_) {
      return {'success': false, 'error': 'فشل الاتصال'};
    }
  }

  // ── Resident Registration (Feature 16) ───────────────────
  static Future<Map<String, dynamic>> registerResident({
    required String name,
    required String phone,
    String? passportNumber,
    String? nationality,
    String? birthDate,
    String? gender,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/register/resident'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'passportNumber': passportNumber,
          'nationality': nationality,
          'birthDate': birthDate,
          'gender': gender,
        }),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['token'] != null)
        _token = data['token'] as String;
      return data;
    } catch (_) {
      return {'success': false, 'error': 'فشل الاتصال'};
    }
  }

  // ── Update Profile (Feature 19) ──────────────────────────
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/user/profile'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }

  // ── Family Link (Feature 11) ─────────────────────────────
  static Future<List<Map<String, dynamic>>> getFamilyMembers() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/family/members'),
        headers: _headers,
      );
      return List<Map<String, dynamic>>.from(jsonDecode(res.body) as List);
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> addFamilyMember(
    Map<String, dynamic> data,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/family/members'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }

  // ── Smart Booking (Feature 4, 6) ─────────────────────────
  static Future<List<Map<String, dynamic>>> smartBookingSearch({
    String? specialty,
    String? governorate,
    String? urgency,
  }) async {
    try {
      final params = <String, String>{};
      if (specialty != null) params['specialty'] = specialty;
      if (governorate != null) params['governorate'] = governorate;
      if (urgency != null) params['urgency'] = urgency;
      final uri = Uri.parse(
        '$_baseUrl/booking/smart-search',
      ).replace(queryParameters: params.isNotEmpty ? params : null);
      final res = await http.get(uri, headers: _headers);
      return List<Map<String, dynamic>>.from(jsonDecode(res.body) as List);
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> rescheduleAppointment(
    String aptId,
    String newDate,
    String newTime,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/booking/reschedule'),
        headers: _headers,
        body: jsonEncode({
          'appointmentId': aptId,
          'newDate': newDate,
          'newTime': newTime,
        }),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }

  // ── Medication Delivery & Refill (Feature 8, 9) ──────────
  static Future<Map<String, dynamic>> refillMedication(String medId) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/medications/refill'),
        headers: _headers,
        body: jsonEncode({'medicationId': medId}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> orderMedicationDelivery({
    required List<String> medicationIds,
    String? address,
    String? phone,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/medications/deliver'),
        headers: _headers,
        body: jsonEncode({
          'medicationIds': medicationIds,
          'address': address,
          'phone': phone,
        }),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }

  // ── Notification Settings (Feature 5, 13) ────────────────
  static Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/notifications/settings'),
        headers: _headers,
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> updateNotificationSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/notifications/settings'),
        headers: _headers,
        body: jsonEncode(settings),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }

  // ── Geofence (Feature 13) ────────────────────────────────
  static Future<Map<String, dynamic>> geofenceCheckin(
    double lat,
    double lng,
    String hospitalId,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/geofence/checkin'),
        headers: _headers,
        body: jsonEncode({'lat': lat, 'lng': lng, 'hospitalId': hospitalId}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }

  // ── Home Nursing (Feature 12) ────────────────────────────
  static Future<Map<String, dynamic>> bookNursingService({
    required String serviceId,
    required String date,
    required String time,
    String? address,
    String? patientName,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/nursing/book'),
        headers: _headers,
        body: jsonEncode({
          'serviceId': serviceId,
          'date': date,
          'time': time,
          'address': address,
          'patientName': patientName,
        }),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }

  // ── Wearable Devices (Feature 14) ────────────────────────
  static Future<Map<String, dynamic>> syncDeviceReadings(
    String deviceType,
    Map<String, dynamic> readings,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/devices/sync'),
        headers: _headers,
        body: jsonEncode({'deviceType': deviceType, 'readings': readings}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }

  // ── Payments (Feature 15) ────────────────────────────────
  static Future<List<Map<String, dynamic>>> getBills() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/payments/bills'),
        headers: _headers,
      );
      return List<Map<String, dynamic>>.from(jsonDecode(res.body) as List);
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> payBill(
    String billId, {
    String method = 'بطاقة',
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/payments/pay'),
        headers: _headers,
        body: jsonEncode({'billId': billId, 'method': method}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }

  // ── Health Tips (Feature 18) ─────────────────────────────
  static Future<Map<String, dynamic>> getDailyTips() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/health/tips'),
        headers: _headers,
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'tips': []};
    }
  }

  // ── Chronic Care Plans (Feature 17) ──────────────────────
  static Future<List<Map<String, dynamic>>> getChronicPlans() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/chronic/plans'),
        headers: _headers,
      );
      return List<Map<String, dynamic>>.from(jsonDecode(res.body) as List);
    } catch (_) {
      return [];
    }
  }

  // ── Offline Wallet Data (Feature 2, 3) ───────────────────
  static Future<Map<String, dynamic>> getOfflineWalletData() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/wallet/offline-data'),
        headers: _headers,
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  // ── HMS Lab Ready (Feature 31) ───────────────────────────
  static Future<Map<String, dynamic>> notifyLabReady(
    String patientId,
    String labName,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/hms/lab-ready'),
        headers: _headers,
        body: jsonEncode({'patientId': patientId, 'labName': labName}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }

  // ── HMS ER Registration (Feature 32) ─────────────────────
  static Future<Map<String, dynamic>> registerErCase({
    required String name,
    required int age,
    required String gender,
    required String complaint,
    String? severity,
    Map<String, dynamic>? vitals,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/hms/er/register'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'age': age,
          'gender': gender,
          'complaint': complaint,
          'severity': severity,
          'vitals': vitals,
        }),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }

  // ── HMS Redistribute (Feature 24) ────────────────────────
  static Future<Map<String, dynamic>> redistributeAppointments(
    String doctorId,
    String reason,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/hms/redistribute'),
        headers: _headers,
        body: jsonEncode({'doctorId': doctorId, 'reason': reason}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }

  // ── MOH Multi-Source (Feature 40) ────────────────────────
  static Future<Map<String, dynamic>> getMohDataSources() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/moh/data-sources'),
        headers: _headers,
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  // ── Hakeem Integration (Feature 43) ──────────────────────
  static Future<Map<String, dynamic>> getHakeemPatient(
    String nationalId,
  ) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/hakeem/patient/$nationalId'),
        headers: _headers,
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
