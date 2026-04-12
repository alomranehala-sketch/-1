import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';

class MedicalRecordTab extends StatefulWidget {
  const MedicalRecordTab({super.key});

  @override
  State<MedicalRecordTab> createState() => _MedicalRecordTabState();
}

class _MedicalRecordTabState extends State<MedicalRecordTab> {
  Map<String, dynamic> _record = {};
  Map<String, dynamic> _profile = {};
  // ignore: unused_field
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      ApiService.getHealthRecord(),
      ApiService.getProfile(),
    ]);
    if (!mounted) return;
    setState(() {
      _record = results[0];
      _profile = results[1];
      _loading = false;
    });
  }

  String get _name => (_profile['name'] as String?) ?? 'مستخدم';
  String get _initial => _name.isNotEmpty ? _name[0] : 'م';
  String get _gender =>
      (_record['gender'] as String?) ?? (_profile['gender'] as String?) ?? '';
  String get _age => (_record['age']?.toString()) ?? '';
  String get _bloodType => (_record['bloodType'] as String?) ?? '';
  String get _height => (_record['height']?.toString()) ?? '';
  String get _weight => (_record['weight']?.toString()) ?? '';

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 16),
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
            children: const [
              Text(
                'سجلي الطبي',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              Spacer(),
              Icon(
                Icons.file_download_outlined,
                color: AppColors.textMedium,
                size: 22,
              ),
            ],
          ),
        ),
        // Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPatientSummary(),
                const SizedBox(height: 16),
                _buildTimeline(),
                const SizedBox(height: 16),
                _buildDiagnoses(),
                const SizedBox(height: 16),
                _buildPrescriptions(),
                const SizedBox(height: 16),
                _buildLabResultsHistory(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    _initial,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_gender • $_age سنة',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem(
                  'فصيلة الدم',
                  _bloodType.isNotEmpty ? _bloodType : '--',
                ),
                _summaryDivider(),
                _summaryItem(
                  'الطول',
                  _height.isNotEmpty ? '$_height سم' : '--',
                ),
                _summaryDivider(),
                _summaryItem(
                  'الوزن',
                  _weight.isNotEmpty ? '$_weight كغ' : '--',
                ),
                _summaryDivider(),
                _summaryItem(
                  'BMI',
                  _height.isNotEmpty && _weight.isNotEmpty
                      ? (double.tryParse(_weight)! /
                                ((double.tryParse(_height)! / 100) *
                                    (double.tryParse(_height)! / 100)))
                            .toStringAsFixed(1)
                      : '--',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }

  Widget _summaryDivider() {
    return Container(width: 1, height: 28, color: Colors.white.withAlpha(20));
  }

  Widget _buildTimeline() {
    final events = [
      _TimeEvent(
        'زيارة طب عام',
        'د. محمد العبادي',
        '15 أبريل 2025',
        Icons.person_rounded,
        AppColors.primary,
      ),
      _TimeEvent(
        'فحص مخبري',
        'فحص الدم الشامل',
        '10 أبريل 2025',
        Icons.biotech_rounded,
        AppColors.info,
      ),
      _TimeEvent(
        'صرف دواء',
        'ميتفورمين 500mg',
        '10 أبريل 2025',
        Icons.medication_rounded,
        AppColors.warning,
      ),
      _TimeEvent(
        'زيارة أسنان',
        'د. سارة الخالدي',
        '1 مارس 2025',
        Icons.medical_services_rounded,
        const Color(0xFF7E57C2),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'الجدول الزمني',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...events.asMap().entries.map((e) {
            final i = e.key;
            final ev = e.value;
            final isLast = i == events.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline line + dot
                  SizedBox(
                    width: 30,
                    child: Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: ev.color.withAlpha(30),
                            shape: BoxShape.circle,
                            border: Border.all(color: ev.color, width: 2.5),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(width: 2, color: AppColors.border),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ev.color.withAlpha(6),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: ev.color.withAlpha(20)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(ev.icon, size: 16, color: ev.color),
                              const SizedBox(width: 6),
                              Text(
                                ev.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ev.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ev.date,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
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

  Widget _buildDiagnoses() {
    final diagnoses = [
      _Diagnosis('السكري من النوع 2', 'مزمن', AppColors.warning),
      _Diagnosis('نقص فيتامين D', 'نشط', AppColors.error),
      _Diagnosis('التهاب اللثة', 'متابعة', AppColors.info),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.medical_information_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'التشخيصات',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...diagnoses.map(
            (d) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: d.color.withAlpha(8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: d.color.withAlpha(25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: d.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      d.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: d.color.withAlpha(18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      d.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: d.color,
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

  Widget _buildPrescriptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'الوصفات الطبية',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _prescriptionRow('ميتفورمين', '500mg', 'مرتين يومياً', 'بعد الأكل'),
          const SizedBox(height: 8),
          _prescriptionRow('أوميبرازول', '20mg', 'مرة يومياً', 'قبل النوم'),
          const SizedBox(height: 8),
          _prescriptionRow(
            'فيتامين D',
            '50,000 IU',
            'مرة أسبوعياً',
            'مع الأكل',
          ),
        ],
      ),
    );
  }

  Widget _prescriptionRow(String name, String dose, String freq, String note) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.medication_rounded,
              size: 18,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name $dose',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      freq,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• $note',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabResultsHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'نتائج الفحوصات',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Spacer(),
              Text(
                'عرض الكل',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _labHistoryRow(
            'فحص الدم CBC',
            '10 أبريل 2025',
            'طبيعي',
            AppColors.success,
          ),
          const SizedBox(height: 8),
          _labHistoryRow(
            'السكر التراكمي',
            '10 أبريل 2025',
            '6.2%',
            AppColors.warning,
          ),
          const SizedBox(height: 8),
          _labHistoryRow(
            'فيتامين D',
            '10 أبريل 2025',
            'منخفض',
            AppColors.error,
          ),
          const SizedBox(height: 8),
          _labHistoryRow(
            'وظائف الكلى',
            '15 مارس 2025',
            'طبيعي',
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _labHistoryRow(String name, String date, String result, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 10, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withAlpha(18),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              result,
              style: TextStyle(
                fontSize: 11,
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

class _TimeEvent {
  final String title, subtitle, date;
  final IconData icon;
  final Color color;
  const _TimeEvent(this.title, this.subtitle, this.date, this.icon, this.color);
}

class _Diagnosis {
  final String name, status;
  final Color color;
  const _Diagnosis(this.name, this.status, this.color);
}
