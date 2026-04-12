import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/hms_service.dart';
import '../../services/theme_service.dart';
import '../../theme.dart';
import 'hms_checkin_screen.dart';
import 'hms_triage_screen.dart';

import 'hms_tracking_screen.dart';
import 'hms_wayfinding_screen.dart';

class HmsDashboardScreen extends StatefulWidget {
  final String role;
  const HmsDashboardScreen({super.key, required this.role});
  @override
  State<HmsDashboardScreen> createState() => _HmsDashboardScreenState();
}

class _HmsDashboardScreenState extends State<HmsDashboardScreen> {
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await HmsService.getDashboard();
    if (mounted) {
      setState(() {
        _data = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(topPad),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatGrid(),
                    const SizedBox(height: 20),
                    _buildTriageBar(),
                    const SizedBox(height: 20),
                    _buildDepartmentLoad(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double topPad) {
    String roleIcon;
    String roleLabel;
    switch (widget.role) {
      case 'doctor':
        roleIcon = '👨‍⚕️';
        roleLabel = 'لوحة الطبيب';
        break;
      case 'nurse':
        roleIcon = '👩‍⚕️';
        roleLabel = 'لوحة التمريض';
        break;
      default:
        roleIcon = '🏥';
        roleLabel = 'لوحة الاستقبال';
    }

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(roleIcon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roleLabel,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'نظام إدارة المستشفى — مستشفى الأردن',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(120),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showThemePicker();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: ThemeService().primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.palette_rounded,
                    color: ThemeService().primary,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withAlpha(40)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withAlpha(100),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'بث مباشر • تحديث تلقائي',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    final stats = [
      _Stat(
        'مرضى اليوم',
        '${_data['patientsToday'] ?? 0}',
        Icons.people_rounded,
        AppColors.primary,
      ),
      _Stat(
        'حالات حرجة',
        '${_data['criticalPatients'] ?? 0}',
        Icons.warning_rounded,
        AppColors.error,
      ),
      _Stat(
        'بالانتظار',
        '${_data['waitingPatients'] ?? 0}',
        Icons.hourglass_top_rounded,
        AppColors.warning,
      ),
      _Stat(
        'قيد العلاج',
        '${_data['inTreatment'] ?? 0}',
        Icons.medical_services_rounded,
        AppColors.info,
      ),
      _Stat(
        'أسرّة متاحة',
        '${_data['availableBeds'] ?? 0}',
        Icons.bed_rounded,
        AppColors.success,
      ),
      _Stat(
        'إسعاف قادم',
        '${_data['emsIncoming'] ?? 0}',
        Icons.local_hospital_rounded,
        const Color(0xFFEF4444),
      ),
      _Stat(
        'تنبيهات',
        '${_data['pendingAlerts'] ?? 0}',
        Icons.notifications_active_rounded,
        const Color(0xFFF59E0B),
      ),
      _Stat(
        'التقييم',
        '${_data['avgRating'] ?? 0}/3',
        Icons.star_rounded,
        const Color(0xFFA855F7),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: stats.map((s) => _statCard(s)).toList(),
    );
  }

  Widget _statCard(_Stat s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(s.icon, color: s.color, size: 20),
              const Spacer(),
              Text(
                s.value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: s.color,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            s.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriageBar() {
    final triage = _data['triageBreakdown'] as Map<String, dynamic>? ?? {};
    final red = (triage['red'] ?? 0) as int;
    final yellow = (triage['yellow'] ?? 0) as int;
    final green = (triage['green'] ?? 0) as int;
    final total = red + yellow + green;
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الفرز الطبي (Triage)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white.withAlpha(200),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  if (red > 0)
                    Expanded(
                      flex: red,
                      child: Container(
                        color: AppColors.error,
                        child: Center(
                          child: Text(
                            '$red',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (yellow > 0)
                    Expanded(
                      flex: yellow,
                      child: Container(
                        color: AppColors.warning,
                        child: Center(
                          child: Text(
                            '$yellow',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (green > 0)
                    Expanded(
                      flex: green,
                      child: Container(
                        color: AppColors.success,
                        child: Center(
                          child: Text(
                            '$green',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _triageLegend('حرج', AppColors.error),
              const SizedBox(width: 16),
              _triageLegend('متوسط', AppColors.warning),
              const SizedBox(width: 16),
              _triageLegend('بسيط', AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _triageLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(150)),
        ),
      ],
    );
  }

  Widget _buildDepartmentLoad() {
    final depts =
        (_data['departmentLoad'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (depts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حمل الأقسام',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white.withAlpha(200),
            ),
          ),
          const SizedBox(height: 12),
          ...depts.map((d) {
            final count = (d['count'] as int?) ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      d['name'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(160),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (count / 10).clamp(0.0, 1.0),
                        backgroundColor: Colors.white.withAlpha(10),
                        valueColor: AlwaysStoppedAnimation(
                          count > 5 ? AppColors.error : AppColors.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    void push(Widget screen) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    final actions = [
      _QA(
        'تسجيل مريض',
        Icons.person_add_rounded,
        AppColors.success,
        () => push(const HmsCheckinScreen()),
      ),
      _QA(
        'فرز طبي',
        Icons.medical_information_rounded,
        AppColors.warning,
        () => push(const HmsTriageScreen()),
      ),
      _QA(
        'تتبع مريض',
        Icons.location_searching_rounded,
        AppColors.info,
        () => push(const HmsTrackingScreen()),
      ),
      _QA(
        'ملاحة داخلية',
        Icons.map_rounded,
        const Color(0xFFA855F7),
        () => push(const HmsWayfindingScreen()),
      ),
    ];

    return Row(
      children: actions
          .map(
            (a) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    a.onTap();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: a.color.withAlpha(15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: a.color.withAlpha(30)),
                    ),
                    child: Column(
                      children: [
                        Icon(a.icon, color: a.color, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          a.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: a.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  void _showThemePicker() {
    final ts = ThemeService();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
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
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'اختر لون التطبيق',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppThemeColor.values.map((t) {
                  final p = ThemeService.palettes[t]!;
                  final sel = ts.currentTheme == t;
                  return GestureDetector(
                    onTap: () {
                      ts.setTheme(t);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: Container(
                      width: 96,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel
                            ? p.primary.withAlpha(25)
                            : Colors.white.withAlpha(6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: sel ? p.primary : Colors.white.withAlpha(10),
                          width: sel ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: p.gradient,
                              shape: BoxShape.circle,
                              border: sel
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                            child: sel
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.labelAr,
                            style: TextStyle(
                              color: sel ? p.primary : const Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.icon, this.color);
}

class _QA {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QA(this.label, this.icon, this.color, this.onTap);
}
