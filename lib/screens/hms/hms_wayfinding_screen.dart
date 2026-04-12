import 'package:flutter/material.dart';
import '../../theme.dart';

/// Indoor Wayfinding — Hospital floor plan with navigation
class HmsWayfindingScreen extends StatefulWidget {
  const HmsWayfindingScreen({super.key});
  @override
  State<HmsWayfindingScreen> createState() => _HmsWayfindingScreenState();
}

class _HmsWayfindingScreenState extends State<HmsWayfindingScreen> {
  String _selectedFloor = 'الطابق الأرضي';
  String? _selectedDest;

  final _floors = [
    'الطابق الأرضي',
    'الطابق الأول',
    'الطابق الثاني',
    'الطابق الثالث',
  ];

  final _destinations = <String, List<Map<String, dynamic>>>{
    'الطابق الأرضي': [
      {
        'name': 'الاستقبال',
        'icon': Icons.support_agent_rounded,
        'x': 0.5,
        'y': 0.2,
      },
      {
        'name': 'الطوارئ',
        'icon': Icons.local_hospital_rounded,
        'x': 0.8,
        'y': 0.3,
      },
      {
        'name': 'الصيدلية',
        'icon': Icons.local_pharmacy_rounded,
        'x': 0.2,
        'y': 0.5,
      },
      {'name': 'المختبر', 'icon': Icons.biotech_rounded, 'x': 0.6, 'y': 0.6},
      {'name': 'الأشعة', 'icon': Icons.camera_rounded, 'x': 0.3, 'y': 0.8},
    ],
    'الطابق الأول': [
      {
        'name': 'العيادات الخارجية',
        'icon': Icons.medical_services_rounded,
        'x': 0.4,
        'y': 0.3,
      },
      {
        'name': 'قسم الباطنية',
        'icon': Icons.healing_rounded,
        'x': 0.7,
        'y': 0.4,
      },
      {
        'name': 'قسم الجراحة',
        'icon': Icons.content_cut_rounded,
        'x': 0.3,
        'y': 0.6,
      },
      {'name': 'غرف العمليات', 'icon': Icons.masks_rounded, 'x': 0.6, 'y': 0.7},
    ],
    'الطابق الثاني': [
      {
        'name': 'قسم الأطفال',
        'icon': Icons.child_care_rounded,
        'x': 0.4,
        'y': 0.3,
      },
      {
        'name': 'قسم النسائية',
        'icon': Icons.pregnant_woman_rounded,
        'x': 0.6,
        'y': 0.5,
      },
      {
        'name': 'العناية المركزة',
        'icon': Icons.monitor_heart_rounded,
        'x': 0.5,
        'y': 0.7,
      },
    ],
    'الطابق الثالث': [
      {'name': 'قسم القلب', 'icon': Icons.favorite_rounded, 'x': 0.4, 'y': 0.3},
      {
        'name': 'قسم العظام',
        'icon': Icons.accessibility_new_rounded,
        'x': 0.6,
        'y': 0.5,
      },
      {
        'name': 'قسم الأعصاب',
        'icon': Icons.psychology_rounded,
        'x': 0.5,
        'y': 0.7,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final dests = _destinations[_selectedFloor] ?? [];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'الملاحة الداخلية 🗺️',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Column(
          children: [
            // Floor selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: const Color(0xFF1E293B),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _floors.map((f) {
                    final active = f == _selectedFloor;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedFloor = f;
                        _selectedDest = null;
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary.withAlpha(20)
                              : Colors.white.withAlpha(5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active
                                ? AppColors.primary.withAlpha(60)
                                : Colors.white.withAlpha(10),
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: active
                                ? AppColors.primary
                                : Colors.white.withAlpha(100),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Floor plan
            Expanded(
              child: Stack(
                children: [
                  // Grid
                  CustomPaint(
                    painter: _FloorGridPainter(),
                    size: Size.infinite,
                  ),
                  // Navigation path
                  if (_selectedDest != null)
                    CustomPaint(
                      painter: _NavPathPainter(
                        dests.firstWhere(
                          (d) => d['name'] == _selectedDest,
                          orElse: () => dests.first,
                        ),
                      ),
                      size: Size.infinite,
                    ),
                  // Destination markers
                  ...dests.map((d) => _buildMarker(d, context)),
                  // "You are here" marker
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.1,
                    top: MediaQuery.of(context).size.height * 0.15,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(80),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'أنت هنا',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Destinations list
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: const Color(0xFF1E293B),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: dests.map((d) {
                  final active = d['name'] == _selectedDest;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedDest = d['name'] as String),
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary.withAlpha(20)
                            : Colors.white.withAlpha(5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: active
                              ? AppColors.primary.withAlpha(60)
                              : Colors.white.withAlpha(10),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            d['icon'] as IconData,
                            size: 24,
                            color: active
                                ? AppColors.primary
                                : Colors.white.withAlpha(80),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            d['name'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: active
                                  ? Colors.white
                                  : Colors.white.withAlpha(100),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarker(Map<String, dynamic> d, BuildContext ctx) {
    final active = d['name'] == _selectedDest;
    final w = MediaQuery.of(ctx).size.width;
    final h = MediaQuery.of(ctx).size.height * 0.55;
    return Positioned(
      left: w * (d['x'] as double) - 20,
      top: h * (d['y'] as double),
      child: GestureDetector(
        onTap: () => setState(() => _selectedDest = d['name'] as String),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: active ? AppColors.success : const Color(0xFF1E293B),
                shape: BoxShape.circle,
                border: Border.all(
                  color: active
                      ? AppColors.success
                      : Colors.white.withAlpha(20),
                  width: 2,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppColors.success.withAlpha(60),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                d['icon'] as IconData,
                size: 16,
                color: active ? Colors.white : Colors.white.withAlpha(80),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              d['name'] as String,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.success : Colors.white.withAlpha(80),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloorGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(8)
      ..strokeWidth = 0.5;
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Draw vertical lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NavPathPainter extends CustomPainter {
  final Map<String, dynamic> dest;
  _NavPathPainter(this.dest);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withAlpha(100)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startX = size.width * 0.1 + 10;
    final startY = size.height * 0.15 + 10;
    final endX = size.width * (dest['x'] as double);
    final endY = size.height * (dest['y'] as double);

    final path = Path()
      ..moveTo(startX, startY)
      ..cubicTo(startX, endY * 0.5, endX * 0.5, startY, endX, endY);

    // Draw dashed path
    final dashPath = Path();
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        dashPath.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
