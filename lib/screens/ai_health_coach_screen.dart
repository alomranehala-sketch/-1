import 'package:flutter/material.dart';
import '../theme.dart';

/// AI Predictive Health Coach — المدرب الصحي الذكي
/// Analyzes your data + wearable → alerts before complications
class AiHealthCoachScreen extends StatefulWidget {
  const AiHealthCoachScreen({super.key});
  @override
  State<AiHealthCoachScreen> createState() => _AiHealthCoachScreenState();
}

class _AiHealthCoachScreenState extends State<AiHealthCoachScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _healthScore = 78;
  final _insights = [
    _Insight(
      'سكر التراكمي يرتفع تدريجياً',
      'HbA1c ارتفع من 6.2 إلى 6.8 خلال 6 أشهر — ينصح بمراجعة الطبيب وتعديل الجرعة.',
      Icons.trending_up_rounded,
      const Color(0xFFF59E0B),
      'متوسط',
    ),
    _Insight(
      'ضغط الدم مستقر ✅',
      'القراءات الأسبوعية ممتازة: 125/82 بالمعدل. استمر على نفس الروتين.',
      Icons.favorite_rounded,
      const Color(0xFF10B981),
      'جيد',
    ),
    _Insight(
      'تحتاج المزيد من المشي',
      'معدل خطواتك 3,200 يومياً — المطلوب 7,000 على الأقل للوقاية.',
      Icons.directions_walk_rounded,
      const Color(0xFF3B82F6),
      'تحسين',
    ),
    _Insight(
      'موعد فحص الكلى قريب',
      'آخر فحص كرياتينين كان قبل 5 أشهر — المطلوب كل 3 أشهر.',
      Icons.water_drop_rounded,
      const Color(0xFF8B5CF6),
      'تنبيه',
    ),
  ];

  final _dailyTasks = [
    _DailyTask(
      'قياس السكر — صائم',
      false,
      Icons.bloodtype_rounded,
      const Color(0xFFF59E0B),
    ),
    _DailyTask(
      'أدوية الصباح',
      true,
      Icons.medication_rounded,
      const Color(0xFF6366F1),
    ),
    _DailyTask(
      '30 دقيقة مشي',
      false,
      Icons.directions_walk_rounded,
      const Color(0xFF10B981),
    ),
    _DailyTask(
      'شرب 2 لتر ماء',
      false,
      Icons.water_rounded,
      const Color(0xFF3B82F6),
    ),
    _DailyTask(
      'قياس الضغط — مساءً',
      false,
      Icons.monitor_heart_rounded,
      const Color(0xFFEF4444),
    ),
    _DailyTask(
      'أدوية المساء',
      false,
      Icons.medication_rounded,
      const Color(0xFF6366F1),
    ),
  ];

  final _wearableData = {
    'heartRate': 72,
    'steps': 3247,
    'oxygen': 98,
    'sleep': 6.5,
    'calories': 1450,
  };

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
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
              title: const Text(
                'المدرب الصحي الذكي 🧠',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildHealthScore()),
            SliverToBoxAdapter(child: _buildWearableData()),
            SliverToBoxAdapter(child: _buildDailyTasks()),
            SliverToBoxAdapter(child: _buildInsights()),
            SliverToBoxAdapter(child: _buildPredictions()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScore() {
    final scoreColor = _healthScore >= 80
        ? const Color(0xFF10B981)
        : _healthScore >= 60
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF0F172A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نقاط صحتك اليوم',
                  style: TextStyle(color: AppColors.textMedium, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$_healthScore',
                      style: TextStyle(
                        color: scoreColor,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      '/100',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _healthScore >= 80
                      ? 'ممتاز! صحتك بحالة جيدة 🎉'
                      : 'يحتاج تحسين — تابع النصائح',
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Circular progress
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: _healthScore / 100,
                  strokeWidth: 8,
                  backgroundColor: AppColors.border.withAlpha(30),
                  color: scoreColor,
                ),
                Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    color: scoreColor,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWearableData() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'بيانات الأجهزة القابلة للارتداء',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.watch_rounded,
                      color: AppColors.success,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'متصل',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _wearableTile(
                'النبض',
                '${_wearableData['heartRate']}',
                'bpm',
                Icons.favorite_rounded,
                const Color(0xFFEF4444),
              ),
              const SizedBox(width: 8),
              _wearableTile(
                'الخطوات',
                '${_wearableData['steps']}',
                'خطوة',
                Icons.directions_walk_rounded,
                const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              _wearableTile(
                'الأكسجين',
                '${_wearableData['oxygen']}%',
                '',
                Icons.air_rounded,
                const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              _wearableTile(
                'النوم',
                '${_wearableData['sleep']}',
                'ساعة',
                Icons.bedtime_rounded,
                const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _wearableTile(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withAlpha(30)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: TextStyle(color: AppColors.textLight, fontSize: 9),
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: AppColors.textLight, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTasks() {
    final completedCount = _dailyTasks.where((t) => t.done).length;
    return Container(
      margin: const EdgeInsets.all(16),
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
              const Text(
                'مهامك اليومية',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$completedCount/${_dailyTasks.length}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: completedCount / _dailyTasks.length,
              backgroundColor: AppColors.border.withAlpha(30),
              color: AppColors.primary,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_dailyTasks.length, (i) {
            final t = _dailyTasks[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(
                  () => _dailyTasks[i] = _DailyTask(
                    t.name,
                    !t.done,
                    t.icon,
                    t.color,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: t.done
                            ? t.color.withAlpha(30)
                            : AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: t.done
                              ? t.color
                              : AppColors.border.withAlpha(60),
                        ),
                      ),
                      child: t.done
                          ? Icon(Icons.check_rounded, color: t.color, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      t.icon,
                      color: t.done ? t.color : AppColors.textLight,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.name,
                      style: TextStyle(
                        color: t.done ? AppColors.textLight : Colors.white,
                        fontSize: 13,
                        decoration: t.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تحليلات ذكية 🤖',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_insights.length, (i) {
            final ins = _insights[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ins.color.withAlpha(30)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ins.color.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(ins.icon, color: ins.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ins.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ins.color.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                ins.level,
                                style: TextStyle(
                                  color: ins.color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ins.detail,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
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

  Widget _buildPredictions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'تنبؤات AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _predictionRow('خطر ارتفاع السكر', 35, const Color(0xFFF59E0B)),
          const SizedBox(height: 8),
          _predictionRow('خطر مشكلة قلبية', 12, const Color(0xFF10B981)),
          const SizedBox(height: 8),
          _predictionRow('نقص فيتامين D', 65, const Color(0xFFEF4444)),
          const SizedBox(height: 12),
          const Text(
            '⚡ هذه تنبؤات مبنية على بياناتك الصحية وليست تشخيصاً طبياً',
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _predictionRow(String label, int percent, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        SizedBox(
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: Colors.white.withAlpha(20),
              color: color,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percent%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Insight {
  final String title, detail, level;
  final IconData icon;
  final Color color;
  const _Insight(this.title, this.detail, this.icon, this.color, this.level);
}

class _DailyTask {
  final String name;
  final bool done;
  final IconData icon;
  final Color color;
  const _DailyTask(this.name, this.done, this.icon, this.color);
}
