import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Hospital Operations Dashboard — لوحة عمليات المستشفى
class HospitalOperationsScreen extends StatefulWidget {
  const HospitalOperationsScreen({super.key});
  @override
  State<HospitalOperationsScreen> createState() =>
      _HospitalOperationsScreenState();
}

class _HospitalOperationsScreenState extends State<HospitalOperationsScreen> {
  int _selectedDept = 0;

  final _departments = [
    'الكل',
    'الطوارئ',
    'العمليات',
    'الباطنية',
    'الأطفال',
    'ICU',
  ];

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
                'لوحة العمليات',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.textLight,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحديث البيانات ✅'),
                        backgroundColor: Color(0xFF10B981),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(child: _buildSummaryCards()),
            SliverToBoxAdapter(child: _buildDeptFilter()),
            SliverToBoxAdapter(child: _buildStaffSection()),
            SliverToBoxAdapter(child: _buildEquipmentSection()),
            SliverToBoxAdapter(child: _buildRevenueSection()),
            SliverToBoxAdapter(child: _buildAlertsSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final items = [
      _SummaryItem(
        'المرضى',
        '347',
        '+12',
        Icons.people_rounded,
        const Color(0xFF3B82F6),
      ),
      _SummaryItem(
        'الأسرّة',
        '82%',
        '',
        Icons.bed_rounded,
        const Color(0xFF10B981),
      ),
      _SummaryItem(
        'العمليات',
        '14',
        'اليوم',
        Icons.medical_services_rounded,
        const Color(0xFF8B5CF6),
      ),
      _SummaryItem(
        'الطوارئ',
        '23',
        'حالة',
        Icons.emergency_rounded,
        const Color(0xFFEF4444),
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
        childAspectRatio: 1.6,
        children: items
            .map(
              (item) => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: item.color.withAlpha(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: item.color.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(item.icon, color: item.color, size: 18),
                        ),
                        if (item.sub.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: item.color.withAlpha(15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.sub,
                              style: TextStyle(
                                color: item.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 11,
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

  Widget _buildDeptFilter() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _departments.asMap().entries.map((e) {
          final active = e.key == _selectedDept;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDept = e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
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

  Widget _buildStaffSection() {
    final staff = [
      _StaffItem('د. أحمد الخطيب', 'استشاري قلب', true, 'غرفة 5'),
      _StaffItem('د. فاطمة العلي', 'أخصائية أطفال', true, 'عيادة 3'),
      _StaffItem('د. محمد القاسم', 'جراح عام', false, 'عملية'),
      _StaffItem('ممرض خالد', 'طوارئ', true, 'ER-2'),
      _StaffItem('د. ليلى حسن', 'نساء وتوليد', true, 'عيادة 7'),
    ];

    return _section(
      'الكوادر الطبية 👨‍⚕️',
      '${staff.where((s) => s.available).length}/${staff.length} متاح',
      Column(
        children: staff
            .map(
              (s) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: s.available
                          ? AppColors.success.withAlpha(30)
                          : AppColors.textLight.withAlpha(30),
                      child: Icon(
                        Icons.person_rounded,
                        color: s.available
                            ? AppColors.success
                            : AppColors.textLight,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            s.role,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
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
                        color: s.available
                            ? AppColors.success.withAlpha(15)
                            : const Color(0xFFF59E0B).withAlpha(15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s.available ? s.location : '🔴 في عملية',
                        style: TextStyle(
                          color: s.available
                              ? AppColors.success
                              : const Color(0xFFF59E0B),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
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

  Widget _buildEquipmentSection() {
    final equip = [
      _Equip('CT Scanner', 'تصوير طبقي', true, 'متاح — الطابق 2'),
      _Equip('MRI', 'رنين مغناطيسي', false, 'مشغول — ينتهي 2:30'),
      _Equip('X-Ray #1', 'أشعة سينية', true, 'متاح — الطابق 1'),
      _Equip('X-Ray #2', 'أشعة سينية', true, 'متاح — الطوارئ'),
      _Equip('Ultrasound', 'سونار', false, 'صيانة مجدولة'),
      _Equip('Ventilator #3', 'جهاز تنفس', true, 'متاح — ICU'),
    ];

    return _section(
      'الأجهزة والمعدات 🏥',
      '${equip.where((e) => e.available).length}/${equip.length} متاح',
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: equip
            .map(
              (e) => Container(
                width: (MediaQuery.of(context).size.width - 56) / 2,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        (e.available
                                ? AppColors.success
                                : const Color(0xFFF59E0B))
                            .withAlpha(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: e.available
                                ? AppColors.success
                                : const Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          e.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.status,
                      style: TextStyle(
                        color: e.available
                            ? AppColors.success
                            : const Color(0xFFF59E0B),
                        fontSize: 10,
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

  Widget _buildRevenueSection() {
    return _section(
      'الإيرادات اليومية 💰',
      'اليوم',
      Column(
        children: [
          _revenueTile('استشارات', '12,450 د.أ', 0.7, const Color(0xFF3B82F6)),
          const SizedBox(height: 8),
          _revenueTile('عمليات', '28,300 د.أ', 1.0, const Color(0xFF10B981)),
          const SizedBox(height: 8),
          _revenueTile('مختبر', '5,200 د.أ', 0.35, const Color(0xFF8B5CF6)),
          const SizedBox(height: 8),
          _revenueTile('أشعة', '7,800 د.أ', 0.5, const Color(0xFFF59E0B)),
          const SizedBox(height: 8),
          _revenueTile('صيدلية', '3,600 د.أ', 0.25, const Color(0xFF06B6D4)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withAlpha(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'المجموع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '57,350 د.أ',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _revenueTile(String label, String amount, double pct, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMedium, fontSize: 12),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.border.withAlpha(20),
              color: color,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsSection() {
    final alerts = [
      _Alert(
        'إشغال ICU وصل 90%',
        'قبل 15 دقيقة',
        Icons.warning_rounded,
        AppColors.error,
      ),
      _Alert(
        'نقص مخزون دم O-',
        'قبل 30 دقيقة',
        Icons.bloodtype_rounded,
        const Color(0xFFF59E0B),
      ),
      _Alert(
        'عملية طارئة — غرفة 3',
        'قبل 45 دقيقة',
        Icons.emergency_rounded,
        AppColors.error,
      ),
      _Alert(
        'صيانة مصعد B2',
        'قبل ساعة',
        Icons.build_rounded,
        AppColors.textLight,
      ),
    ];

    return _section(
      'تنبيهات ⚠️',
      '${alerts.length} تنبيه',
      Column(
        children: alerts
            .map(
              (a) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: a.color.withAlpha(8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: a.color.withAlpha(25)),
                ),
                child: Row(
                  children: [
                    Icon(a.icon, color: a.color, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            a.time,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 10,
                            ),
                          ),
                        ],
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

  Widget _section(String title, String badge, Widget child) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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

class _SummaryItem {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _SummaryItem(this.label, this.value, this.sub, this.icon, this.color);
}

class _StaffItem {
  final String name, role, location;
  final bool available;
  const _StaffItem(this.name, this.role, this.available, this.location);
}

class _Equip {
  final String name, type, status;
  final bool available;
  const _Equip(this.name, this.type, this.available, this.status);
}

class _Alert {
  final String text, time;
  final IconData icon;
  final Color color;
  const _Alert(this.text, this.time, this.icon, this.color);
}
