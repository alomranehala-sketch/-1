import 'package:flutter/material.dart';
import '../theme.dart';

/// Monthly AI Health Report — تقرير صحي شهري بالذكاء الاصطناعي
class MonthlyHealthReportScreen extends StatelessWidget {
  const MonthlyHealthReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF047857)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        '📊 التقرير الصحي الشهري',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'أبريل 2026 • تم التحليل بالذكاء الاصطناعي',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Health score
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value: 0.78,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.white.withAlpha(20),
                                  valueColor: const AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const Text(
                                '78',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'نقاط الصحة العامة',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'تحسن +5 عن الشهر السابق',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withAlpha(180),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.trending_up_rounded,
                                    color: Colors.white.withAlpha(200),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'أفضل من 65% من فئتك العمرية',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withAlpha(150),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vitals summary
                  _sectionTitle('📈', 'ملخص المؤشرات الحيوية'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _vitalCard(
                        'ضغط الدم',
                        '120/80',
                        'طبيعي',
                        const Color(0xFF22C55E),
                        Icons.favorite_rounded,
                      ),
                      const SizedBox(width: 10),
                      _vitalCard(
                        'السكر',
                        '95',
                        'طبيعي',
                        const Color(0xFF22C55E),
                        Icons.water_drop_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _vitalCard(
                        'النبض',
                        '72',
                        'ممتاز',
                        const Color(0xFF3B82F6),
                        Icons.monitor_heart_rounded,
                      ),
                      const SizedBox(width: 10),
                      _vitalCard(
                        'الوزن',
                        '75 كغ',
                        '-2 كغ',
                        const Color(0xFF22C55E),
                        Icons.scale_rounded,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _sectionTitle('🤖', 'تحليل الذكاء الاصطناعي'),
                  const SizedBox(height: 10),
                  _aiInsightCard('✅', 'نقاط القوة', const Color(0xFF22C55E), [
                    'التزام ممتاز بمواعيد الأدوية (92%)',
                    'معدل مشي جيد — 6,500 خطوة/يوم',
                    'ضغط الدم مستقر طوال الشهر',
                    'تحسن ملحوظ في جودة النوم',
                  ]),
                  const SizedBox(height: 10),
                  _aiInsightCard(
                    '⚠️',
                    'نقاط تحتاج تحسين',
                    const Color(0xFFF59E0B),
                    [
                      'شرب الماء أقل من المعدل — 5 أكواب/يوم',
                      'معدل السكر مرتفع قليلاً بعد الفطور',
                      'قلة النشاط يومي الجمعة والسبت',
                    ],
                  ),
                  const SizedBox(height: 10),
                  _aiInsightCard(
                    '🔴',
                    'تحذيرات مبكرة',
                    const Color(0xFFEF4444),
                    ['ارتفاع طفيف في الكوليسترول — ينصح بفحص شامل'],
                  ),

                  const SizedBox(height: 24),
                  _sectionTitle('💡', 'توصيات مخصصة لك'),
                  const SizedBox(height: 10),
                  _recommendationCard(
                    '🥗',
                    'تقليل الكربوهيدرات بالفطور',
                    'استبدل الخبز الأبيض بالشوفان أو الخبز الأسمر لتحسين السكر بعد الفطور',
                  ),
                  _recommendationCard(
                    '💧',
                    'زيادة شرب الماء',
                    'ضع تذكير كل ساعتين. الهدف 8 أكواب يومياً — أنت تشرب 5 فقط',
                  ),
                  _recommendationCard(
                    '🏃',
                    'إضافة نشاط نهاية الأسبوع',
                    'مشي 20 دقيقة يومي الجمعة والسبت يحسن معدلك الأسبوعي بنسبة 30%',
                  ),
                  _recommendationCard(
                    '🧪',
                    'فحص كوليسترول',
                    'ينصح بفحص Lipid Profile خلال الأسبوعين القادمين',
                  ),

                  const SizedBox(height: 24),
                  _sectionTitle('📊', 'مقارنة شهرية'),
                  const SizedBox(height: 10),
                  _comparisonCard('النشاط البدني', 0.72, 0.65, 'خطوة/يوم'),
                  _comparisonCard('الالتزام بالأدوية', 0.92, 0.88, ''),
                  _comparisonCard('جودة النوم', 0.80, 0.70, ''),
                  _comparisonCard('شرب الماء', 0.63, 0.60, 'كوب/يوم'),

                  const SizedBox(height: 24),
                  // Share button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('جاري تصدير التقرير كـ PDF 📄'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                      label: const Text(
                        'تصدير كـ PDF',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String icon, String title) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  static Widget _vitalCard(
    String label,
    String value,
    String status,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withAlpha(120),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiInsightCard(
    String emoji,
    String title,
    Color color,
    List<String> items,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•', style: TextStyle(fontSize: 12, color: color)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(170),
                        height: 1.4,
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

  Widget _recommendationCard(String emoji, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withAlpha(130),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonCard(
    String title,
    double current,
    double previous,
    String unit,
  ) {
    final improved = current > previous;
    final pct = ((current - previous) * 100).toInt();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                improved
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: improved
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${improved ? '+' : ''}$pct%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: improved
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'هذا الشهر',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withAlpha(80),
                      ),
                    ),
                    const SizedBox(height: 3),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: current,
                        backgroundColor: Colors.white.withAlpha(8),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الشهر السابق',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withAlpha(80),
                      ),
                    ),
                    const SizedBox(height: 3),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: previous,
                        backgroundColor: Colors.white.withAlpha(8),
                        valueColor: AlwaysStoppedAnimation(
                          Colors.white.withAlpha(40),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
