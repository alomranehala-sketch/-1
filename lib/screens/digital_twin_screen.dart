import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Digital Twin — التوأم الرقمي للمستشفى
class DigitalTwinScreen extends StatefulWidget {
  const DigitalTwinScreen({super.key});
  @override
  State<DigitalTwinScreen> createState() => _DigitalTwinScreenState();
}

class _DigitalTwinScreenState extends State<DigitalTwinScreen>
    with SingleTickerProviderStateMixin {
  int _selectedFloor = 0;
  late AnimationController _pulseCtrl;

  final _floors = [
    'الطابق الأرضي',
    'الطابق الأول',
    'الطابق الثاني',
    'الطابق الثالث',
  ];

  // Departments per floor with live status
  final List<List<Map<String, dynamic>>> _floorData = [
    // Ground floor
    [
      {
        'name': 'الطوارئ',
        'icon': '🚨',
        'load': 0.85,
        'patients': 28,
        'staff': 12,
        'x': 0.15,
        'y': 0.25,
        'w': 0.35,
        'h': 0.22,
      },
      {
        'name': 'الاستقبال',
        'icon': '🏥',
        'load': 0.40,
        'patients': 8,
        'staff': 4,
        'x': 0.55,
        'y': 0.25,
        'w': 0.30,
        'h': 0.22,
      },
      {
        'name': 'المختبر',
        'icon': '🧪',
        'load': 0.60,
        'patients': 15,
        'staff': 6,
        'x': 0.15,
        'y': 0.55,
        'w': 0.25,
        'h': 0.20,
      },
      {
        'name': 'الأشعة',
        'icon': '📡',
        'load': 0.55,
        'patients': 5,
        'staff': 3,
        'x': 0.45,
        'y': 0.55,
        'w': 0.25,
        'h': 0.20,
      },
      {
        'name': 'الصيدلية',
        'icon': '💊',
        'load': 0.70,
        'patients': 20,
        'staff': 5,
        'x': 0.75,
        'y': 0.55,
        'w': 0.15,
        'h': 0.20,
      },
    ],
    // First floor
    [
      {
        'name': 'الباطنية',
        'icon': '🩺',
        'load': 0.75,
        'patients': 22,
        'staff': 8,
        'x': 0.10,
        'y': 0.25,
        'w': 0.35,
        'h': 0.25,
      },
      {
        'name': 'القلب',
        'icon': '❤️',
        'load': 0.90,
        'patients': 18,
        'staff': 10,
        'x': 0.50,
        'y': 0.25,
        'w': 0.35,
        'h': 0.25,
      },
      {
        'name': 'العيادات',
        'icon': '👨‍⚕️',
        'load': 0.50,
        'patients': 30,
        'staff': 15,
        'x': 0.10,
        'y': 0.58,
        'w': 0.75,
        'h': 0.20,
      },
    ],
    // Second floor
    [
      {
        'name': 'الجراحة',
        'icon': '🔪',
        'load': 0.65,
        'patients': 12,
        'staff': 20,
        'x': 0.10,
        'y': 0.25,
        'w': 0.35,
        'h': 0.25,
      },
      {
        'name': 'العمليات',
        'icon': '⚕️',
        'load': 0.80,
        'patients': 4,
        'staff': 16,
        'x': 0.50,
        'y': 0.25,
        'w': 0.35,
        'h': 0.25,
      },
      {
        'name': 'العناية المركزة',
        'icon': '🫀',
        'load': 0.95,
        'patients': 10,
        'staff': 12,
        'x': 0.10,
        'y': 0.58,
        'w': 0.75,
        'h': 0.20,
      },
    ],
    // Third floor
    [
      {
        'name': 'الأطفال',
        'icon': '👶',
        'load': 0.45,
        'patients': 15,
        'staff': 8,
        'x': 0.10,
        'y': 0.25,
        'w': 0.35,
        'h': 0.25,
      },
      {
        'name': 'النسائية',
        'icon': '🤱',
        'load': 0.55,
        'patients': 10,
        'staff': 6,
        'x': 0.50,
        'y': 0.25,
        'w': 0.35,
        'h': 0.25,
      },
      {
        'name': 'العظام',
        'icon': '🦴',
        'load': 0.35,
        'patients': 8,
        'staff': 4,
        'x': 0.10,
        'y': 0.58,
        'w': 0.35,
        'h': 0.20,
      },
      {
        'name': 'الأعصاب',
        'icon': '🧠',
        'load': 0.60,
        'patients': 6,
        'staff': 5,
        'x': 0.50,
        'y': 0.58,
        'w': 0.35,
        'h': 0.20,
      },
    ],
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  int get _totalPatients => _floorData
      .expand((f) => f)
      .fold(0, (sum, d) => sum + (d['patients'] as int));
  int get _totalStaff => _floorData
      .expand((f) => f)
      .fold(0, (sum, d) => sum + (d['staff'] as int));
  double get _avgLoad =>
      _floorData
          .expand((f) => f)
          .map((d) => d['load'] as double)
          .reduce((a, b) => a + b) /
      _floorData.expand((f) => f).length;

  @override
  Widget build(BuildContext context) {
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
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('🏗️', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'التوأم الرقمي — مستشفى الأردن',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, __) => Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(
                            (150 + (_pulseCtrl.value * 105)).toInt(),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Summary row
                Row(
                  children: [
                    _miniStat(
                      'مرضى',
                      '$_totalPatients',
                      Icons.people_rounded,
                      AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    _miniStat(
                      'طاقم',
                      '$_totalStaff',
                      Icons.badge_rounded,
                      AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    _miniStat(
                      'إشغال',
                      '${(_avgLoad * 100).toInt()}%',
                      Icons.speed_rounded,
                      _avgLoad > 0.7 ? AppColors.error : AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Floor selector
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _floors.length,
              itemBuilder: (_, i) {
                final selected = i == _selectedFloor;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedFloor = i);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.white.withAlpha(15),
                        ),
                      ),
                      child: Text(
                        _floors[i],
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
          const SizedBox(height: 12),

          // Floor plan visualization
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Floor map
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withAlpha(10)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                // Grid lines
                                ..._buildGridLines(constraints),
                                // Departments
                                ..._floorData[_selectedFloor].map(
                                  (dept) => _deptBlock(dept, constraints),
                                ),
                                // Floor label
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _floors[_selectedFloor],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Department list
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _floorData[_selectedFloor].length,
                      itemBuilder: (_, i) =>
                          _deptListItem(_floorData[_selectedFloor][i]),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGridLines(BoxConstraints c) {
    return List.generate(5, (i) {
      final pos = c.maxWidth * (i + 1) / 6;
      return Positioned(
        left: pos,
        top: 0,
        bottom: 0,
        child: Container(width: 0.5, color: Colors.white.withAlpha(5)),
      );
    })..addAll(
      List.generate(4, (i) {
        final pos = c.maxHeight * (i + 1) / 5;
        return Positioned(
          left: 0,
          right: 0,
          top: pos,
          child: Container(height: 0.5, color: Colors.white.withAlpha(5)),
        );
      }),
    );
  }

  Widget _deptBlock(Map<String, dynamic> dept, BoxConstraints c) {
    final load = dept['load'] as double;
    final color = load >= 0.8
        ? const Color(0xFFEF4444)
        : load >= 0.6
        ? const Color(0xFFF59E0B)
        : const Color(0xFF22C55E);
    final x = (dept['x'] as double) * c.maxWidth;
    final y = (dept['y'] as double) * c.maxHeight;
    final w = (dept['w'] as double) * c.maxWidth;
    final h = (dept['h'] as double) * c.maxHeight;

    return Positioned(
      left: x,
      top: y,
      width: w,
      height: h,
      child: GestureDetector(
        onTap: () => _showDeptDetail(dept),
        child: AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, child) => Container(
            decoration: BoxDecoration(
              color: color.withAlpha(
                (15 + (_pulseCtrl.value * (load > 0.8 ? 15 : 5)).toInt()),
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withAlpha(50),
                width: load > 0.8 ? 1.5 : 1,
              ),
            ),
            child: child,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dept['icon'] as String,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 2),
              Text(
                dept['name'] as String,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '${(load * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deptListItem(Map<String, dynamic> dept) {
    final load = dept['load'] as double;
    final color = load >= 0.8
        ? const Color(0xFFEF4444)
        : load >= 0.6
        ? const Color(0xFFF59E0B)
        : const Color(0xFF22C55E);

    return GestureDetector(
      onTap: () => _showDeptDetail(dept),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(20)),
        ),
        child: Row(
          children: [
            Text(dept['icon'] as String, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dept['name'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${dept['patients']} مريض • ${dept['staff']} طاقم',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withAlpha(100),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: load,
                  backgroundColor: Colors.white.withAlpha(10),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(load * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 9, color: color.withAlpha(150)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeptDetail(Map<String, dynamic> dept) {
    final load = dept['load'] as double;
    final color = load >= 0.8
        ? const Color(0xFFEF4444)
        : load >= 0.6
        ? const Color(0xFFF59E0B)
        : const Color(0xFF22C55E);
    final status = load >= 0.8
        ? 'مزدحم'
        : load >= 0.6
        ? 'متوسط'
        : 'هادئ';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${dept['icon']} ${dept['name']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _detailStat('الحالة', status, color),
                  _detailStat('الإشغال', '${(load * 100).toInt()}%', color),
                  _detailStat(
                    'المرضى',
                    '${dept['patients']}',
                    AppColors.primary,
                  ),
                  _detailStat('الطاقم', '${dept['staff']}', AppColors.info),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: load,
                  backgroundColor: Colors.white.withAlpha(10),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 16),
              if (load >= 0.8)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Color(0xFFEF4444),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'تحذير: القسم يعمل بطاقة قريبة من الحد الأقصى',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
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
            style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(100)),
          ),
        ],
      ),
    );
  }
}
