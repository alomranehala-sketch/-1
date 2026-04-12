import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════
//  TERYAQ SMART HEALTH — Geofencing Service
//  Monitors user location vs hospital zones
//  Triggers alerts when approaching hospitals
// ═══════════════════════════════════════════════════════════════

class GeofencingService {
  static const double _defaultRadiusMeters = 500.0;
  static StreamSubscription<Position>? _positionSub;
  static final _nearbyController = StreamController<GeofenceEvent>.broadcast();
  static Stream<GeofenceEvent> get nearbyStream => _nearbyController.stream;

  static final List<_Hospital> _hospitals = [
    _Hospital('مستشفى الأردن', 31.9580, 35.8650),
    _Hospital('مستشفى الجامعة الأردنية', 32.0194, 35.8744),
    _Hospital('مدينة الملك حسين الطبية', 31.9773, 35.8639),
    _Hospital('مستشفى البشير', 31.9500, 35.9350),
    _Hospital('مستشفى الأمير حمزة', 31.9980, 35.8700),
    _Hospital('المركز العربي الطبي', 31.9620, 35.8570),
    _Hospital('مستشفى الخالدي', 31.9530, 35.8900),
    _Hospital('مستشفى ابن الهيثم', 31.9700, 35.8800),
    _Hospital('مستشفى إيسرا', 31.9420, 35.8700),
    _Hospital('مستشفى الزرقاء الحكومي', 32.0670, 36.0870),
    _Hospital('مستشفى الأميرة بسمة - إربد', 32.5570, 35.8500),
    _Hospital('مستشفى الأمير علي - الكرك', 31.1800, 35.7050),
  ];

  static bool _enabled = true;
  static final Set<String> _alerted = {};

  static Future<bool> init() async {
    if (kIsWeb) return false;
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('geofencing_enabled') ?? true;
    if (!_enabled) return false;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return false;
    }

    startMonitoring();
    return true;
  }

  static void startMonitoring() {
    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 50,
      ),
    ).listen(_checkGeofences);
  }

  static void stopMonitoring() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  static void _checkGeofences(Position pos) {
    for (final hospital in _hospitals) {
      final dist = _distanceMeters(
        pos.latitude,
        pos.longitude,
        hospital.lat,
        hospital.lng,
      );
      final key = hospital.name;
      if (dist <= _defaultRadiusMeters && !_alerted.contains(key)) {
        _alerted.add(key);
        _nearbyController.add(
          GeofenceEvent(
            hospitalName: hospital.name,
            distanceMeters: dist.round(),
            message:
                'أنت قريب من ${hospital.name} (${dist.round()} متر).\nيتم تفعيل دورك وتجهيز ملفك الآن.',
          ),
        );
      } else if (dist > _defaultRadiusMeters * 2) {
        _alerted.remove(key);
      }
    }
  }

  static double _distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _rad(double deg) => deg * pi / 180;

  static Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('geofencing_enabled', enabled);
    if (enabled) {
      startMonitoring();
    } else {
      stopMonitoring();
    }
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('geofencing_enabled') ?? true;
  }

  static void dispose() {
    _positionSub?.cancel();
    _nearbyController.close();
  }
}

class GeofenceEvent {
  final String hospitalName;
  final int distanceMeters;
  final String message;
  const GeofenceEvent({
    required this.hospitalName,
    required this.distanceMeters,
    required this.message,
  });
}

class _Hospital {
  final String name;
  final double lat;
  final double lng;
  const _Hospital(this.name, this.lat, this.lng);
}
