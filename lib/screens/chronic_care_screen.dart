import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class ChronicCareScreen extends StatefulWidget {
  const ChronicCareScreen({super.key});
  @override
  State<ChronicCareScreen> createState() => _ChronicCareScreenState();
}

class _ChronicCareScreenState extends State<ChronicCareScreen> {
  int _selectedPlan = -1;

  final _plans = [
    _CarePlan(
      'متابعة السكري',
      'إدارة شاملة لمرض السكري',
      Icons.bloodtype_rounded,
      const Color(0xFFF59E0B),
      'نشط',
      0.65,
      [
        _Step('فحص HbA1c', 'كل 3 أشهر', true, '2026-04-01'),
        _Step('فحص العيون', 'سنوي', true, '2026-01-15'),
        _Step('فحص القدمين', 'كل 6 أشهر', false, '2026-06-01'),
        _Step('فحص وظائف الكلى', 'سنوي', false, '2026-07-01'),
        _Step('تعديل الجرعة', 'حسب النتائج', true, '2026-03-28'),
      ],
      [
        _Tip(
          'حافظ على مستوى السكر بين 80-130 صائم',
          Icons.tips_and_updates_rounded,
        ),
        _Tip('مارس رياضة المشي 30 دقيقة يومياً', Icons.directions_walk_rounded),
        _Tip('راقب قدميك يومياً لأي تغيرات', Icons.visibility_rounded),
        _Tip('احتفظ بسجل يومي لقراءات السكر', Icons.edit_note_rounded),
      ],
    ),
    _CarePlan(
      'متابعة القلب',
      'متابعة صحة القلب والأوعية',
      Icons.favorite_rounded,
      const Color(0xFFEF4444),
      'نشط',
      0.45,
      [
        _Step('فحص ECG', 'كل 6 أشهر', true, '2026-02-10'),
        _Step('فحص الدهون', 'كل 3 أشهر', true, '2026-03-25'),
        _Step('إيكو القلب', 'سنوي', false, '2026-08-01'),
        _Step('فحص إجهاد القلب', 'سنوي', false, '2026-09-01'),
        _Step('مراجعة الأدوية', 'شهري', true, '2026-04-05'),
      ],
      [
        _Tip('حافظ على ضغط الدم أقل من 130/80', Icons.monitor_heart_rounded),
        _Tip('قلل الملح في طعامك (أقل من 2g)', Icons.no_food_rounded),
        _Tip(
          'تجنب التوتر ومارس تمارين الاسترخاء',
          Icons.self_improvement_rounded,
        ),
        _Tip('تناول أدويتك في مواعيدها بدقة', Icons.alarm_rounded),
      ],
    ),
    _CarePlan(
      'متابعة الأورام',
      'متابعة ما بعد العلاج',
      Icons.health_and_safety_rounded,
      const Color(0xFF8B5CF6),
      'متابعة',
      0.30,
      [
        _Step('فحص دم شامل', 'شهري', true, '2026-04-03'),
        _Step('أشعة مقطعية', 'كل 3 أشهر', false, '2026-06-15'),
        _Step('مراجعة الأورام', 'شهري', true, '2026-04-01'),
        _Step('تقييم نفسي', 'كل 3 أشهر', false, '2026-05-01'),
      ],
      [
        _Tip(
          'حافظ على التغذية السليمة والبروتين الكافي',
          Icons.restaurant_rounded,
        ),
        _Tip('بلّغ فوراً عن أي أعراض جديدة', Icons.warning_rounded),
        _Tip('النوم الكافي 7-9 ساعات يومياً مهم جداً', Icons.bedtime_rounded),
        _Tip('الدعم النفسي جزء أساسي من العلاج', Icons.psychology_rounded),
      ],
    ),
    _CarePlan(
      'متابعة الكلى',
      'حماية وظائف الكلى',
      Icons.water_drop_rounded,
      const Color(0xFF3B82F6),
      'وقائي',
      0.80,
      [
        _Step('فحص الكرياتينين', 'كل 3 أشهر', true, '2026-04-03'),
        _Step('تحليل بول', 'كل 3 أشهر', true, '2026-04-03'),
        _Step('قياس ضغط الدم', 'أسبوعي', true, '2026-04-07'),
        _Step('مراجعة الطبيب', 'كل 3 أشهر', false, '2026-06-01'),
      ],
      [
        _Tip('اشرب 2-3 لترات ماء يومياً', Icons.water_rounded),
        _Tip('قلل البروتين إذا طلب الطبيب', Icons.egg_alt_rounded),
        _Tip('راقب ضغط الدم بانتظام', Icons.monitor_heart_rounded),
        _Tip('تجنب المسكنات دون استشارة', Icons.medication_rounded),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
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
                      'برامج الرعاية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _selectedPlan < 0
                  ? _buildPlansList()
                  : _buildPlanDetail(_plans[_selectedPlan]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'برامج مخصصة لك',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'خطط متابعة ذكية مبنية على سجلك الطبي',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.route_rounded, size: 48, color: Colors.white24),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ..._plans.asMap().entries.map((e) => _buildPlanCard(e.key, e.value)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildPlanCard(int idx, _CarePlan plan) {
    final completedSteps = plan.steps.where((s) => s.done).length;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPlan = idx);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: plan.color.withAlpha(30)),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: plan.color.withAlpha(15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(plan.icon, color: plan.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        plan.desc,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
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
                    color: plan.color.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    plan.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: plan.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: plan.progress,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(plan.color),
                      minHeight: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$completedSteps/${plan.steps.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: plan.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDetail(_CarePlan plan) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Back + title
        GestureDetector(
          onTap: () => setState(() => _selectedPlan = -1),
          child: Row(
            children: [
              Icon(Icons.arrow_forward_rounded, size: 18, color: plan.color),
              const SizedBox(width: 8),
              Text(
                'العودة للبرامج',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: plan.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Plan header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: plan.color.withAlpha(10),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: plan.color.withAlpha(30)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(plan.icon, color: plan.color, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: plan.color,
                          ),
                        ),
                        Text(
                          plan.desc,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: plan.progress,
                  backgroundColor: plan.color.withAlpha(30),
                  valueColor: AlwaysStoppedAnimation(plan.color),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الإنجاز: ${(plan.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: plan.color,
                    ),
                  ),
                  Text(
                    '${plan.steps.where((s) => s.done).length} من ${plan.steps.length} مكتمل',
                    style: TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Steps timeline
        const SectionHeader(
          title: 'خطوات المتابعة',
          icon: Icons.checklist_rounded,
        ),
        const SizedBox(height: 8),
        ...plan.steps.asMap().entries.map(
          (e) => _buildStep(e.key, e.value, plan),
        ),
        const SizedBox(height: 20),

        // Tips
        const SectionHeader(title: 'نصائح مهمة', icon: Icons.lightbulb_rounded),
        const SizedBox(height: 8),
        ...plan.tips.map((t) => _buildTip(t, plan.color)),

        const SizedBox(height: 20),

        // Actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حجز موعد المتابعة القادم ✓'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                label: const Text('حجز متابعة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                      content: Text('تم مشاركة التقرير مع طبيبك ✓'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.share_rounded, size: 16),
                label: const Text('مشاركة تقرير'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: plan.color,
                  side: BorderSide(color: plan.color),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStep(int idx, _Step step, _CarePlan plan) {
    final isLast = idx == plan.steps.length - 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: step.done ? plan.color : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: step.done
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : Center(
                      child: Text(
                        '${idx + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: step.done ? plan.color.withAlpha(60) : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: step.done ? plan.color.withAlpha(8) : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: step.done
                    ? plan.color.withAlpha(20)
                    : AppColors.border.withAlpha(40),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: step.done ? plan.color : AppColors.textDark,
                          decoration: step.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${step.freq} • ${step.date}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (step.done)
                  Icon(Icons.check_circle_rounded, size: 18, color: plan.color)
                else
                  const Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: AppColors.textLight,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTip(_Tip tip, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(tip.icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip.text,
              style: const TextStyle(fontSize: 12, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarePlan {
  final String name, desc;
  final IconData icon;
  final Color color;
  final String status;
  final double progress;
  final List<_Step> steps;
  final List<_Tip> tips;
  const _CarePlan(
    this.name,
    this.desc,
    this.icon,
    this.color,
    this.status,
    this.progress,
    this.steps,
    this.tips,
  );
}

class _Step {
  final String name, freq;
  final bool done;
  final String date;
  const _Step(this.name, this.freq, this.done, this.date);
}

class _Tip {
  final String text;
  final IconData icon;
  const _Tip(this.text, this.icon);
}
