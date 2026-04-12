import 'package:flutter/material.dart';
import '../theme.dart';

/// National Anonymous Dashboard — لوحة وطنية مجهولة الهوية
/// Real-time disease, crowd stats, epidemics for MOH
class NationalDashboardScreen extends StatefulWidget {
  const NationalDashboardScreen({super.key});
  @override
  State<NationalDashboardScreen> createState() =>
      _NationalDashboardScreenState();
}

class _NationalDashboardScreenState extends State<NationalDashboardScreen> {
  int _periodIndex = 0;
  final _periods = ['اليوم', 'أسبوع', 'شهر', 'سنة'];

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
                'لوحة الأردن الصحية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(left: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.circle, color: AppColors.success, size: 8),
                      SizedBox(width: 4),
                      Text(
                        'مباشر',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(child: _buildPeriodFilter()),
            SliverToBoxAdapter(child: _buildKeyMetrics()),
            SliverToBoxAdapter(child: _buildDiseaseTracker()),
            SliverToBoxAdapter(child: _buildGovernorateMap()),
            SliverToBoxAdapter(child: _buildHospitalLoad()),
            SliverToBoxAdapter(child: _buildVaccinationProgress()),
            SliverToBoxAdapter(child: _buildAlerts()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _periods.asMap().entries.map((e) {
          final active = e.key == _periodIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _periodIndex = e.key),
              child: Container(
                margin: EdgeInsets.only(left: e.key > 0 ? 6 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  e.value,
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.textMedium,
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyMetrics() {
    final metrics = [
      _Metric(
        'زيارات طوارئ',
        '15,234',
        '+3.2%',
        true,
        Icons.emergency_rounded,
        const Color(0xFFEF4444),
      ),
      _Metric(
        'مراجعين عيادات',
        '42,180',
        '-1.5%',
        false,
        Icons.local_hospital_rounded,
        const Color(0xFF3B82F6),
      ),
      _Metric(
        'عمليات',
        '1,847',
        '+0.8%',
        true,
        Icons.medical_services_rounded,
        const Color(0xFF8B5CF6),
      ),
      _Metric(
        'ولادات',
        '892',
        '+2.1%',
        true,
        Icons.child_care_rounded,
        const Color(0xFF10B981),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: metrics
            .map(
              (m) => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: m.color.withAlpha(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(m.icon, color: m.color, size: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (m.up ? AppColors.success : AppColors.error)
                                .withAlpha(15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            m.change,
                            style: TextStyle(
                              color: m.up ? AppColors.success : AppColors.error,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          m.label,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDiseaseTracker() {
    final diseases = [
      _Disease('إنفلونزا موسمية', 2340, 0.65, const Color(0xFF3B82F6)),
      _Disease('COVID-19', 187, 0.15, const Color(0xFFEF4444)),
      _Disease('حمى مالطية', 89, 0.08, const Color(0xFFF59E0B)),
      _Disease('سكري جديد', 456, 0.30, const Color(0xFF8B5CF6)),
      _Disease('أمراض تنفسية', 1230, 0.50, const Color(0xFF06B6D4)),
    ];

    return _section(
      'متتبع الأمراض 🦠',
      'محافظات الأردن',
      Column(
        children: diseases
            .map(
              (d) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        d.name,
                        style: const TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: d.pct,
                          backgroundColor: AppColors.border.withAlpha(20),
                          color: d.color,
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${d.count}',
                        style: TextStyle(
                          color: d.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildGovernorateMap() {
    final govs = [
      _Gov('عمان', 35, const Color(0xFFEF4444)),
      _Gov('إربد', 18, const Color(0xFFF59E0B)),
      _Gov('الزرقاء', 15, const Color(0xFFF59E0B)),
      _Gov('العقبة', 5, const Color(0xFF10B981)),
      _Gov('الكرك', 7, const Color(0xFF10B981)),
      _Gov('جرش', 4, const Color(0xFF10B981)),
      _Gov('المفرق', 6, const Color(0xFF10B981)),
      _Gov('مادبا', 3, const Color(0xFF10B981)),
      _Gov('الطفيلة', 2, const Color(0xFF10B981)),
      _Gov('البلقاء', 5, const Color(0xFF10B981)),
    ];

    return _section(
      'توزيع محافظات 🗺️',
      'حالات اليوم',
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: govs
            .map(
              (g) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: g.color.withAlpha(10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: g.color.withAlpha(30)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      g.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: g.color.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${g.pct}%',
                        style: TextStyle(
                          color: g.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildHospitalLoad() {
    final hospitals = [
      _HLoad('مستشفى الجامعة', 92, const Color(0xFFEF4444)),
      _HLoad('البشير', 85, const Color(0xFFF59E0B)),
      _HLoad('المدينة الطبية', 78, const Color(0xFF3B82F6)),
      _HLoad('الأمير حمزة', 65, const Color(0xFF10B981)),
      _HLoad('الزرقاء الحكومي', 70, const Color(0xFF3B82F6)),
    ];

    return _section(
      'حمل المستشفيات 🏥',
      'نسبة الإشغال',
      Column(
        children: hospitals
            .map(
              (h) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          h.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${h.pct}%',
                          style: TextStyle(
                            color: h.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: h.pct / 100,
                        backgroundColor: AppColors.border.withAlpha(20),
                        color: h.color,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildVaccinationProgress() {
    return _section(
      'التطعيمات 💉',
      'تقدم',
      Column(
        children: [
          _vacRow('كورونا (معززة)', '78%', 0.78, const Color(0xFF10B981)),
          const SizedBox(height: 8),
          _vacRow('إنفلونزا 2024', '45%', 0.45, const Color(0xFF3B82F6)),
          const SizedBox(height: 8),
          _vacRow('أطفال روتيني', '92%', 0.92, const Color(0xFF8B5CF6)),
          const SizedBox(height: 8),
          _vacRow('حصبة', '88%', 0.88, const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _vacRow(String name, String pct, double val, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            name,
            style: const TextStyle(color: AppColors.textMedium, fontSize: 12),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: val,
              backgroundColor: AppColors.border.withAlpha(20),
              color: color,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          pct,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildAlerts() {
    return _section(
      'تنبيهات وبائية 🚨',
      'تلقائي',
      Column(
        children: [
          _alertTile('ارتفاع حالات إنفلونزا في إربد +40%', AppColors.error),
          const SizedBox(height: 8),
          _alertTile(
            'نقص مخزون لقاح الأطفال في المفرق',
            const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 8),
          _alertTile('إشغال مستشفى الجامعة يقترب من 95%', AppColors.error),
        ],
      ),
    );
  }

  Widget _alertTile(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String badge, Widget child) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Metric {
  final String label, value, change;
  final bool up;
  final IconData icon;
  final Color color;
  const _Metric(
    this.label,
    this.value,
    this.change,
    this.up,
    this.icon,
    this.color,
  );
}

class _Disease {
  final String name;
  final int count;
  final double pct;
  final Color color;
  const _Disease(this.name, this.count, this.pct, this.color);
}

class _Gov {
  final String name;
  final int pct;
  final Color color;
  const _Gov(this.name, this.pct, this.color);
}

class _HLoad {
  final String name;
  final int pct;
  final Color color;
  const _HLoad(this.name, this.pct, this.color);
}
