import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
//  TERYAQ SMART HEALTH — MoH Equity Analytics Screen
//  Booking equity between governorates + doctor distribution
//  Demand prediction + resource recommendations
// ═══════════════════════════════════════════════════════════════

class MohEquityScreen extends StatefulWidget {
  const MohEquityScreen({super.key});
  @override
  State<MohEquityScreen> createState() => _MohEquityScreenState();
}

class _MohEquityScreenState extends State<MohEquityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _governorates = <_GovData>[
    _GovData('عمّان', 42.0, 1200, 8.5, 120, 1.0),
    _GovData('الزرقاء', 15.0, 380, 5.2, 45, 1.3),
    _GovData('إربد', 13.0, 290, 6.1, 52, 1.2),
    _GovData('البلقاء', 4.5, 85, 4.8, 18, 1.6),
    _GovData('الكرك', 3.5, 60, 4.2, 14, 1.8),
    _GovData('العقبة', 2.8, 55, 5.5, 12, 1.4),
    _GovData('معان', 1.8, 28, 3.1, 6, 2.4),
    _GovData('الطفيلة', 1.0, 18, 3.5, 4, 2.1),
    _GovData('مادبا', 1.6, 32, 4.0, 8, 1.9),
    _GovData('جرش', 1.2, 22, 3.8, 5, 2.0),
    _GovData('عجلون', 0.8, 14, 3.2, 3, 2.3),
    _GovData('المفرق', 1.4, 24, 3.0, 4, 2.6),
  ];

  final _recommendations = <_Recommendation>[
    _Recommendation(
      '⚕️',
      'نقل 8 أطباء باطنية للجنوب',
      'معان والطفيلة والكرك تعاني من نقص حاد في الأطباء. نسبة طبيب : مريض = 1:2400',
      'عالية',
      const Color(0xFFEF4444),
      'فوري',
    ),
    _Recommendation(
      '🏥',
      'توسيع طاقة مستشفى الزرقاء',
      'ضغط 130% على طاقة المستشفى. يحتاج 80 سرير إضافي وطاقم تمريض',
      'عالية',
      const Color(0xFFEF4444),
      'خلال 3 أشهر',
    ),
    _Recommendation(
      '🚑',
      'وحدات صحة متنقلة للريف',
      'المناطق النائية في المفرق وعجلون لا تصل إليها خدمات بسهولة',
      'متوسطة',
      const Color(0xFFF59E0B),
      'خلال 6 أشهر',
    ),
    _Recommendation(
      '💻',
      'توسيع خدمات التطبيب عن بعد',
      'يمكن تغطية 40% من استشارات المحافظات البعيدة عبر التيليميدسين',
      'متوسطة',
      const Color(0xFFF59E0B),
      'خلال شهر',
    ),
    _Recommendation(
      '📊',
      'نظام حصص عادل للمواعيد',
      'عمّان تستحوذ على 68% من المواعيد مع 42% من السكان فقط',
      'عالية',
      const Color(0xFFEF4444),
      'فوري',
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
            Tab(text: 'الحجز'),
            Tab(text: 'الأطباء'),
            Tab(text: 'التوصيات'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEquityTab(),
              _buildDoctorsTab(),
              _buildRecommendationsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(double topPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 12),
      color: const Color(0xFF1E293B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('⚖️', style: TextStyle(fontSize: 22)),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تحليلات العدالة الصحية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'توزيع الخدمات والموارد بين المحافظات',
                    style: TextStyle(fontSize: 12, color: Color(0xFF10B981)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _chip('12', 'محافظة', const Color(0xFF3B82F6))),
              const SizedBox(width: 8),
              Expanded(child: _chip('2,208', 'طبيب', const Color(0xFF10B981))),
              const SizedBox(width: 8),
              Expanded(child: _chip('68%', 'الحجوزات لعمّان', const Color(0xFFF59E0B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              fontSize: 12,
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

  Widget _buildEquityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF59E0B).withAlpha(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('📊', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'نسبة الحجوزات من السكان',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._governorates.map((g) => _EquityRow(gov: g)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🏆 أعلى 3 محافظات انتفاعاً',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ..._governorates
                    .take(3)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (e) => _RankRow(
                        rank: e.key + 1,
                        name: e.value.name,
                        value:
                            '${e.value.appointmentsPer100k.toStringAsFixed(0)} حجز/100k',
                      ),
                    ),
                const Divider(color: Colors.white12, height: 16),
                const Text(
                  '⚠️ أقل 3 محافظات انتفاعاً',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 8),
                ..._governorates.reversed
                    .take(3)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (e) => _RankRow(
                        rank: _governorates.length - e.key,
                        name: e.value.name,
                        value:
                            '${e.value.appointmentsPer100k.toStringAsFixed(0)} حجز/100k',
                        isLow: true,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نسبة الأطباء لكل 10,000 مواطن',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ..._governorates.map((g) {
                  final ratio = g.doctorsPer10k;
                  final color = ratio >= 6
                      ? const Color(0xFF10B981)
                      : ratio >= 4
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFEF4444);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text(
                            g.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (ratio / 10).clamp(0.0, 1.0),
                              backgroundColor: Colors.white.withAlpha(15),
                              valueColor: AlwaysStoppedAnimation(color),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ratio.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEF4444).withAlpha(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🚨', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Text(
                      'مناطق تحتاج تعزيز طبي فوري',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._governorates
                    .where((g) => g.doctorsPer10k < 4)
                    .map(
                      (g) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${g.name}: ${g.doctorsPer10k.toStringAsFixed(1)} طبيب/10k مواطن',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _recommendations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _RecommendationCard(rec: _recommendations[i]),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────

class _EquityRow extends StatelessWidget {
  final _GovData gov;
  const _EquityRow({required this.gov});

  @override
  Widget build(BuildContext context) {
    final equityIndex = gov.equityIndex;
    final color = equityIndex <= 1.2
        ? const Color(0xFF10B981)
        : equityIndex <= 1.8
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 65,
            child: Text(
              gov.name,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (gov.populationPct / 50).clamp(0.0, 1.0),
                backgroundColor: Colors.white.withAlpha(15),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${gov.populationPct.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 10, color: Colors.white54),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${equityIndex.toStringAsFixed(1)}×',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final int rank;
  final String name;
  final String value;
  final bool isLow;
  const _RankRow({
    required this.rank,
    required this.name,
    required this.value,
    this.isLow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isLow
                  ? const Color(0xFFEF4444).withAlpha(20)
                  : const Color(0xFF10B981).withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isLow
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final _Recommendation rec;
  const _RecommendationCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rec.priorityColor.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(rec.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  rec.title,
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
                  color: rec.priorityColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rec.priority,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: rec.priorityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rec.body,
            style: const TextStyle(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 12,
                color: Colors.white38,
              ),
              const SizedBox(width: 4),
              Text(
                rec.timeline,
                style: const TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Data models ────────────────────────────────────────────────

class _GovData {
  final String name;
  final double populationPct;
  final double appointmentsPer100k;
  final double doctorsPer10k;
  final int totalDoctors;
  final double equityIndex;
  const _GovData(
    this.name,
    this.populationPct,
    this.appointmentsPer100k,
    this.doctorsPer10k,
    this.totalDoctors,
    this.equityIndex,
  );
}

class _Recommendation {
  final String icon;
  final String title;
  final String body;
  final String priority;
  final Color priorityColor;
  final String timeline;
  const _Recommendation(
    this.icon,
    this.title,
    this.body,
    this.priority,
    this.priorityColor,
    this.timeline,
  );
}
