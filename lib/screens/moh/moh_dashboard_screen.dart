import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/moh_service.dart';
import '../../services/theme_service.dart';
import '../../theme.dart';

class MohDashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onTabSwitch;
  const MohDashboardScreen({super.key, this.onTabSwitch});
  @override
  State<MohDashboardScreen> createState() => _MohDashboardScreenState();
}

class _MohDashboardScreenState extends State<MohDashboardScreen> {
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await MohService.getDashboard();
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
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            border: Border(
              bottom: BorderSide(color: Colors.white.withAlpha(8)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🏛️', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'وزارة الصحة — الأردن',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'لوحة القيادة المركزية',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'مباشر',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showThemePicker,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ThemeService().primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.palette_rounded,
                        color: ThemeService().primary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF10B981)),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Key metrics grid
                        _sectionTitle('📊 المؤشرات الرئيسية'),
                        const SizedBox(height: 8),
                        _metricsGrid(),
                        const SizedBox(height: 20),
                        // National capacity
                        _sectionTitle('🏥 السعة الوطنية'),
                        const SizedBox(height: 8),
                        _capacityCard(),
                        const SizedBox(height: 20),
                        // Alerts
                        _sectionTitle('⚠️ التنبيهات الوطنية'),
                        const SizedBox(height: 8),
                        _alertsList(),
                        const SizedBox(height: 20),
                        // Quick links
                        _sectionTitle('🔗 إجراءات سريعة'),
                        const SizedBox(height: 8),
                        _quickActions(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.white.withAlpha(200),
      ),
    );
  }

  Widget _metricsGrid() {
    final stats = _data['stats'] as Map<String, dynamic>? ?? {};
    final items = <_MetricItem>[
      _MetricItem(
        'المستشفيات',
        '${stats['totalHospitals'] ?? 42}',
        Icons.local_hospital_rounded,
        const Color(0xFF10B981),
      ),
      _MetricItem(
        'إجمالي الأسرّة',
        '${stats['totalBeds'] ?? 12540}',
        Icons.bed_rounded,
        AppColors.info,
      ),
      _MetricItem(
        'نسبة الإشغال',
        '${stats['occupancyRate'] ?? 78}%',
        Icons.pie_chart_rounded,
        const Color(0xFFF59E0B),
      ),
      _MetricItem(
        'المرضى اليوم',
        '${stats['patientsToday'] ?? 3420}',
        Icons.people_rounded,
        AppColors.primary,
      ),
      _MetricItem(
        'حالات الطوارئ',
        '${stats['emergencyToday'] ?? 186}',
        Icons.warning_amber_rounded,
        AppColors.error,
      ),
      _MetricItem(
        'الأطباء الفعّالون',
        '${stats['activeDoctors'] ?? 2180}',
        Icons.person_rounded,
        const Color(0xFF8B5CF6),
      ),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.0,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: item.color.withAlpha(20)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: item.color, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: item.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withAlpha(100),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _capacityCard() {
    final capacity = _data['capacity'] as Map<String, dynamic>? ?? {};
    final regions =
        (capacity['regions'] as List?)?.cast<Map<String, dynamic>>() ??
        [
          {'name': 'عمّان', 'beds': 4200, 'occupied': 3360, 'pct': 80},
          {'name': 'إربد', 'beds': 2100, 'occupied': 1575, 'pct': 75},
          {'name': 'الزرقاء', 'beds': 1800, 'occupied': 1530, 'pct': 85},
          {'name': 'العقبة', 'beds': 800, 'occupied': 560, 'pct': 70},
          {'name': 'الكرك', 'beds': 650, 'occupied': 455, 'pct': 70},
        ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: regions.map((r) {
          final pct = (r['pct'] as num?)?.toDouble() ?? 0;
          Color barColor;
          if (pct > 90) {
            barColor = AppColors.error;
          } else if (pct > 75) {
            barColor = const Color(0xFFF59E0B);
          } else {
            barColor = const Color(0xFF10B981);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      r['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${r['occupied']}/${r['beds']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withAlpha(100),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${pct.toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: barColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    backgroundColor: Colors.white.withAlpha(8),
                    color: barColor,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _alertsList() {
    final alerts = <Map<String, dynamic>>[
      {
        'title': 'نسبة إشغال مرتفعة — الزرقاء',
        'type': 'warning',
        'icon': Icons.warning_rounded,
      },
      {
        'title': 'نقص أدوية ضغط — مستشفى البشير',
        'type': 'critical',
        'icon': Icons.medication_rounded,
      },
      {
        'title': 'حالة وبائية مشتبهة — العقبة',
        'type': 'critical',
        'icon': Icons.coronavirus_rounded,
      },
    ];

    return Column(
      children: alerts.map((a) {
        final isCritical = a['type'] == 'critical';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCritical
                ? AppColors.error.withAlpha(8)
                : const Color(0xFFF59E0B).withAlpha(8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCritical
                  ? AppColors.error.withAlpha(30)
                  : const Color(0xFFF59E0B).withAlpha(30),
            ),
          ),
          child: Row(
            children: [
              Icon(
                a['icon'] as IconData,
                color: isCritical ? AppColors.error : const Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  a['title'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCritical
                        ? AppColors.error
                        : const Color(0xFFF59E0B),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                size: 18,
                color: Colors.white.withAlpha(60),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _quickActions() {
    final actions = [
      [
        'تقرير يومي',
        Icons.description_rounded,
        const Color(0xFF10B981),
        3,
      ], // Reports tab
      [
        'إحصائيات',
        Icons.bar_chart_rounded,
        AppColors.primary,
        2,
      ], // Analytics tab
      [
        'وبائيات',
        Icons.coronavirus_rounded,
        AppColors.error,
        4,
      ], // Epidemic tab
      [
        'العدالة',
        Icons.balance_rounded,
        const Color(0xFF8B5CF6),
        5,
      ], // Equity tab
    ];
    return Row(
      children: actions.map<Widget>((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onTabSwitch?.call(a[3] as int);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: (a[2] as Color).withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (a[2] as Color).withAlpha(30)),
              ),
              child: Column(
                children: [
                  Icon(a[1] as IconData, color: a[2] as Color, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    a[0] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(140),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showThemePicker() {
    HapticFeedback.mediumImpact();
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

class _MetricItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _MetricItem(this.label, this.value, this.icon, this.color);
}
