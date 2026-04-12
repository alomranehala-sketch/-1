import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// Ministry of Health — API Service
class MohService {
  static String get _base => ApiService.baseUrl;
  static Map<String, String> get _h => {
    'Content-Type': 'application/json',
    if (ApiService.token != null) 'Authorization': 'Bearer ${ApiService.token}',
  };

  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final r = await http.get(Uri.parse('$_base/moh/dashboard'), headers: _h);
      return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getHospitals() async {
    try {
      final r = await http.get(Uri.parse('$_base/moh/hospitals'), headers: _h);
      return List<Map<String, dynamic>>.from(jsonDecode(r.body));
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final r = await http.get(Uri.parse('$_base/moh/analytics'), headers: _h);
      return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getReports() async {
    try {
      final r = await http.get(Uri.parse('$_base/moh/reports'), headers: _h);
      return List<Map<String, dynamic>>.from(jsonDecode(r.body));
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getEpidemicData() async {
    try {
      final r = await http.get(Uri.parse('$_base/moh/epidemic'), headers: _h);
      return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> getEquityData() async {
    try {
      final r = await http.get(Uri.parse('$_base/moh/equity'), headers: _h);
      return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> sendAlert(
    Map<String, dynamic> data,
  ) async {
    try {
      final r = await http.post(
        Uri.parse('$_base/moh/alerts'),
        headers: _h,
        body: jsonEncode(data),
      );
      return jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false};
    }
  }
}
