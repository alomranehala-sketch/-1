import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/moh_service.dart';
import '../../theme.dart';

class MohMapScreen extends StatefulWidget {
  const MohMapScreen({super.key});
  @override
  State<MohMapScreen> createState() => _MohMapScreenState();
}

class _MohMapScreenState extends State<MohMapScreen> {
  final _mapController = MapController();
  // ignore: unused_field
  List<Map<String, dynamic>> _hospitals = [];
  Map<String, dynamic>? _selectedHospital;
  // ignore: unused_field
  bool _loading = true;

  // Jordan center coordinates
  static const _jordanCenter = LatLng(31.95, 35.93);

  // Hospital locations across Jordan
  final _hospitalLocations = <Map<String, dynamic>>[
    {
      'name': 'مستشفى الملك المؤسس',
      'city': 'عمّان',
      'lat': 31.955,
      'lng': 35.945,
      'beds': 1200,
      'occupancy': 82,
      'emergency': true,
    },
    {
      'name': 'مستشفى الجامعة الأردنية',
      'city': 'عمّان',
      'lat': 31.975,
      'lng': 35.88,
      'beds': 800,
      'occupancy': 75,
      'emergency': true,
    },
    {
      'name': 'مستشفى البشير',
      'city': 'عمّان',
      'lat': 31.94,
      'lng': 35.92,
      'beds': 1000,
      'occupancy': 90,
      'emergency': true,
    },
    {
      'name': 'مستشفى الأمير حمزة',
      'city': 'عمّان',
      'lat': 31.99,
      'lng': 35.87,
      'beds': 600,
      'occupancy': 68,
      'emergency': true,
    },
    {
      'name': 'مستشفى الملك عبدالله',
      'city': 'إربد',
      'lat': 32.555,
      'lng': 35.85,
      'beds': 700,
      'occupancy': 78,
      'emergency': true,
    },
    {
      'name': 'مستشفى الأميرة بسمة',
      'city': 'إربد',
      'lat': 32.54,
      'lng': 35.87,
      'beds': 450,
      'occupancy': 72,
      'emergency': false,
    },
    {
      'name': 'مستشفى الزرقاء الحكومي',
      'city': 'الزرقاء',
      'lat': 32.07,
      'lng': 36.09,
      'beds': 500,
      'occupancy': 88,
      'emergency': true,
    },
    {
      'name': 'مستشفى الأمير فيصل',
      'city': 'الزرقاء',
      'lat': 32.06,
      'lng': 36.07,
      'beds': 350,
      'occupancy': 80,
      'emergency': false,
    },
    {
      'name': 'مستشفى العقبة',
      'city': 'العقبة',
      'lat': 29.53,
      'lng': 35.00,
      'beds': 300,
      'occupancy': 65,
      'emergency': true,
    },
    {
      'name': 'مستشفى الكرك',
      'city': 'الكرك',
      'lat': 31.18,
      'lng': 35.70,
      'beds': 250,
      'occupancy': 58,
      'emergency': false,
    },
    {
      'name': 'مستشفى معان',
      'city': 'معان',
      'lat': 30.19,
      'lng': 35.73,
      'beds': 200,
      'occupancy': 52,
      'emergency': false,
    },
    {
      'name': 'مستشفى جرش',
      'city': 'جرش',
      'lat': 32.28,
      'lng': 35.90,
      'beds': 180,
      'occupancy': 60,
      'emergency': false,
    },
    {
      'name': 'مستشفى السلط',
      'city': 'السلط',
      'lat': 32.04,
      'lng': 35.73,
      'beds': 300,
      'occupancy': 70,
      'emergency': true,
    },
    {
      'name': 'مستشفى مادبا',
      'city': 'مادبا',
      'lat': 31.72,
      'lng': 35.79,
      'beds': 220,
      'occupancy': 62,
      'emergency': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hospitals = await MohService.getHospitals();
    if (mounted) {
      setState(() {
        _hospitals = hospitals.isNotEmpty ? hospitals : _hospitalLocations;
        _loading = false;
      });
    }
  }

  Color _occupancyColor(int occ) {
    if (occ > 85) return AppColors.error;
    if (occ > 70) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 12),
          color: const Color(0xFF1E293B),
          child: Row(
            children: [
              const Text('🗺️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Text(
                'خريطة المستشفيات — الأردن',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_hospitalLocations.length} مستشفى',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _jordanCenter,
                  initialZoom: 7.5,
                  minZoom: 6,
                  maxZoom: 16,
                  onTap: (_, _) => setState(() => _selectedHospital = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.teryaq.app',
                  ),
                  MarkerLayer(
                    markers: _hospitalLocations.map((h) {
                      final occ = h['occupancy'] as int;
                      final color = _occupancyColor(occ);
                      final isSelected =
                          _selectedHospital?['name'] == h['name'];
                      return Marker(
                        point: LatLng(h['lat'] as double, h['lng'] as double),
                        width: isSelected ? 60 : 40,
                        height: isSelected ? 60 : 40,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedHospital = h),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(isSelected ? 8 : 6),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withAlpha(80),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  h['emergency'] == true
                                      ? Icons.local_hospital_rounded
                                      : Icons.medical_services_rounded,
                                  color: Colors.white,
                                  size: isSelected ? 18 : 14,
                                ),
                              ),
                              if (isSelected)
                                Text(
                                  h['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              // Legend
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withAlpha(220),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _legendItem(const Color(0xFF10B981), 'إشغال < 70%'),
                      _legendItem(const Color(0xFFF59E0B), 'إشغال 70-85%'),
                      _legendItem(AppColors.error, 'إشغال > 85%'),
                    ],
                  ),
                ),
              ),
              // Selected hospital detail
              if (_selectedHospital != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _hospitalDetail(_selectedHospital!),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.white.withAlpha(180)),
          ),
        ],
      ),
    );
  }

  Widget _hospitalDetail(Map<String, dynamic> h) {
    final occ = h['occupancy'] as int;
    final color = _occupancyColor(occ);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  h['emergency'] == true
                      ? Icons.local_hospital_rounded
                      : Icons.medical_services_rounded,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h['name'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${h['city']} • ${h['beds']} سرير',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$occ%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: occ / 100,
              backgroundColor: Colors.white.withAlpha(10),
              color: color,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _tag(Icons.bed_rounded, '${h['beds']} سرير'),
              const SizedBox(width: 12),
              _tag(
                Icons.check_circle_rounded,
                '${((h['beds'] as int) * (100 - occ) / 100).round()} متاح',
              ),
              if (h['emergency'] == true) ...[
                const SizedBox(width: 12),
                _tag(Icons.emergency_rounded, 'طوارئ'),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white.withAlpha(80)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(120)),
        ),
      ],
    );
  }
}
