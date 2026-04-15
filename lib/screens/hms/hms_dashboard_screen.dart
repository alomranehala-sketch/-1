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
  final ValueChanged<int>? onSwitchTab;
  const HmsDashboardScreen({super.key, required this.role, this.onSwitchTab});
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
        // Use API data if available, otherwise demo
        if (data.isNotEmpty && (data['patientsToday'] ?? 0) > 0) {
          _data = data;
        } else {
          _data = _demoData;
        }
        _loading = false;
      });
    }
  }

  static final Map<String, dynamic> _demoData = {
    'patientsToday': 47,
    'criticalPatients': 6,
    'waitingPatients': 12,
    'inTreatment': 23,
    'availableBeds': 34,
    'emsIncoming': 2,
    'pendingAlerts': 8,
    'avgRating': 4.2,
    'dischargedToday': 9,
    'surgeriesToday': 5,
    'occupancyRate': 72,
    'avgWaitTime': 18,
    'triageBreakdown': {'red': 6, 'yellow': 18, 'green': 23},
    'departmentLoad': [
      {'name': 'طوارئ', 'count': 8, 'capacity': 12},
      {'name': 'باطنية', 'count': 6, 'capacity': 10},
      {'name': 'قلب', 'count': 7, 'capacity': 8},
      {'name': 'جراحة', 'count': 4, 'capacity': 10},
      {'name': 'عظام', 'count': 3, 'capacity': 8},
      {'name': 'أطفال', 'count': 5, 'capacity': 8},
      {'name': 'عناية مركزة', 'count': 9, 'capacity': 10},
      {'name': 'نسائية', 'count': 3, 'capacity': 6},
    ],
    'recentAdmissions': [
      {
        'name': 'أحمد الخالدي',
        'time': '08:30',
        'dept': 'طوارئ',
        'triage': 'red',
      },
      {
        'name': 'فاطمة الحسن',
        'time': '09:15',
        'dept': 'نسائية',
        'triage': 'yellow',
      },
      {'name': 'عمر النعيمي', 'time': '10:00', 'dept': 'قلب', 'triage': 'red'},
      {
        'name': 'سارة المصري',
        'time': '11:20',
        'dept': 'أطفال',
        'triage': 'yellow',
      },
      {
        'name': 'خالد عبدالله',
        'time': '13:45',
        'dept': 'عظام',
        'triage': 'green',
      },
    ],
  };

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
                    const SizedBox(height: 16),
                    _buildExtraStats(),
                    const SizedBox(height: 20),
                    _buildTriageBar(),
                    const SizedBox(height: 20),
                    _buildRecentAdmissions(),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roleLabel,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'نظام إدارة المستشفى — مستشفى الأردن',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(120),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
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
        () => _switchTab(1),
      ),
      _Stat(
        'حالات حرجة',
        '${_data['criticalPatients'] ?? 0}',
        Icons.warning_rounded,
        AppColors.error,
        () => _switchTab(3),
      ),
      _Stat(
        'بالانتظار',
        '${_data['waitingPatients'] ?? 0}',
        Icons.hourglass_top_rounded,
        AppColors.warning,
        () => _switchTab(1),
      ),
      _Stat(
        'قيد العلاج',
        '${_data['inTreatment'] ?? 0}',
        Icons.medical_services_rounded,
        AppColors.info,
        () => _switchTab(1),
      ),
      _Stat(
        'أسرّة متاحة',
        '${_data['availableBeds'] ?? 0}',
        Icons.bed_rounded,
        AppColors.success,
        () => _switchTab(2),
      ),
      _Stat(
        'إسعاف قادم',
        '${_data['emsIncoming'] ?? 0}',
        Icons.local_hospital_rounded,
        const Color(0xFFEF4444),
        () => _switchTab(4),
      ),
      _Stat(
        'تنبيهات',
        '${_data['pendingAlerts'] ?? 0}',
        Icons.notifications_active_rounded,
        const Color(0xFFF59E0B),
        () => _switchTab(3),
      ),
      _Stat(
        'خرجوا اليوم',
        '${_data['dischargedToday'] ?? 0}',
        Icons.logout_rounded,
        const Color(0xFF10B981),
        null,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: stats.map((s) => _statCard(s)).toList(),
    );
  }

  void _switchTab(int index) {
    widget.onSwitchTab?.call(index);
  }

  Widget _statCard(_Stat s) {
    return GestureDetector(
      onTap: s.onTap != null
          ? () {
              HapticFeedback.lightImpact();
              s.onTap!();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: s.color.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(s.icon, color: s.color, size: 18),
                const Spacer(),
                Flexible(
                  child: Text(
                    s.value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: s.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              s.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha(150),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (s.onTap != null)
              Flexible(
                child: Text(
                  'اضغط للتفاصيل ←',
                  style: TextStyle(fontSize: 8, color: s.color.withAlpha(120)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraStats() {
    final occupancy = (_data['occupancyRate'] ?? 0) as int;
    final avgWait = (_data['avgWaitTime'] ?? 0) as int;
    final surgeries = (_data['surgeriesToday'] ?? 0) as int;

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
            'مؤشرات إضافية',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white.withAlpha(200),
            ),
          ),
          const SizedBox(height: 14),
          // Occupancy rate bar
          Row(
            children: [
              const Icon(
                Icons.hotel_rounded,
                color: Color(0xFF60A5FA),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'نسبة الإشغال',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha(160),
                          ),
                        ),
                        Text(
                          '$occupancy%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: occupancy > 85
                                ? AppColors.error
                                : occupancy > 70
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: occupancy / 100,
                        backgroundColor: Colors.white.withAlpha(15),
                        valueColor: AlwaysStoppedAnimation(
                          occupancy > 85
                              ? AppColors.error
                              : occupancy > 70
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Avg wait + surgeries row
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  Icons.timer_rounded,
                  'متوسط الانتظار',
                  '$avgWait د',
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  Icons.local_hospital_rounded,
                  'عمليات اليوم',
                  '$surgeries',
                  const Color(0xFFA855F7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withAlpha(130),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAdmissions() {
    final admissions =
        (_data['recentAdmissions'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
    if (admissions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_add_alt_1_rounded,
                color: Color(0xFF60A5FA),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'آخر الدخول',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withAlpha(200),
                ),
              ),
              const Spacer(),
              Text(
                'اليوم',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withAlpha(100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...admissions.map((a) {
            final triage = a['triage'] ?? 'green';
            final triageColor = triage == 'red'
                ? AppColors.error
                : triage == 'yellow'
                ? AppColors.warning
                : AppColors.success;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: triageColor.withAlpha(20),
                      shape: BoxShape.circle,
                      border: Border.all(color: triageColor.withAlpha(50)),
                    ),
                    child: Center(
                      child: Text(
                        (a['name'] as String? ?? '?').substring(0, 1),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: triageColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          a['dept'] ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withAlpha(120),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: triageColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      triage == 'red'
                          ? 'حرج'
                          : triage == 'yellow'
                          ? 'متوسط'
                          : 'بسيط',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: triageColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    a['time'] ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(100),
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

  Widget _buildTriageBar() {
    final triage = _data['triageBreakdown'] != null
        ? Map<String, dynamic>.from(_data['triageBreakdown'] as Map)
        : <String, dynamic>{};
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
        (_data['departmentLoad'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
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
  final VoidCallback? onTap;
  const _Stat(this.label, this.value, this.icon, this.color, [this.onTap]);
}

class _QA {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QA(this.label, this.icon, this.color, this.onTap);
}
