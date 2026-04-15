import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // ignore: unused_field
  bool _loading = true;
  String _filter = 'الكل'; // الكل / حرج / تحذير / متاح / طوارئ

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
      'type': 'حكومي عام',
      'icu': 80,
      'icuOcc': 68,
      'er': 45,
      'waitList': 12,
      'phone': '06-5600800',
      'address': 'عمّان، شارع الجبيهة',
      'founded': 1963,
      'doctors': 200,
      'nurses': 400,
      'rating': 4.3,
      'dept': 'متعدد التخصصات',
      'parking': true,
    },
    {
      'name': 'مستشفى الجامعة الأردنية',
      'city': 'عمّان',
      'lat': 31.975,
      'lng': 35.88,
      'beds': 800,
      'occupancy': 75,
      'emergency': true,
      'type': 'جامعي',
      'icu': 60,
      'icuOcc': 42,
      'er': 30,
      'waitList': 8,
      'phone': '06-5353444',
      'address': 'عمّان، الجبيهة',
      'founded': 1973,
      'doctors': 350,
      'nurses': 280,
      'rating': 4.6,
      'dept': 'تعليمي متخصص',
      'parking': true,
    },
    {
      'name': 'مستشفى البشير',
      'city': 'عمّان',
      'lat': 31.94,
      'lng': 35.92,
      'beds': 1000,
      'occupancy': 90,
      'emergency': true,
      'type': 'حكومي عام',
      'icu': 70,
      'icuOcc': 67,
      'er': 60,
      'waitList': 25,
      'phone': '06-5001000',
      'address': 'عمّان، الرابية',
      'founded': 1972,
      'doctors': 180,
      'nurses': 360,
      'rating': 3.9,
      'dept': 'متعدد التخصصات',
      'parking': false,
    },
    {
      'name': 'مستشفى الأمير حمزة',
      'city': 'عمّان',
      'lat': 31.99,
      'lng': 35.87,
      'beds': 600,
      'occupancy': 68,
      'emergency': true,
      'type': 'حكومي',
      'icu': 40,
      'icuOcc': 22,
      'er': 20,
      'waitList': 5,
      'phone': '06-5200500',
      'address': 'عمّان، ماركا',
      'founded': 1985,
      'doctors': 120,
      'nurses': 240,
      'rating': 4.1,
      'dept': 'عام',
      'parking': true,
    },
    {
      'name': 'مستشفى الملك عبدالله',
      'city': 'إربد',
      'lat': 32.555,
      'lng': 35.85,
      'beds': 700,
      'occupancy': 78,
      'emergency': true,
      'type': 'حكومي',
      'icu': 50,
      'icuOcc': 38,
      'er': 35,
      'waitList': 10,
      'phone': '02-7090900',
      'address': 'إربد، وسط المدينة',
      'founded': 1969,
      'doctors': 140,
      'nurses': 280,
      'rating': 4.0,
      'dept': 'متعدد التخصصات',
      'parking': true,
    },
    {
      'name': 'مستشفى الأميرة بسمة',
      'city': 'إربد',
      'lat': 32.54,
      'lng': 35.87,
      'beds': 450,
      'occupancy': 72,
      'emergency': false,
      'type': 'حكومي',
      'icu': 25,
      'icuOcc': 15,
      'er': 0,
      'waitList': 6,
      'phone': '02-7271700',
      'address': 'إربد، الحي الجنوبي',
      'founded': 1978,
      'doctors': 90,
      'nurses': 180,
      'rating': 3.8,
      'dept': 'نساء وأطفال',
      'parking': true,
    },
    {
      'name': 'مستشفى الزرقاء الحكومي',
      'city': 'الزرقاء',
      'lat': 32.07,
      'lng': 36.09,
      'beds': 500,
      'occupancy': 88,
      'emergency': true,
      'type': 'حكومي',
      'icu': 35,
      'icuOcc': 32,
      'er': 40,
      'waitList': 20,
      'phone': '05-3826800',
      'address': 'الزرقاء، المدينة القديمة',
      'founded': 1970,
      'doctors': 100,
      'nurses': 200,
      'rating': 3.7,
      'dept': 'عام',
      'parking': false,
    },
    {
      'name': 'مستشفى الأمير فيصل',
      'city': 'الزرقاء',
      'lat': 32.06,
      'lng': 36.07,
      'beds': 350,
      'occupancy': 80,
      'emergency': false,
      'type': 'حكومي',
      'icu': 20,
      'icuOcc': 14,
      'er': 0,
      'waitList': 8,
      'phone': '05-3624700',
      'address': 'الزرقاء، الجديدة',
      'founded': 1982,
      'doctors': 70,
      'nurses': 140,
      'rating': 3.9,
      'dept': 'عام',
      'parking': true,
    },
    {
      'name': 'مستشفى العقبة',
      'city': 'العقبة',
      'lat': 29.53,
      'lng': 35.00,
      'beds': 300,
      'occupancy': 65,
      'emergency': true,
      'type': 'حكومي',
      'icu': 20,
      'icuOcc': 11,
      'er': 15,
      'waitList': 4,
      'phone': '03-2012000',
      'address': 'العقبة، وسط المدينة',
      'founded': 1975,
      'doctors': 60,
      'nurses': 120,
      'rating': 4.0,
      'dept': 'عام',
      'parking': true,
    },
    {
      'name': 'مستشفى الكرك',
      'city': 'الكرك',
      'lat': 31.18,
      'lng': 35.70,
      'beds': 250,
      'occupancy': 58,
      'emergency': false,
      'type': 'حكومي',
      'icu': 15,
      'icuOcc': 7,
      'er': 0,
      'waitList': 3,
      'phone': '03-2351460',
      'address': 'الكرك، وسط البلد',
      'founded': 1968,
      'doctors': 50,
      'nurses': 100,
      'rating': 3.6,
      'dept': 'عام',
      'parking': true,
    },
    {
      'name': 'مستشفى معان',
      'city': 'معان',
      'lat': 30.19,
      'lng': 35.73,
      'beds': 200,
      'occupancy': 52,
      'emergency': false,
      'type': 'حكومي',
      'icu': 12,
      'icuOcc': 5,
      'er': 0,
      'waitList': 2,
      'phone': '03-2132000',
      'address': 'معان، حي الشرق',
      'founded': 1972,
      'doctors': 40,
      'nurses': 80,
      'rating': 3.5,
      'dept': 'عام',
      'parking': true,
    },
    {
      'name': 'مستشفى جرش',
      'city': 'جرش',
      'lat': 32.28,
      'lng': 35.90,
      'beds': 180,
      'occupancy': 60,
      'emergency': false,
      'type': 'حكومي',
      'icu': 10,
      'icuOcc': 5,
      'er': 0,
      'waitList': 2,
      'phone': '02-6350800',
      'address': 'جرش، المنطقة المركزية',
      'founded': 1974,
      'doctors': 36,
      'nurses': 72,
      'rating': 3.7,
      'dept': 'عام',
      'parking': false,
    },
    {
      'name': 'مستشفى السلط',
      'city': 'السلط',
      'lat': 32.04,
      'lng': 35.73,
      'beds': 300,
      'occupancy': 70,
      'emergency': true,
      'type': 'حكومي',
      'icu': 18,
      'icuOcc': 11,
      'er': 12,
      'waitList': 5,
      'phone': '05-3550400',
      'address': 'السلط، وسط المدينة',
      'founded': 1971,
      'doctors': 60,
      'nurses': 120,
      'rating': 3.9,
      'dept': 'عام',
      'parking': true,
    },
    {
      'name': 'مستشفى مادبا',
      'city': 'مادبا',
      'lat': 31.72,
      'lng': 35.79,
      'beds': 220,
      'occupancy': 62,
      'emergency': false,
      'type': 'حكومي',
      'icu': 12,
      'icuOcc': 6,
      'er': 0,
      'waitList': 3,
      'phone': '05-3240700',
      'address': 'مادبا، الحي الغربي',
      'founded': 1976,
      'doctors': 44,
      'nurses': 88,
      'rating': 3.8,
      'dept': 'عام',
      'parking': true,
    },
  ];
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

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'الكل') return _hospitalLocations;
    if (_filter == 'طوارئ') return _hospitalLocations.where((h) => h['emergency'] == true).toList();
    if (_filter == 'حرج') return _hospitalLocations.where((h) => (h['occupancy'] as int) > 85).toList();
    if (_filter == 'تحذير') return _hospitalLocations.where((h) {
      final o = h['occupancy'] as int;
      return o > 70 && o <= 85;
    }).toList();
    if (_filter == 'متاح') return _hospitalLocations.where((h) => (h['occupancy'] as int) <= 70).toList();
    return _hospitalLocations;
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final filtered = _filtered;
    final critical = _hospitalLocations.where((h) => (h['occupancy'] as int) > 85).length;
    final warning = _hospitalLocations.where((h) {
      final o = h['occupancy'] as int;
      return o > 70 && o <= 85;
    }).length;
    final available = _hospitalLocations.where((h) => (h['occupancy'] as int) <= 70).length;

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 8),
          color: const Color(0xFF1E293B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🗺️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'خريطة المستشفيات',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _statBadge('🔴', '$critical', Colors.redAccent),
                  const SizedBox(width: 6),
                  _statBadge('🟡', '$warning', const Color(0xFFF59E0B)),
                  const SizedBox(width: 6),
                  _statBadge('🟢', '$available', const Color(0xFF10B981)),
                ],
              ),
              const SizedBox(height: 10),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['الكل', 'حرج', 'تحذير', 'متاح', 'طوارئ'].map((f) {
                    final selected = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF3B82F6) : Colors.white.withAlpha(12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: selected ? const Color(0xFF3B82F6) : Colors.white.withAlpha(20)),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white60,
                              fontSize: 11,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
                options: const MapOptions(
                  initialCenter: _jordanCenter,
                  initialZoom: 7.5,
                  minZoom: 6,
                  maxZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.teryaq.app',
                  ),
                  MarkerLayer(
                    markers: filtered.map((h) {
                      final occ = h['occupancy'] as int;
                      final color = _occupancyColor(occ);
                      return Marker(
                        point: LatLng(h['lat'] as double, h['lng'] as double),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => _showDetail(h),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(color: color.withAlpha(120), blurRadius: 10),
                              ],
                            ),
                            child: Icon(
                              h['emergency'] == true
                                  ? Icons.local_hospital_rounded
                                  : Icons.medical_services_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
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
              // Filtered count
              if (_filter != 'الكل')
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withAlpha(220),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'عرض ${filtered.length} مستشفى — تصفية: $_filter',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statBadge(String emoji, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(val, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _showDetail(Map<String, dynamic> h) {
    HapticFeedback.mediumImpact();
    final occ = h['occupancy'] as int;
    final color = _occupancyColor(occ);
    final beds = h['beds'] as int;
    final available = (beds * (100 - occ) / 100).round();
    final icu = h['icu'] as int? ?? 0;
    final icuOcc = h['icuOcc'] as int? ?? 0;
    final icuRate = icu > 0 ? icuOcc / icu : 0.0;
    final icuColor = icuRate > 0.85 ? Colors.redAccent : icuRate > 0.65 ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
    final occRate = occ / 100;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, ctrl) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        h['emergency'] == true ? Icons.local_hospital_rounded : Icons.medical_services_rounded,
                        color: color, size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h['name'] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: Colors.white38, size: 12),
                              const SizedBox(width: 3),
                              Text(
                                '${h['city']}  •  ${h['type'] ?? 'حكومي'}',
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6, runSpacing: 4,
                            children: [
                              _badge(h['type'] as String? ?? 'حكومي', Colors.white30),
                              _badge(h['city'] as String, const Color(0xFF10B981)),
                              if (h['emergency'] == true) _badge('🚨 طوارئ', Colors.redAccent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Status banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: color.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        occ >= 95 ? Icons.dangerous_rounded : occ >= 80 ? Icons.warning_rounded : Icons.check_circle_rounded,
                        color: color, size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              occ >= 95 ? '⛔ الطاقة الاستيعابية ممتلئة' : occ >= 80 ? '⚠️ يقترب من الطاقة القصوى' : '✅ الوضع مستقر',
                              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'إشغال $occ% — $available سرير متاح من $beds',
                              style: TextStyle(color: color.withAlpha(180), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Occupancy bars
                _sectionTitle('📊 الإشغال الحالي'),
                const SizedBox(height: 12),
                _progressBar('🛏️ الأسرة العامة', occ, 100, color),
                const SizedBox(height: 8),
                if (icu > 0) ...[
                  _progressBar('🫀 العناية المركزة (ICU)', (icuRate * 100).round(), 100, icuColor),
                  const SizedBox(height: 8),
                ],
                // Stats grid
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.1,
                  children: [
                    _statCell('🟢', '$available', 'متاح', const Color(0xFF10B981)),
                    _statCell('🔴', '${beds - available}', 'مشغول', Colors.redAccent),
                    _statCell('🚨', '${h['er'] ?? 0}', 'طاقة طوارئ', Colors.orange),
                    _statCell('⏳', '${h['waitList'] ?? 0}', 'انتظار', const Color(0xFFF59E0B)),
                    _statCell('🫀', '$icu', 'أسرة ICU', const Color(0xFF8B5CF6)),
                    _statCell('📊', '$occ%', 'الإشغال', color),
                  ],
                ),
                const SizedBox(height: 20),
                // Hospital info
                _sectionTitle('🏥 معلومات المستشفى'),
                const SizedBox(height: 10),
                _infoRow(Icons.location_on_rounded, 'العنوان', h['address'] as String? ?? h['city'] as String),
                _infoRow(Icons.phone_rounded, 'الهاتف', h['phone'] as String? ?? 'غير متوفر'),
                _infoRow(Icons.apartment_rounded, 'التخصص', h['dept'] as String? ?? 'عام'),
                _infoRow(Icons.business_center_rounded, 'النوع', h['type'] as String? ?? 'حكومي'),
                _infoRow(Icons.calendar_today_rounded, 'سنة التأسيس', '${h['founded'] ?? 'غير متوفر'}'),
                _infoRow(Icons.star_rounded, 'التقييم', '⭐ ${h['rating'] ?? '4.0'} من 5'),
                _infoRow(Icons.people_rounded, 'عدد الأطباء', '${h['doctors'] ?? (beds ~/ 6)} طبيب'),
                _infoRow(Icons.medical_services_rounded, 'عدد التمريض', '${h['nurses'] ?? (beds ~/ 3)} ممرض/ة'),
                _infoRow(Icons.access_time_rounded, 'ساعات العمل', '24 ساعة / 7 أيام'),
                _infoRow(Icons.hourglass_top_rounded, 'وقت الانتظار', '${((h['waitList'] as int? ?? 0) * 3 + 10)} دقيقة'),
                _infoRow(Icons.local_parking_rounded, 'موقف السيارات', (h['parking'] as bool? ?? true) ? 'متاح ✅' : 'غير متاح ❌'),
                const SizedBox(height: 20),
                // Departments
                _sectionTitle('🏥 الأقسام الطبية'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    h['dept'] as String? ?? 'عام',
                    'طب الطوارئ',
                    'الباطنية',
                    'الجراحة',
                    'التخدير',
                    'الأشعة',
                    'المختبر',
                    'الصيدلة',
                    if (h['emergency'] == true) 'وحدة إنعاش',
                  ].map((d) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withAlpha(12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withAlpha(30)),
                    ),
                    child: Text(d, style: TextStyle(color: color, fontSize: 11)),
                  )).toList(),
                ),
                const SizedBox(height: 24),
                // Action buttons
                _sectionTitle('⚡ إجراءات'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _actionBtn(Icons.phone_rounded, 'اتصال', const Color(0xFF10B981))),
                    const SizedBox(width: 8),
                    Expanded(child: _actionBtn(Icons.map_rounded, 'الموقع', const Color(0xFF3B82F6))),
                    const SizedBox(width: 8),
                    Expanded(child: _actionBtn(Icons.bed_rounded, 'حجز سرير', const Color(0xFF8B5CF6))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _actionBtn(Icons.share_rounded, 'مشاركة', const Color(0xFFF59E0B))),
                    const SizedBox(width: 8),
                    Expanded(child: _actionBtn(Icons.directions_rounded, 'الاتجاهات', Colors.teal)),
                    const SizedBox(width: 8),
                    Expanded(child: _actionBtn(Icons.calendar_month_rounded, 'موعد', Colors.deepOrange)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: TextStyle(
      color: Colors.white.withAlpha(200),
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    ),
  );

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withAlpha(60)),
    ),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
  );

  Widget _progressBar(String label, int val, int total, Color color) {
    final rate = total > 0 ? val / total : 0.0;
    return Column(
      children: [
        Row(
          children: [
            Flexible(child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Text('$val%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rate.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withAlpha(12),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 7,
          ),
        ),
      ],
    );
  }

  Widget _statCell(String emoji, String val, String label, Color color) => Container(
    decoration: BoxDecoration(
      color: color.withAlpha(12),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withAlpha(30)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(color: color.withAlpha(160), fontSize: 9), textAlign: TextAlign.center),
      ],
    ),
  );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white30, size: 14),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Colors.white38, fontSize: 12)),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
      ],
    ),
  );

  Widget _actionBtn(IconData icon, String label, Color color) => GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
