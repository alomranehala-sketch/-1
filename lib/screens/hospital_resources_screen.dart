import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

/// Hospital Resources Map — خريطة موارد المستشفيات الحية
/// Live: beds, ER wait, equipment, doctors per department (public + private)
class HospitalResourcesScreen extends StatefulWidget {
  const HospitalResourcesScreen({super.key});
  @override
  State<HospitalResourcesScreen> createState() =>
      _HospitalResourcesScreenState();
}

class _HospitalResourcesScreenState extends State<HospitalResourcesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  Timer? _timer;
  int _selectedFilter = 0;

  final _filters = ['الكل', 'الأسرّة', 'الطوارئ', 'العمليات', 'الأشعة'];

  final _hospitals = [
    _HospitalResource(
      'مستشفى الجامعة الأردنية',
      'عام',
      'عمّان',
      totalBeds: 850,
      availableBeds: 47,
      erWait: 45,
      icuBeds: 5,
      orRooms: 2,
      doctors: 120,
      xrayAvail: true,
      ctAvail: true,
      mriAvail: false,
    ),
    _HospitalResource(
      'مستشفى البشير',
      'عام',
      'عمّان',
      totalBeds: 1000,
      availableBeds: 23,
      erWait: 75,
      icuBeds: 2,
      orRooms: 1,
      doctors: 150,
      xrayAvail: true,
      ctAvail: true,
      mriAvail: true,
    ),
    _HospitalResource(
      'مستشفى الأردن',
      'خاص',
      'عمّان',
      totalBeds: 350,
      availableBeds: 45,
      erWait: 10,
      icuBeds: 8,
      orRooms: 4,
      doctors: 85,
      xrayAvail: true,
      ctAvail: true,
      mriAvail: true,
    ),
    _HospitalResource(
      'مستشفى الأمير حمزة',
      'عام',
      'عمّان',
      totalBeds: 600,
      availableBeds: 31,
      erWait: 35,
      icuBeds: 3,
      orRooms: 2,
      doctors: 95,
      xrayAvail: true,
      ctAvail: false,
      mriAvail: false,
    ),
    _HospitalResource(
      'المركز العربي الطبي',
      'خاص',
      'عمّان',
      totalBeds: 260,
      availableBeds: 52,
      erWait: 8,
      icuBeds: 10,
      orRooms: 5,
      doctors: 70,
      xrayAvail: true,
      ctAvail: true,
      mriAvail: true,
    ),
    _HospitalResource(
      'مستشفى الملك المؤسس',
      'عام',
      'عمّان',
      totalBeds: 500,
      availableBeds: 38,
      erWait: 50,
      icuBeds: 4,
      orRooms: 3,
      doctors: 88,
      xrayAvail: true,
      ctAvail: true,
      mriAvail: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) {
        setState(() {
          for (final h in _hospitals) {
            h.availableBeds += Random().nextInt(5) - 2;
            h.availableBeds = h.availableBeds.clamp(0, h.totalBeds);
            h.erWait += Random().nextInt(10) - 5;
            h.erWait = h.erWait.clamp(5, 120);
            h.icuBeds += Random().nextInt(3) - 1;
            h.icuBeds = h.icuBeds.clamp(0, 20);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                children: [
                  const Text(
                    'موارد المستشفيات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, _) => Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          AppColors.success,
                          AppColors.success.withAlpha(100),
                          _pulseCtrl.value,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: _buildNationalSummary()),
            SliverToBoxAdapter(child: _buildFilters()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _buildHospitalCard(_hospitals[i]),
                childCount: _hospitals.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildNationalSummary() {
    final totalBeds = _hospitals.fold<int>(0, (s, h) => s + h.availableBeds);
    final totalICU = _hospitals.fold<int>(0, (s, h) => s + h.icuBeds);
    final avgER =
        _hospitals.fold<int>(0, (s, h) => s + h.erWait) ~/ _hospitals.length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF0F172A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص موارد عمّان 🏥',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'بيانات لحظية من جميع المستشفيات',
            style: TextStyle(color: AppColors.textLight, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _summaryCard(
                'أسرّة شاغرة',
                '$totalBeds',
                Icons.bed_rounded,
                const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              _summaryCard(
                'عناية مركزة',
                '$totalICU',
                Icons.monitor_heart_rounded,
                const Color(0xFFEF4444),
              ),
              const SizedBox(width: 8),
              _summaryCard(
                'متوسط طوارئ',
                '$avgER د',
                Icons.access_time_rounded,
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: AppColors.textLight, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final selected = _selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.border.withAlpha(40),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _filters[i],
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textMedium,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHospitalCard(_HospitalResource h) {
    final isPublic = h.type == 'عام';
    final typeColor = isPublic
        ? const Color(0xFF10B981)
        : const Color(0xFF6366F1);
    final bedPercent = ((h.totalBeds - h.availableBeds) / h.totalBeds * 100)
        .round();
    final bedColor = bedPercent > 90
        ? const Color(0xFFEF4444)
        : bedPercent > 70
        ? const Color(0xFFF59E0B)
        : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          h.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            h.type,
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      h.location,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Resources grid
          Row(
            children: [
              _resourceTile(
                'أسرّة شاغرة',
                '${h.availableBeds}/${h.totalBeds}',
                Icons.bed_rounded,
                bedColor,
              ),
              const SizedBox(width: 6),
              _resourceTile(
                'طوارئ',
                '${h.erWait} د',
                Icons.emergency_rounded,
                h.erWait > 60
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 6),
              _resourceTile(
                'عناية مركزة',
                '${h.icuBeds}',
                Icons.monitor_heart_rounded,
                h.icuBeds < 3
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 6),
              _resourceTile(
                'عمليات',
                '${h.orRooms}',
                Icons.local_hospital_rounded,
                const Color(0xFF8B5CF6),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Bed occupancy bar
          Row(
            children: [
              Text(
                'نسبة الإشغال: $bedPercent%',
                style: TextStyle(color: AppColors.textLight, fontSize: 11),
              ),
              const Spacer(),
              Text(
                '${h.doctors} طبيب',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: bedPercent / 100,
              backgroundColor: AppColors.border.withAlpha(30),
              color: bedColor,
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 10),
          // Equipment availability
          Row(
            children: [
              _equipBadge('أشعة', h.xrayAvail),
              const SizedBox(width: 6),
              _equipBadge('CT', h.ctAvail),
              const SizedBox(width: 6),
              _equipBadge('MRI', h.mriAvail),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.navigation_rounded, size: 14),
                label: const Text('اتجاهات', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resourceTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: AppColors.textLight, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _equipBadge(String name, bool available) {
    final color = available ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            available ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HospitalResource {
  final String name, type, location;
  int totalBeds, availableBeds, erWait, icuBeds, orRooms, doctors;
  bool xrayAvail, ctAvail, mriAvail;
  _HospitalResource(
    this.name,
    this.type,
    this.location, {
    required this.totalBeds,
    required this.availableBeds,
    required this.erWait,
    required this.icuBeds,
    required this.orRooms,
    required this.doctors,
    required this.xrayAvail,
    required this.ctAvail,
    required this.mriAvail,
  });
}
