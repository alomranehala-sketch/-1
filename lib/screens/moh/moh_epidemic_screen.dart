import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
//  TERYAQ SMART HEALTH — MoH Epidemic Early Warning Screen
//  Real-time outbreak detection from lab data across Jordan
//  Community Health Index (CHI) + predictive alerting
// ═══════════════════════════════════════════════════════════════

class MohEpidemicScreen extends StatefulWidget {
  const MohEpidemicScreen({super.key});
  @override
  State<MohEpidemicScreen> createState() => _MohEpidemicScreenState();
}

class _MohEpidemicScreenState extends State<MohEpidemicScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDisease = 0;

  final _chiData = <_CHI>[
    _CHI('عمّان', 78.4, 0.5, const Color(0xFF10B981)),
    _CHI('الزرقاء', 65.2, -1.8, const Color(0xFFF59E0B)),
    _CHI('إربد', 72.1, 1.2, const Color(0xFF10B981)),
    _CHI('البلقاء', 81.3, 2.1, const Color(0xFF10B981)),
    _CHI('الكرك', 69.5, -0.3, const Color(0xFF10B981)),
    _CHI('العقبة', 74.8, 3.2, const Color(0xFF10B981)),
    _CHI('معان', 61.2, -4.5, const Color(0xFFEF4444)),
    _CHI('الطفيلة', 66.8, 0.8, const Color(0xFFF59E0B)),
    _CHI('مادبا', 79.1, 1.5, const Color(0xFF10B981)),
    _CHI('جرش', 70.3, 2.0, const Color(0xFF10B981)),
    _CHI('عجلون', 68.9, 0.2, const Color(0xFF10B981)),
    _CHI('المفرق', 58.7, -5.2, const Color(0xFFEF4444)),
  ];

  final _alerts = <_Alert>[
    _Alert(
      '🦠',
      'إنفلونزا فصلية — عمّان الشرق',
      '23 حالة مؤكدة هذا الأسبوع. ارتفاع بنسبة 47% عن الأسبوع الماضي.',
      'برتقالي',
      const Color(0xFFF59E0B),
      '2026-04-08',
      'إنفلونزا',
      true,
    ),
    _Alert(
      '🫁',
      'حالات سعال شديدة — الزرقاء',
      '14 حالة تمت إحالتها للمستشفى. يُشتبه في سلالة جديدة.',
      'أحمر',
      const Color(0xFFEF4444),
      '2026-04-07',
      'الجهاز التنفسي',
      true,
    ),
    _Alert(
      '🤒',
      'حمى غير مصنفة — معان',
      '8 حالات متفرقة. فرق المراقبة على الأرض للتحقيق.',
      'أصفر',
      const Color(0xFFFBBF24),
      '2026-04-06',
      'حمى',
      false,
    ),
    _Alert(
      '🦟',
      'رصد حشرات — وادي الأردن',
      'ارتفاع موسمي في بعوض الحمى. لا حالات مؤكدة حتى الآن.',
      'أصفر',
      const Color(0xFFFBBF24),
      '2026-04-05',
      'ناقلات أمراض',
      false,
    ),
  ];

  final _diseases = const [
    'الكل',
    'إنفلونزا',
    'كوفيد',
    'حمى',
    'الجهاز التنفسي',
    'الجهاز الهضمي',
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

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        _buildHeader(topPad),
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF10B981),
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF10B981),
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: 'التنبيهات'),
            Tab(text: 'مؤشر CHI'),
            Tab(text: 'التوقعات'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildAlertsTab(), _buildCHITab(), _buildForecastTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(double topPad) {
    final alerts = _alerts.where((a) => a.isActive).length;
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 12),
      color: const Color(0xFF1E293B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('⚠️', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نظام الإنذار المبكر',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'مراقبة الأوبئة والأمراض وطنياً',
                      style: TextStyle(fontSize: 12, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
              if (alerts > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withAlpha(50),
                    ),
                  ),
                  child: Text(
                    '$alerts تنبيه',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metricChip(
                '${_chiData.length}',
                'محافظة مراقبة',
                const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              _metricChip(
                '${_alerts.where((a) => a.level == 'أحمر').length}',
                'إنذار أحمر',
                const Color(0xFFEF4444),
              ),
              const SizedBox(width: 8),
              _metricChip(
                '${_alerts.where((a) => a.level == 'برتقالي').length}',
                'إنذار برتقالي',
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withAlpha(200)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    return Column(
      children: [
        // Disease filter
        Container(
          height: 44,
          color: const Color(0xFF0F172A),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: _diseases.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final selected = i == _selectedDisease;
              return GestureDetector(
                onTap: () => setState(() => _selectedDisease = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF10B981)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _diseases[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.white54,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _alerts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _AlertCard(alert: _alerts[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildCHITab() {
    final avg = _chiData.fold(0.0, (s, c) => s + c.score) / _chiData.length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // National CHI Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🏛️', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المؤشر الوطني للصحة المجتمعية',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    Text(
                      avg.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'من 100 — جيد',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'المؤشرات حسب المحافظة',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ..._chiData.map((c) => _CHIRow(chi: c)),
        ],
      ),
    );
  }

  Widget _buildForecastTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ForecastCard(
            title: 'إنفلونزا موسمية — العشرة أيام القادمة',
            subtitle: 'احتمال 78% لارتفاع الحالات في عمّان والزرقاء',
            risk: 'مرتفع',
            riskColor: const Color(0xFFEF4444),
            icon: '🦠',
            recommendations: [
              'توزيع لقاحات الإنفلونزا في المناطق المتوقعة',
              'رفع جاهزية طوارئ مستشفيات عمّان الكبرى',
              'حملة توعية عبر وسائل التواصل الاجتماعي',
              'تفعيل بروتوكول الوقاية في المدارس',
            ],
          ),
          const SizedBox(height: 12),
          _ForecastCard(
            title: 'ضغط على طوارئ — نهاية الأسبوع',
            subtitle:
                'توقع بزيادة 35% في حالات الطوارئ خلال عطلة نهاية الأسبوع',
            risk: 'متوسط',
            riskColor: const Color(0xFFF59E0B),
            icon: '🏥',
            recommendations: [
              'جدولة طواقم إضافية في الطوارئ',
              'تفعيل بروتوكول الفرز السريع',
              'التنسيق بين المستشفيات لتوزيع الحالات',
            ],
          ),
          const SizedBox(height: 12),
          _ForecastCard(
            title: 'حساسية الربيع — إربد والشمال',
            subtitle: 'موسم الربيع يرفع حالات الحساسية 60% في المنطقة الشمالية',
            risk: 'منخفض',
            riskColor: const Color(0xFF10B981),
            icon: '🌸',
            recommendations: [
              'توفير مضادات الهيستامين في الصيدليات',
              'إرسال إشعارات للمرضى المعرضين للخطر',
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  final _Alert alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: alert.isActive
              ? alert.color.withAlpha(60)
              : Colors.white.withAlpha(10),
          width: alert.isActive ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(alert.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  alert.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: alert.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  alert.level,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: alert.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.body,
            style: const TextStyle(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  alert.disease,
                  style: const TextStyle(fontSize: 10, color: Colors.white54),
                ),
              ),
              const Spacer(),
              Text(
                alert.date,
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CHIRow extends StatelessWidget {
  final _CHI chi;
  const _CHIRow({required this.chi});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                chi.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: chi.score / 100,
                      backgroundColor: Colors.white.withAlpha(15),
                      valueColor: AlwaysStoppedAnimation(chi.color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              chi.score.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: chi.color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              chi.change >= 0
                  ? '+${chi.change.toStringAsFixed(1)}'
                  : chi.change.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 10,
                color: chi.change >= 0
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String risk;
  final Color riskColor;
  final String icon;
  final List<String> recommendations;
  const _ForecastCard({
    required this.title,
    required this.subtitle,
    required this.risk,
    required this.riskColor,
    required this.icon,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: riskColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'خطر $risk',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: riskColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'التوصيات:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          ...recommendations.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 4, left: 8),
                    decoration: BoxDecoration(
                      color: riskColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      r,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data models ────────────────────────────────────────────────

class _CHI {
  final String name;
  final double score;
  final double change;
  final Color color;
  const _CHI(this.name, this.score, this.change, this.color);
}

class _Alert {
  final String icon;
  final String title;
  final String body;
  final String level;
  final Color color;
  final String date;
  final String disease;
  final bool isActive;
  const _Alert(
    this.icon,
    this.title,
    this.body,
    this.level,
    this.color,
    this.date,
    this.disease,
    this.isActive,
  );
}
