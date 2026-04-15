import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Emergency Heatmap — خريطة حرارية حية لازدحام الطوارئ
class EmergencyHeatmapScreen extends StatefulWidget {
  const EmergencyHeatmapScreen({super.key});
  @override
  State<EmergencyHeatmapScreen> createState() => _EmergencyHeatmapScreenState();
}

class _EmergencyHeatmapScreenState extends State<EmergencyHeatmapScreen> {
  String _selectedCity = 'الكل';
  final _cities = [
    'الكل',
    'عمّان',
    'إربد',
    'الزرقاء',
    'العقبة',
    'الكرك',
    'جرش',
    'مادبا',
  ];

  // Mock hospital ER data
  final List<Map<String, dynamic>> _hospitals = [
    {
      'name': 'مستشفى الأردن',
      'city': 'عمّان',
      'load': 0.92,
      'waitMin': 85,
      'beds': 2,
      'totalBeds': 30,
      'lat': 31.95,
      'lng': 35.91,
    },
    {
      'name': 'مستشفى الجامعة الأردنية',
      'city': 'عمّان',
      'load': 0.78,
      'waitMin': 45,
      'beds': 8,
      'totalBeds': 40,
      'lat': 32.02,
      'lng': 35.87,
    },
    {
      'name': 'مستشفى البشير',
      'city': 'عمّان',
      'load': 0.95,
      'waitMin': 120,
      'beds': 1,
      'totalBeds': 50,
      'lat': 31.96,
      'lng': 35.93,
    },
    {
      'name': 'مستشفى الأمير حمزة',
      'city': 'عمّان',
      'load': 0.55,
      'waitMin': 20,
      'beds': 15,
      'totalBeds': 35,
      'lat': 32.00,
      'lng': 35.85,
    },
    {
      'name': 'مستشفى الملك المؤسس',
      'city': 'إربد',
      'load': 0.67,
      'waitMin': 30,
      'beds': 12,
      'totalBeds': 25,
      'lat': 32.55,
      'lng': 35.85,
    },
    {
      'name': 'مستشفى الأميرة بسمة',
      'city': 'إربد',
      'load': 0.82,
      'waitMin': 55,
      'beds': 5,
      'totalBeds': 28,
      'lat': 32.54,
      'lng': 35.87,
    },
    {
      'name': 'مستشفى الزرقاء الحكومي',
      'city': 'الزرقاء',
      'load': 0.88,
      'waitMin': 70,
      'beds': 3,
      'totalBeds': 22,
      'lat': 32.07,
      'lng': 36.09,
    },
    {
      'name': 'مستشفى الأمير هاشم',
      'city': 'العقبة',
      'load': 0.40,
      'waitMin': 10,
      'beds': 18,
      'totalBeds': 20,
      'lat': 29.53,
      'lng': 35.01,
    },
    {
      'name': 'مستشفى الكرك',
      'city': 'الكرك',
      'load': 0.60,
      'waitMin': 25,
      'beds': 10,
      'totalBeds': 18,
      'lat': 31.18,
      'lng': 35.76,
    },
    {
      'name': 'مستشفى جرش',
      'city': 'جرش',
      'load': 0.35,
      'waitMin': 5,
      'beds': 14,
      'totalBeds': 16,
      'lat': 32.28,
      'lng': 35.90,
    },
    {
      'name': 'مستشفى مادبا',
      'city': 'مادبا',
      'load': 0.50,
      'waitMin': 15,
      'beds': 8,
      'totalBeds': 15,
      'lat': 31.72,
      'lng': 35.79,
    },
  ];

  List<Map<String, dynamic>> get _filtered => _selectedCity == 'الكل'
      ? _hospitals
      : _hospitals.where((h) => h['city'] == _selectedCity).toList();

  @override
  Widget build(BuildContext context) {
    final sorted = List<Map<String, dynamic>>.from(_filtered)
      ..sort((a, b) => (a['load'] as double).compareTo(b['load'] as double));
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🔥', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      'خريطة الطوارئ الحية',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ازدحام طوارئ المستشفيات بالوقت الحقيقي',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(120),
                  ),
                ),
                const SizedBox(height: 12),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot('فارغ', const Color(0xFF22C55E)),
                    const SizedBox(width: 16),
                    _legendDot('متوسط', const Color(0xFFF59E0B)),
                    const SizedBox(width: 16),
                    _legendDot('مزدحم', const Color(0xFFEF4444)),
                  ],
                ),
                const SizedBox(height: 12),
                // City filter
                SizedBox(
                  height: 34,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _cities.length,
                    itemBuilder: (_, i) {
                      final selected = _cities[i] == _selectedCity;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCity = _cities[i]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.white.withAlpha(10),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.white.withAlpha(20),
                              ),
                            ),
                            child: Text(
                              _cities[i],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : Colors.white60,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _summaryCard(
                  'إجمالي',
                  '${_filtered.length}',
                  Icons.local_hospital_rounded,
                  Colors.white70,
                ),
                const SizedBox(width: 8),
                _summaryCard(
                  'متاح',
                  '${_filtered.where((h) => (h['load'] as double) < 0.6).length}',
                  Icons.check_circle_rounded,
                  const Color(0xFF22C55E),
                ),
                const SizedBox(width: 8),
                _summaryCard(
                  'مزدحم',
                  '${_filtered.where((h) => (h['load'] as double) >= 0.8).length}',
                  Icons.warning_rounded,
                  const Color(0xFFEF4444),
                ),
              ],
            ),
          ),
          // Hospital list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: sorted.length,
              itemBuilder: (_, i) => _hospitalCard(sorted[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(150)),
        ),
      ],
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color.withAlpha(180)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hospitalCard(Map<String, dynamic> h) {
    final load = h['load'] as double;
    final waitMin = h['waitMin'] as int;
    final beds = h['beds'] as int;
    final totalBeds = h['totalBeds'] as int;
    final color = load >= 0.8
        ? const Color(0xFFEF4444)
        : load >= 0.6
        ? const Color(0xFFF59E0B)
        : const Color(0xFF22C55E);
    final statusText = load >= 0.8
        ? 'مزدحم جداً'
        : load >= 0.6
        ? 'ازدحام متوسط'
        : 'متاح';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    load >= 0.8
                        ? '🔴'
                        : load >= 0.6
                        ? '🟡'
                        : '🟢',
                    style: const TextStyle(fontSize: 20),
                  ),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${h['city']} • $statusText',
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(load * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  Text(
                    'إشغال',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withAlpha(100),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: load,
              backgroundColor: Colors.white.withAlpha(10),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip('⏱️', '$waitMin دقيقة', 'وقت الانتظار'),
              const SizedBox(width: 8),
              _infoChip('🛏️', '$beds/$totalBeds', 'أسرّة متاحة'),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('جاري فتح الاتجاهات إلى ${h['name']} 🗺️'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.navigation_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'اتجاهات',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white.withAlpha(80),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
