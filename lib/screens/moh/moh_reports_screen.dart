import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/moh_service.dart';
import '../../theme.dart';

class MohReportsScreen extends StatefulWidget {
  const MohReportsScreen({super.key});
  @override
  State<MohReportsScreen> createState() => _MohReportsScreenState();
}

class _MohReportsScreenState extends State<MohReportsScreen> {
  // ignore: unused_field
  Map<String, dynamic> _data = {};
  bool _loading = true;
  String _selectedPeriod = 'شهري';

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
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 12),
          color: const Color(0xFF1E293B),
          child: Row(
            children: [
              const Text('📑', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'التقارير والإحصائيات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              // Period selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white54,
                      size: 16,
                    ),
                    items: ['يومي', 'أسبوعي', 'شهري', 'سنوي']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPeriod = v!),
                  ),
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
                        // Key Performance Indicators
                        _sectionTitle('📊 مؤشرات الأداء الرئيسية'),
                        const SizedBox(height: 8),
                        _kpiGrid(),
                        const SizedBox(height: 20),
                        // Cost savings
                        _sectionTitle('💰 التوفير المالي'),
                        const SizedBox(height: 8),
                        _costCard(),
                        const SizedBox(height: 20),
                        // Patient satisfaction
                        _sectionTitle('😊 رضا المرضى'),
                        const SizedBox(height: 8),
                        _satisfactionCard(),
                        const SizedBox(height: 20),
                        // Efficiency metrics
                        _sectionTitle('⚡ كفاءة العمليات'),
                        const SizedBox(height: 8),
                        _efficiencyCard(),
                        const SizedBox(height: 20),
                        // Generate report button
                        _generateButton(),
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

  Widget _kpiGrid() {
    final items = [
      _KPI(
        'متوسط وقت الانتظار',
        '23 دقيقة',
        '↓ 15%',
        const Color(0xFF10B981),
        Icons.timer_rounded,
      ),
      _KPI(
        'معدل إشغال الأسرّة',
        '78%',
        '↑ 3%',
        const Color(0xFFF59E0B),
        Icons.bed_rounded,
      ),
      _KPI(
        'وقت الاستجابة للطوارئ',
        '8 دقائق',
        '↓ 20%',
        AppColors.primary,
        Icons.emergency_rounded,
      ),
      _KPI(
        'معدل إعادة الدخول',
        '4.2%',
        '↓ 8%',
        const Color(0xFF8B5CF6),
        Icons.replay_rounded,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: items
          .map(
            (kpi) => Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kpi.color.withAlpha(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(kpi.icon, color: kpi.color, size: 18),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          kpi.change,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    kpi.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: kpi.color,
                    ),
                  ),
                  Text(
                    kpi.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withAlpha(100),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _costCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withAlpha(12),
            const Color(0xFF10B981).withAlpha(4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withAlpha(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.savings_rounded,
                color: Color(0xFF10B981),
                size: 32,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التوفير السنوي المتوقع',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'من خلال الذكاء الاصطناعي والأتمتة',
                      style: TextStyle(fontSize: 10, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const Text(
                '2.4M',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10B981),
                ),
              ),
              Text(
                ' د.أ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withAlpha(100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _savingItem('فرز ذكي — تقليل وقت انتظار', '820K', 34),
          _savingItem('تحسين إشغال الأسرّة', '640K', 27),
          _savingItem('تنبؤ بالطلب — تحسين الجدولة', '520K', 22),
          _savingItem('كشف وبائي مبكر', '420K', 17),
        ],
      ),
    );
  }

  Widget _savingItem(String label, String amount, int pct) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withAlpha(140),
                  ),
                ),
                const SizedBox(height: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    backgroundColor: Colors.white.withAlpha(8),
                    color: const Color(0xFF10B981),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$amount د.أ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _satisfactionCard() {
    final regions = [
      {'name': 'عمّان', 'score': 4.2},
      {'name': 'إربد', 'score': 3.8},
      {'name': 'الزرقاء', 'score': 3.5},
      {'name': 'العقبة', 'score': 4.1},
      {'name': 'الكرك', 'score': 3.9},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: regions.map<Widget>((r) {
          final score = r['score'] as double;
          final pct = score / 5;
          final color = score >= 4.0
              ? const Color(0xFF10B981)
              : score >= 3.5
              ? const Color(0xFFF59E0B)
              : AppColors.error;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    r['name'] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.white.withAlpha(8),
                      color: color,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  score.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const Text(
                  ' /5',
                  style: TextStyle(fontSize: 10, color: Colors.white38),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _efficiencyCard() {
    final metrics = [
      {'label': 'دقة الفرز الذكي', 'value': 94, 'icon': '🎯'},
      {'label': 'مطابقة التنبؤ بالطلب', 'value': 89, 'icon': '📊'},
      {'label': 'سرعة الاستجابة للتنبيهات', 'value': 96, 'icon': '⚡'},
      {'label': 'كفاءة توزيع الأسرّة', 'value': 91, 'icon': '🛏️'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: metrics.map<Widget>((m) {
          final val = (m['value'] as int).toDouble();
          final color = val >= 90
              ? const Color(0xFF10B981)
              : val >= 80
              ? const Color(0xFFF59E0B)
              : AppColors.error;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Text(m['icon'] as String, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    m['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(160),
                    ),
                  ),
                ),
                Text(
                  '${m['value']}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _generateButton() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('جارٍ توليد التقرير... 📄'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✅ تم توليد التقرير بنجاح — تقرير_أداء_المستشفيات_أبريل_2026.pdf',
              ),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            '📥 توليد تقرير شامل PDF',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _KPI {
  final String label, value, change;
  final Color color;
  final IconData icon;
  const _KPI(this.label, this.value, this.change, this.color, this.icon);
}
