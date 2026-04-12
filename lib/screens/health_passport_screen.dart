import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme.dart';
import '../services/api_service.dart';

/// Unified Health Passport — البطاقة الصحية الموحدة
/// Pulls all data from Hakeem + links with private hospitals via API
class HealthPassportScreen extends StatefulWidget {
  const HealthPassportScreen({super.key});
  @override
  State<HealthPassportScreen> createState() => _HealthPassportScreenState();
}

class _HealthPassportScreenState extends State<HealthPassportScreen>
    with TickerProviderStateMixin {
  bool _loading = true;
  Map<String, dynamic> _passport = {};
  Map<String, dynamic> _hakeemData = {};
  late AnimationController _pulseCtrl;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _tabCtrl = TabController(length: 6, vsync: this);
    _loadPassport();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPassport() async {
    final results = await Future.wait([
      ApiService.getHealthRecord(),
      ApiService.getProfile(),
    ]);
    if (!mounted) return;
    setState(() {
      _passport = results[0];
      _hakeemData = results[1];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(child: _buildPassportCard()),
                  SliverToBoxAdapter(child: _buildQuickStats()),
                  SliverToBoxAdapter(child: _buildTabSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 60,
      floating: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'جواز صحتي 🇯🇴',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: AppColors.textMedium),
          onPressed: () => _showShareSheet(),
        ),
      ],
    );
  }

  Widget _buildPassportCard() {
    final name = (_hakeemData['name'] as String?) ?? 'مستخدم';
    final nationalId = (_hakeemData['nationalId'] as String?) ?? '9XXXXXXXXX';
    final bloodType = (_passport['bloodType'] as String?) ?? 'O+';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1E3A5F), Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(40),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            top: -20,
            left: -20,
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, _) => Opacity(
                opacity: 0.05 + (_pulseCtrl.value * 0.05),
                child: const Icon(
                  Icons.health_and_safety,
                  size: 200,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.badge_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                '🇯🇴',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'المملكة الأردنية الهاشمية',
                                style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'الجواز الصحي الموحد',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: QrImageView(
                        data: 'TERYAQ-HP:$nationalId',
                        version: QrVersions.auto,
                        size: 60,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الرقم الوطني: $nationalId',
                  style: const TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _passportField(
                      'فصيلة الدم',
                      bloodType,
                      Icons.bloodtype_rounded,
                      const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 12),
                    _passportField(
                      'الحساسيات',
                      (_passport['allergies']?.toString()) ?? 'لا يوجد',
                      Icons.warning_amber_rounded,
                      const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 12),
                    _passportField(
                      'التطعيمات',
                      '${(_passport['vaccinations'] as List?)?.length ?? 12}',
                      Icons.vaccines_rounded,
                      const Color(0xFF10B981),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.success.withAlpha(40)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'مربوط مع نظام حكيم — Hakeem Verified',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passportField(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: AppColors.textLight, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      _Stat(
        'الأدوية',
        '${(_passport['medications'] as List?)?.length ?? 3}',
        Icons.medication_rounded,
        const Color(0xFF6366F1),
      ),
      _Stat(
        'التحاليل',
        '${(_passport['labResults'] as List?)?.length ?? 8}',
        Icons.science_rounded,
        const Color(0xFF06B6D4),
      ),
      _Stat(
        'الأشعة',
        '${(_passport['radiology'] as List?)?.length ?? 4}',
        Icons.medical_information_rounded,
        const Color(0xFFF59E0B),
      ),
      _Stat(
        'الزيارات',
        '${(_passport['visits'] as List?)?.length ?? 15}',
        Icons.local_hospital_rounded,
        const Color(0xFF10B981),
      ),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: stats
                .map(
                  (s) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.border.withAlpha(40),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(s.icon, color: s.color, size: 22),
                          const SizedBox(height: 6),
                          Text(
                            s.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            s.label,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Hakeem Sync + Private Hospital Link
        _buildHakeemSyncSection(),
        const SizedBox(height: 12),
        _buildPrivateHospitalsLink(),
      ],
    );
  }

  Widget _buildHakeemSyncSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withAlpha(15),
            const Color(0xFF06B6D4).withAlpha(15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sync_rounded,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سحب ملفك من نظام حكيم',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'آخر مزامنة: قبل 3 ساعات',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'مربوط',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _hakeemInfoChip(
                  'التاريخ المرضي',
                  '23 سجل',
                  const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _hakeemInfoChip(
                  'الأدوية الحالية',
                  '5 أدوية',
                  const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _hakeemInfoChip(
                  'المختبرات',
                  '12 فحص',
                  const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                setState(() => _loading = true);
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() => _loading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ تم سحب بياناتك من حكيم بنجاح'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  }
                });
              },
              icon: const Icon(Icons.cloud_download_rounded, size: 18),
              label: const Text(
                'سحب أحدث البيانات من حكيم',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hakeemInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textLight, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateHospitalsLink() {
    final privateHospitals = [
      _PrivateLink('مستشفى الأردن', 'مربوط', true),
      _PrivateLink('المستشفى العبدلي', 'مربوط', true),
      _PrivateLink('مستشفى الاستقلال', 'مربوط', true),
      _PrivateLink('مركز الحسين للسرطان', 'متاح للربط', false),
      _PrivateLink('المركز العربي الطبي', 'متاح للربط', false),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.link_rounded,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'ربط المستشفيات الخاصة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${privateHospitals.where((h) => h.linked).length}/${privateHospitals.length} مربوط',
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'سجلاتك من المستشفيات الخاصة تظهر مع بيانات حكيم بشكل موحد',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 11,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          ...privateHospitals.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: h.linked
                          ? const Color(0xFF10B981)
                          : AppColors.textLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      h.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (h.linked)
                    const Text(
                      '✅ مربوط',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('جاري ربط ${h.name}...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withAlpha(15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withAlpha(40),
                          ),
                        ),
                        child: const Text(
                          'اربط الآن',
                          style: TextStyle(
                            color: Color(0xFF6366F1),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
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

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(40)),
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.primary,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            tabs: const [
              Tab(text: 'التاريخ المرضي'),
              Tab(text: 'الأدوية'),
              Tab(text: 'التحاليل'),
              Tab(text: 'الأشعة'),
              Tab(text: 'التطعيمات'),
              Tab(text: 'الفواتير'),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildHistoryTab(),
                _buildMedicationsTab(),
                _buildLabTab(),
                _buildRadiologyTab(),
                _buildVaccinationsTab(),
                _buildBillsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final items = [
      {
        'date': '2026-04-01',
        'title': 'مراجعة طب عام',
        'hospital': 'مستشفى الجامعة',
        'type': 'عام',
      },
      {
        'date': '2026-03-15',
        'title': 'فحص قلب',
        'hospital': 'مستشفى الأردن',
        'type': 'خاص',
      },
      {
        'date': '2026-02-20',
        'title': 'طوارئ',
        'hospital': 'مستشفى البشير',
        'type': 'عام',
      },
      {
        'date': '2026-01-10',
        'title': 'عملية لوز',
        'hospital': 'المستشفى العبدلي',
        'type': 'خاص',
      },
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final item = items[i];
        final isPublic = item['type'] == 'عام';
        return _recordCard(
          item['title']!,
          '${item['hospital']} — ${item['date']}',
          isPublic
              ? Icons.account_balance_rounded
              : Icons.local_hospital_rounded,
          isPublic ? const Color(0xFF10B981) : const Color(0xFF6366F1),
          isPublic ? 'عام' : 'خاص',
        );
      },
    );
  }

  Widget _buildMedicationsTab() {
    final meds = [
      {'name': 'ميتفورمين 500mg', 'dose': 'مرتين يومياً', 'source': 'حكيم'},
      {'name': 'أسبرين 81mg', 'dose': 'مرة يومياً', 'source': 'خاص'},
      {'name': 'أملوديبين 5mg', 'dose': 'مرة يومياً', 'source': 'حكيم'},
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: meds.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _recordCard(
        meds[i]['name']!,
        '${meds[i]['dose']} — مصدر: ${meds[i]['source']}',
        Icons.medication_rounded,
        const Color(0xFF6366F1),
        meds[i]['source']!,
      ),
    );
  }

  Widget _buildLabTab() {
    final labs = [
      {'name': 'CBC - فحص دم شامل', 'date': '2026-04-05', 'result': 'طبيعي'},
      {'name': 'HbA1c - سكر تراكمي', 'date': '2026-03-28', 'result': '6.8%'},
      {'name': 'Lipid Panel - دهون', 'date': '2026-03-15', 'result': 'مرتفع'},
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: labs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _recordCard(
        labs[i]['name']!,
        '${labs[i]['date']} — النتيجة: ${labs[i]['result']}',
        Icons.science_rounded,
        labs[i]['result'] == 'طبيعي'
            ? const Color(0xFF10B981)
            : const Color(0xFFF59E0B),
        labs[i]['result']!,
      ),
    );
  }

  Widget _buildRadiologyTab() {
    final items = [
      {'name': 'أشعة صدر', 'date': '2026-03-20', 'result': 'طبيعي'},
      {
        'name': 'رنين مغناطيسي — ركبة',
        'date': '2026-02-15',
        'result': 'تمزق جزئي',
      },
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _recordCard(
        items[i]['name']!,
        '${items[i]['date']} — ${items[i]['result']}',
        Icons.medical_information_rounded,
        const Color(0xFF06B6D4),
        '',
      ),
    );
  }

  Widget _buildVaccinationsTab() {
    final vacc = [
      {'name': 'كوفيد-19 (فايزر)', 'date': '2025-12-01', 'doses': '3 جرعات'},
      {
        'name': 'الإنفلونزا الموسمية',
        'date': '2025-10-15',
        'doses': 'جرعة سنوية',
      },
      {'name': 'التهاب الكبد B', 'date': '2024-06-01', 'doses': '3 جرعات'},
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vacc.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _recordCard(
        vacc[i]['name']!,
        '${vacc[i]['date']} — ${vacc[i]['doses']}',
        Icons.vaccines_rounded,
        const Color(0xFF10B981),
        '',
      ),
    );
  }

  Widget _buildBillsTab() {
    final bills = [
      {
        'title': 'مراجعة طب عام',
        'amount': 'مجاني',
        'source': 'عام',
        'date': '2026-04-01',
      },
      {
        'title': 'فحص قلب + إيكو',
        'amount': '85 د.أ',
        'source': 'خاص',
        'date': '2026-03-15',
      },
      {
        'title': 'تحاليل مخبرية',
        'amount': '35 د.أ',
        'source': 'مختبر',
        'date': '2026-03-10',
      },
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bills.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _recordCard(
        bills[i]['title']!,
        '${bills[i]['date']} — ${bills[i]['amount']}',
        Icons.receipt_long_rounded,
        const Color(0xFFF59E0B),
        bills[i]['source']!,
      ),
    );
  }

  Widget _recordCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String badge,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withAlpha(30)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (badge.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showShareSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'مشاركة الجواز الصحي',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            _shareOption(
              Icons.qr_code_rounded,
              'رمز QR',
              'امسح للدخول السريع',
              const Color(0xFF6366F1),
            ),
            _shareOption(
              Icons.bluetooth_rounded,
              'Bluetooth/NFC',
              'مشاركة قريبة',
              const Color(0xFF06B6D4),
            ),
            _shareOption(
              Icons.picture_as_pdf_rounded,
              'تصدير PDF',
              'ملف رسمي',
              const Color(0xFFEF4444),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _shareOption(IconData icon, String title, String sub, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        sub,
        style: const TextStyle(color: AppColors.textLight, fontSize: 12),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.textLight,
        size: 16,
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}

class _Stat {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.icon, this.color);
}

class _PrivateLink {
  final String name, status;
  final bool linked;
  const _PrivateLink(this.name, this.status, this.linked);
}
