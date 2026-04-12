import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});
  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilter = 0;

  final _filters = const ['الكل', 'نشط', 'مجدول', 'منتهي'];

  // Adherence tracking
  final int _streak = 12;
  final Map<String, bool> _weeklyAdherence = {
    'السبت': true,
    'الأحد': true,
    'الإثنين': true,
    'الثلاثاء': true,
    'الأربعاء': false,
    'الخميس': true,
    'الجمعة': true,
  };
  final Map<String, double> _medAdherence = {
    'ميتفورمين': 0.95,
    'فيتامين D': 0.88,
    'أموكسيسيلين': 1.0,
    'لوراتادين': 0.72,
  };

  final _medications = [
    _Med(
      'أموكسيسيلين',
      '500mg',
      'مضاد حيوي',
      'مرتين يومياً',
      'بعد الأكل',
      5,
      14,
      '08:00 م',
      true,
      Icons.medication_rounded,
      const Color(0xFFEF4444),
    ),
    _Med(
      'فيتامين D',
      '1000 IU',
      'مكمل غذائي',
      'مرة يومياً',
      'مع الأكل',
      22,
      30,
      '09:00 ص',
      true,
      Icons.wb_sunny_rounded,
      const Color(0xFFF59E0B),
    ),
    _Med(
      'لوراتادين',
      '10mg',
      'مضاد حساسية',
      'عند الحاجة',
      '',
      8,
      10,
      null,
      true,
      Icons.air_rounded,
      const Color(0xFF3B82F6),
    ),
    _Med(
      'ميتفورمين',
      '500mg',
      'سكري',
      'مرتين يومياً',
      'بعد الأكل',
      28,
      60,
      '07:00 ص',
      true,
      Icons.bloodtype_rounded,
      const Color(0xFF10B981),
    ),
    _Med(
      'أوميبرازول',
      '20mg',
      'معدة',
      'مرة يومياً',
      'قبل النوم',
      0,
      30,
      null,
      false,
      Icons.medication_liquid_rounded,
      const Color(0xFF8B5CF6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_Med> get _filteredMeds {
    if (_selectedFilter == 0) return _medications;
    if (_selectedFilter == 1) {
      return _medications.where((m) => m.active).toList();
    }
    if (_selectedFilter == 2) {
      return _medications.where((m) => m.nextDose != null).toList();
    }
    return _medications.where((m) => !m.active).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(8, topPad + 8, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border.withAlpha(40),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'أدويتي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showRefillSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'إعادة تعبئة',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              color: AppColors.surface,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textLight,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                tabs: const [
                  Tab(text: 'قائمة الأدوية'),
                  Tab(text: 'الجدول اليومي'),
                  Tab(text: 'الالتزام'),
                ],
              ),
            ),

            // Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMedicationsList(),
                  _buildScheduleView(),
                  _buildAdherenceView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsList() {
    final meds = _filteredMeds;
    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final sel = _selectedFilter == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = i),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: sel ? null : Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _filters[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppColors.textMedium,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Summary card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem(
                  '${_medications.length}',
                  'إجمالي',
                  Icons.medication_rounded,
                ),
                _summaryItem(
                  '${_medications.where((m) => m.active).length}',
                  'نشط',
                  Icons.check_circle_rounded,
                ),
                _summaryItem(
                  '${_medications.where((m) => m.nextDose != null).length}',
                  'اليوم',
                  Icons.schedule_rounded,
                ),
              ],
            ),
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: meds.length,
            itemBuilder: (_, i) => _buildMedCard(meds[i]),
          ),
        ),
      ],
    );
  }

  Widget _summaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
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
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildMedCard(_Med med) {
    final progress = med.total > 0 ? med.remaining / med.total : 0.0;
    final isLow = med.remaining <= 3 && med.active;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: isLow
            ? Border.all(color: AppColors.error.withAlpha(40))
            : Border.all(color: AppColors.border.withAlpha(40)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: med.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(med.icon, color: med.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          med.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          med.dose,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${med.category} • ${med.frequency}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMedium,
                      ),
                    ),
                    if (med.note.isNotEmpty)
                      Text(
                        med.note,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                      ),
                  ],
                ),
              ),
              if (med.nextDose != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.alarm_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        med.nextDose!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!med.active)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'منتهي',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
            ],
          ),
          if (med.active) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(
                        isLow ? AppColors.error : med.color,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${med.remaining}/${med.total}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isLow ? AppColors.error : AppColors.textMedium,
                  ),
                ),
              ],
            ),
            if (isLow)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: GestureDetector(
                  onTap: () => _requestRefill(med),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'الكمية منخفضة — اطلب إعادة تعبئة',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleView() {
    final scheduled = _medications
        .where((m) => m.nextDose != null && m.active)
        .toList();
    final times = [
      '07:00 ص',
      '08:00 ص',
      '09:00 ص',
      '12:00 م',
      '02:00 م',
      '08:00 م',
      '10:00 م',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Today header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.today_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'جدول اليوم',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'الثلاثاء، 8 أبريل 2026',
                    style: TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${scheduled.length} أدوية',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Timeline
        ...times.map((time) {
          final medsAtTime = _medications
              .where((m) => m.nextDose == time && m.active)
              .toList();
          if (medsAtTime.isEmpty) return const SizedBox();
          return _buildTimeSlot(time, medsAtTime);
        }),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTimeSlot(String time, List<_Med> meds) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textMedium,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
              ),
              Container(
                width: 2,
                height: 40 * meds.length.toDouble(),
                color: AppColors.border,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: meds
                  .map(
                    (m) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: m.color.withAlpha(30)),
                      ),
                      child: Row(
                        children: [
                          Icon(m.icon, color: m.color, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${m.name} ${m.dose}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  m.note,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم تسجيل تناول ${m.name} ✓'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withAlpha(15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'تم ✓',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ═══ ADHERENCE & COMPLIANCE TAB ═══════════════════════════
  Widget _buildAdherenceView() {
    final takenDays = _weeklyAdherence.values.where((v) => v).length;
    final weekPct = (takenDays / 7 * 100).toInt();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Streak card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withAlpha(40),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    Text(
                      '$_streak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سلسلة الالتزام 🔥',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_streak يوم متواصل من الالتزام بالدواء!',
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Weekly calendar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withAlpha(40)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'هذا الأسبوع',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: weekPct >= 80
                          ? const Color(0xFF10B981).withAlpha(15)
                          : const Color(0xFFF59E0B).withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$weekPct% التزام',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: weekPct >= 80
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _weeklyAdherence.entries
                    .map((e) => _dayDot(e.key, e.value))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Per-medication adherence
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withAlpha(40)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.medication_rounded,
                    color: AppColors.accent,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'نسبة الالتزام لكل دواء',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._medAdherence.entries.map(
                (e) => _medAdherenceRow(e.key, e.value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Reminders section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withAlpha(40)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'التذكيرات اليومية',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _reminderRow('ميتفورمين 500mg', '07:00 ص', true),
              _reminderRow('فيتامين D 1000 IU', '09:00 ص', true),
              _reminderRow('أموكسيسيلين 500mg', '08:00 م', false),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تفعيل جميع التذكيرات ✓'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.alarm_add_rounded, size: 16),
                  label: const Text(
                    'إضافة تذكير جديد',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF59E0B),
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Doctor compliance report
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withAlpha(10),
                AppColors.accent.withAlpha(10),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withAlpha(30)),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.assignment_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'تقرير الالتزام للطبيب',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'إنشاء تقرير مفصل يوضح مدى التزامك بالأدوية المزمنة — يمكنك مشاركته مع طبيبك في الزيارة القادمة',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showComplianceReport(),
                      icon: const Icon(Icons.preview_rounded, size: 16),
                      label: const Text(
                        'عرض التقرير',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تم مشاركة التقرير مع طبيبك عبر حكيم ✓',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share_rounded, size: 16),
                      label: const Text(
                        'أرسل للطبيب',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _dayDot(String day, bool taken) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: taken
                ? const Color(0xFF10B981).withAlpha(15)
                : const Color(0xFFEF4444).withAlpha(10),
            shape: BoxShape.circle,
            border: Border.all(
              color: taken ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              width: 2,
            ),
          ),
          child: Icon(
            taken ? Icons.check_rounded : Icons.close_rounded,
            size: 18,
            color: taken ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day.substring(0, 3),
          style: const TextStyle(fontSize: 9, color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _medAdherenceRow(String name, double pct) {
    final pctInt = (pct * 100).toInt();
    final color = pctInt >= 90
        ? const Color(0xFF10B981)
        : pctInt >= 70
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '$pctInt%',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reminderRow(String med, String time, bool enabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: enabled
            ? const Color(0xFFF59E0B).withAlpha(8)
            : AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: enabled
              ? const Color(0xFFF59E0B).withAlpha(30)
              : AppColors.border.withAlpha(40),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.alarm_rounded,
            size: 18,
            color: enabled ? const Color(0xFFF59E0B) : AppColors.textLight,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: enabled
                  ? const Color(0xFF10B981).withAlpha(15)
                  : AppColors.border.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              enabled ? 'مفعّل' : 'معطّل',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: enabled ? const Color(0xFF10B981) : AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComplianceReport() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.assignment_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'تقرير الالتزام الدوائي',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reportRow('الفترة', 'آخر 30 يوم'),
                _reportRow('نسبة الالتزام الكلية', '89%'),
                _reportRow('أيام الالتزام الكامل', '25 / 30'),
                _reportRow('سلسلة الالتزام الحالية', '$_streak يوم'),
                const Divider(color: AppColors.border, height: 20),
                const Text(
                  'تفصيل حسب الدواء:',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ..._medAdherence.entries.map(
                  (e) => _reportMedRow(e.key, e.value),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ملاحظة: المريض يُظهر التزاماً جيداً بالخطة العلاجية',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إغلاق',
                style: TextStyle(color: AppColors.textLight),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال التقرير لطبيبك عبر حكيم ✅'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text(
                'أرسل عبر حكيم',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportMedRow(String name, double pct) {
    final pctInt = (pct * 100).toInt();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
          ),
          Text(
            '$pctInt%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: pctInt >= 90
                  ? const Color(0xFF10B981)
                  : pctInt >= 70
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  void _requestRefill(_Med med) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'إعادة تعبئة',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('طلب إعادة تعبئة لـ ${med.name} ${med.dose}؟'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.local_shipping_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'التوصيل للمنزل خلال 24 ساعة',
                    style: TextStyle(fontSize: 12, color: AppColors.textMedium),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال طلب إعادة التعبئة ✓'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'تأكيد الطلب',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showRefillSheet() {
    final lowMeds = _medications
        .where((m) => m.remaining <= 5 && m.active)
        .toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
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
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'إعادة تعبئة ذكية',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${lowMeds.length} أدوية تحتاج إعادة تعبئة',
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
              const SizedBox(height: 16),
              ...lowMeds.map(
                (m) => ListTile(
                  leading: Icon(m.icon, color: m.color),
                  title: Text(
                    '${m.name} ${m.dose}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'متبقي ${m.remaining} من ${m.total}',
                    style: TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                  trailing: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم طلب إعادة التعبئة لجميع الأدوية ✓'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('طلب تعبئة الكل + توصيل'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _Med {
  final String name, dose, category, frequency, note;
  final int remaining, total;
  final String? nextDose;
  final bool active;
  final IconData icon;
  final Color color;
  const _Med(
    this.name,
    this.dose,
    this.category,
    this.frequency,
    this.note,
    this.remaining,
    this.total,
    this.nextDose,
    this.active,
    this.icon,
    this.color,
  );
}
