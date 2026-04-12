import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// Hospital Management System — API Service
class HmsService {
  static String get _base => ApiService.baseUrl;
  static Map<String, String> get _h => {
    'Content-Type': 'application/json',
    if (ApiService.token != null) 'Authorization': 'Bearer ${ApiService.token}',
  };

  // Dashboard
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final r = await http.get(Uri.parse('$_base/hms/dashboard'), headers: _h);
      return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  // Patients
  static Future<List<Map<String, dynamic>>> getPatients({
    String? status,
    String? triage,
    String? department,
  }) async {
    try {
      final params = <String, String>{};
      if (status != null) params['status'] = status;
      if (triage != null) params['triage'] = triage;
      if (department != null) params['department'] = department;
      final uri = Uri.parse(
        '$_base/hms/patients',
      ).replace(queryParameters: params.isNotEmpty ? params : null);
      final r = await http.get(uri, headers: _h);
      return List<Map<String, dynamic>>.from(jsonDecode(r.body));
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> checkinPatient(
    Map<String, dynamic> data,
  ) async {
    try {
      final r = await http.post(
        Uri.parse('$_base/hms/patients/checkin'),
        headers: _h,
        body: jsonEncode(data),
      );
      return jsonDecode(r.body);
    } catch (_) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> updateTriage(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final r = await http.patch(
        Uri.parse('$_base/hms/patients/$id/triage'),
        headers: _h,
        body: jsonEncode(data),
      );
      return jsonDecode(r.body);
    } catch (_) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> updatePatientStatus(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final r = await http.patch(
        Uri.parse('$_base/hms/patients/$id/status'),
        headers: _h,
        body: jsonEncode(data),
      );
      return jsonDecode(r.body);
    } catch (_) {
      return {'success': false};
    }
  }

  // Beds
  static Future<Map<String, dynamic>> getBeds({String? ward}) async {
    try {
      final params = ward != null ? {'ward': ward} : null;
      final uri = Uri.parse('$_base/hms/beds').replace(queryParameters: params);
      final r = await http.get(uri, headers: _h);
      return jsonDecode(r.body);
    } catch (_) {
      return {'beds': [], 'summary': {}};
    }
  }

  // Alerts
  static Future<List<Map<String, dynamic>>> getAlerts() async {
    try {
      final r = await http.get(Uri.parse('$_base/hms/alerts'), headers: _h);
      return List<Map<String, dynamic>>.from(jsonDecode(r.body));
    } catch (_) {
      return [];
    }
  }

  static Future<void> acknowledgeAlert(String id) async {
    try {
      await http.patch(
        Uri.parse('$_base/hms/alerts/$id/acknowledge'),
        headers: _h,
      );
    } catch (_) {}
  }

  // EMS
  static Future<List<Map<String, dynamic>>> getEmsIncoming() async {
    try {
      final r = await http.get(Uri.parse('$_base/hms/ems'), headers: _h);
      return List<Map<String, dynamic>>.from(jsonDecode(r.body));
    } catch (_) {
      return [];
    }
  }

  // Feedback
  static Future<List<Map<String, dynamic>>> getFeedback() async {
    try {
      final r = await http.get(Uri.parse('$_base/hms/feedback'), headers: _h);
      return List<Map<String, dynamic>>.from(jsonDecode(r.body));
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> submitFeedback(
    Map<String, dynamic> data,
  ) async {
    try {
      final r = await http.post(
        Uri.parse('$_base/hms/feedback'),
        headers: _h,
        body: jsonEncode(data),
      );
      return jsonDecode(r.body);
    } catch (_) {
      return {'success': false};
    }
  }
}
