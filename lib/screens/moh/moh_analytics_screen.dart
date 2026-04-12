import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/moh_service.dart';
import '../../theme.dart';

class MohAnalyticsScreen extends StatefulWidget {
  const MohAnalyticsScreen({super.key});
  @override
  State<MohAnalyticsScreen> createState() => _MohAnalyticsScreenState();
}

class _MohAnalyticsScreenState extends State<MohAnalyticsScreen> {
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await MohService.getAnalytics();
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
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 12),
          color: const Color(0xFF1E293B),
          child: const Row(
            children: [
              Text('🤖', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text(
                'التحليلات الذكية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
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
                        // Community Health Index
                        _healthIndexCard(),
                        const SizedBox(height: 16),
                        // Epidemic Detection
                        _epidemicCard(),
                        const SizedBox(height: 16),
                        // Demand Prediction
                        _demandPredictionCard(),
                        const SizedBox(height: 16),
                        // Doctor Distribution
                        _doctorDistCard(),
                        const SizedBox(height: 16),
                        // Booking Fairness
                        _fairnessCard(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _healthIndexCard() {
    final hi = _data['healthIndex'] as Map<String, dynamic>? ?? {};
    final score = (hi['score'] as num?)?.toDouble() ?? 82.0;
    final color = score > 80
        ? const Color(0xFF10B981)
        : score > 60
        ? const Color(0xFFF59E0B)
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(12), color.withAlpha(4)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🏥', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مؤشر صحة المجتمع',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Community Health Index (CHI)',
                      style: TextStyle(fontSize: 10, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Text(
                score.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Score bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.white.withAlpha(8),
              color: color,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          // Sub-indices
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _subIndex(
                'وفرة السعة',
                '${hi['capacityIndex'] ?? 85}%',
                const Color(0xFF10B981),
              ),
              _subIndex(
                'جودة الخدمة',
                '${hi['qualityIndex'] ?? 78}%',
                AppColors.primary,
              ),
              _subIndex(
                'الاستجابة',
                '${hi['responseIndex'] ?? 82}%',
                const Color(0xFF8B5CF6),
              ),
              _subIndex(
                'التغطية الجغرافية',
                '${hi['coverageIndex'] ?? 75}%',
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _subIndex(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(120)),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _epidemicCard() {
    final epi = _data['epidemicDetection'] as Map<String, dynamic>? ?? {};
    final alerts =
        (epi['alerts'] as List?)?.cast<Map<String, dynamic>>() ??
        [
          {
            'disease': 'إنفلونزا موسمية',
            'region': 'عمّان',
            'risk': 'moderate',
            'cases': 342,
          },
          {
            'disease': 'التهاب المعدة',
            'region': 'الزرقاء',
            'risk': 'low',
            'cases': 89,
          },
          {
            'disease': 'حالة تنفسية',
            'region': 'العقبة',
            'risk': 'high',
            'cases': 156,
          },
        ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🦠', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'الكشف الوبائي المبكر',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'AI-powered epidemic pattern detection',
            style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(80)),
          ),
          const SizedBox(height: 12),
          ...alerts.map((a) {
            final risk = a['risk'] as String? ?? 'low';
            Color riskColor;
            String riskLabel;
            switch (risk) {
              case 'high':
                riskColor = AppColors.error;
                riskLabel = 'مرتفع';
                break;
              case 'moderate':
                riskColor = const Color(0xFFF59E0B);
                riskLabel = 'متوسط';
                break;
              default:
                riskColor = const Color(0xFF10B981);
                riskLabel = 'منخفض';
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: riskColor.withAlpha(8),
                borderRadius: BorderRadius.circular(10),
                border: Border(right: BorderSide(color: riskColor, width: 3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['disease'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${a['region']} • ${a['cases']} حالة',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withAlpha(100),
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
                      color: riskColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      riskLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: riskColor,
                      ),
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

  Widget _demandPredictionCard() {
    // Simulated 7-day prediction
    final days = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    final rng = Random(42);
    final predictions = List.generate(7, (_) => 2800 + rng.nextInt(800));
    final maxPred = predictions.reduce(max);

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
              const Text('📈', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'التنبؤ بالطلب — 7 أيام',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'AI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final h = (predictions[i] / maxPred) * 100;
                final isToday = i == 0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${predictions[i]}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: isToday
                                ? AppColors.primary
                                : Colors.white.withAlpha(80),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isToday
                                  ? [
                                      AppColors.primary,
                                      AppColors.primary.withAlpha(100),
                                    ]
                                  : [
                                      Colors.white.withAlpha(25),
                                      Colors.white.withAlpha(10),
                                    ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          days[i],
                          style: TextStyle(
                            fontSize: 8,
                            color: isToday
                                ? AppColors.primary
                                : Colors.white.withAlpha(60),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _doctorDistCard() {
    final specialties = <Map<String, dynamic>>[
      {'name': 'باطنية', 'count': 420, 'color': AppColors.primary},
      {'name': 'جراحة', 'count': 310, 'color': const Color(0xFF10B981)},
      {'name': 'أطفال', 'count': 280, 'color': const Color(0xFFF59E0B)},
      {'name': 'قلب', 'count': 180, 'color': AppColors.error},
      {'name': 'نسائية', 'count': 240, 'color': const Color(0xFF8B5CF6)},
      {'name': 'عظام', 'count': 170, 'color': AppColors.info},
    ];
    final total = specialties.fold<int>(
      0,
      (sum, e) => sum + (e['count'] as int),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('👨‍⚕️', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'توزيع الأطباء حسب التخصص',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Proportional bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 18,
              child: Row(
                children: specialties.map((s) {
                  return Expanded(
                    flex: s['count'] as int,
                    child: Container(color: s['color'] as Color),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: specialties
                .map(
                  (s) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: s['color'] as Color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${s['name']} (${s['count']})',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withAlpha(120),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'إجمالي الأطباء: $total',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fairnessCard() {
    final regions = <Map<String, dynamic>>[
      {'name': 'عمّان', 'fairness': 88},
      {'name': 'إربد', 'fairness': 82},
      {'name': 'الزرقاء', 'fairness': 75},
      {'name': 'العقبة', 'fairness': 70},
      {'name': 'الكرك', 'fairness': 65},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('⚖️', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'عدالة توزيع الحجوزات',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...regions.map((r) {
            final f = (r['fairness'] as int).toDouble();
            final color = f > 80
                ? const Color(0xFF10B981)
                : f > 65
                ? const Color(0xFFF59E0B)
                : AppColors.error;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      r['name'] as String,
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
                        value: f / 100,
                        backgroundColor: Colors.white.withAlpha(8),
                        color: color,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${f.toInt()}%',
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
    );
  }
}
