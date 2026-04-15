import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class HomeServicesScreen extends StatefulWidget {
  const HomeServicesScreen({super.key});
  @override
  State<HomeServicesScreen> createState() => _HomeServicesScreenState();
}

class _HomeServicesScreenState extends State<HomeServicesScreen> {
  int _selectedService = -1;
  DateTime? _selectedDate;
  String? _selectedTime;

  final _services = const [
    _Service(
      'تمريض منزلي',
      'ممرض/ة معتمد لرعاية شاملة',
      Icons.medical_services_rounded,
      Color(0xFF0F766E),
      '25 د.أ/ساعة',
    ),
    _Service(
      'سحب عينات دم',
      'فني مختبر لسحب العينات',
      Icons.bloodtype_rounded,
      Color(0xFFEF4444),
      '15 د.أ',
    ),
    _Service(
      'علاج طبيعي',
      'أخصائي علاج طبيعي منزلي',
      Icons.accessibility_new_rounded,
      Color(0xFF3B82F6),
      '35 د.أ/جلسة',
    ),
    _Service(
      'رعاية مسنين',
      'رعاية متخصصة لكبار السن',
      Icons.elderly_rounded,
      Color(0xFF8B5CF6),
      '20 د.أ/ساعة',
    ),
    _Service(
      'تضميد جروح',
      'تغيير ضمادات وعناية بالجروح',
      Icons.healing_rounded,
      Color(0xFFF59E0B),
      '12 د.أ',
    ),
    _Service(
      'حقن وريدية',
      'إعطاء محاليل وأدوية وريدية',
      Icons.vaccines_rounded,
      Color(0xFF10B981),
      '18 د.أ',
    ),
  ];

  final _timeSlots = const [
    '08:00 ص',
    '09:00 ص',
    '10:00 ص',
    '11:00 ص',
    '12:00 م',
    '02:00 م',
    '03:00 م',
    '04:00 م',
    '05:00 م',
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
                      'خدمات منزلية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'معتمد',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Banner
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
                                'الرعاية تأتي إليك',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'فريق طبي متخصص لخدمتك في المنزل',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withAlpha(200),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'متوفر 7 أيام/أسبوع',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.health_and_safety_rounded,
                          size: 56,
                          color: Colors.white24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Services
                  const SectionHeader(
                    title: 'اختر الخدمة',
                    icon: Icons.list_alt_rounded,
                  ),
                  const SizedBox(height: 8),
                  ..._services.asMap().entries.map(
                    (e) => _buildServiceCard(e.key, e.value),
                  ),

                  // Date & Time (show when service selected)
                  if (_selectedService >= 0) ...[
                    const SizedBox(height: 20),
                    const SectionHeader(
                      title: 'اختر الموعد',
                      icon: Icons.calendar_today_rounded,
                    ),
                    const SizedBox(height: 8),
                    _buildDatePicker(),
                    if (_selectedDate != null) ...[
                      const SizedBox(height: 12),
                      _buildTimeSlots(),
                    ],
                  ],

                  // Confirm button
                  if (_selectedService >= 0 &&
                      _selectedDate != null &&
                      _selectedTime != null) ...[
                    const SizedBox(height: 20),
                    _buildSummaryCard(),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _confirmBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'تأكيد الحجز',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(int idx, _Service svc) {
    final sel = _selectedService == idx;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedService = idx;
          _selectedDate = null;
          _selectedTime = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? svc.color.withAlpha(8) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: sel
                ? svc.color.withAlpha(80)
                : AppColors.border.withAlpha(40),
            width: sel ? 1.5 : 1,
          ),
          boxShadow: sel ? [] : AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: svc.color.withAlpha(15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(svc.icon, color: svc.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    svc.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: sel ? svc.color : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    svc.desc,
                    style: TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  svc.price,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: svc.color,
                  ),
                ),
                if (sel) ...[
                  const SizedBox(height: 4),
                  Icon(Icons.check_circle_rounded, size: 18, color: svc.color),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.add(Duration(days: i + 1)));
    final dayNames = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (_, i) {
          final d = days[i];
          final sel =
              _selectedDate != null &&
              _selectedDate!.day == d.day &&
              _selectedDate!.month == d.month;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedDate = d;
              _selectedTime = null;
            }),
            child: Container(
              width: 58,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: sel
                    ? null
                    : Border.all(color: AppColors.border.withAlpha(40)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayNames[d.weekday % 7],
                    style: TextStyle(
                      fontSize: 10,
                      color: sel ? Colors.white70 : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: sel ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  Text(
                    '${d.month}/${d.year.toString().substring(2)}',
                    style: TextStyle(
                      fontSize: 9,
                      color: sel ? Colors.white60 : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _timeSlots.map((t) {
        final sel = _selectedTime == t;
        return GestureDetector(
          onTap: () => setState(() => _selectedTime = t),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: sel
                  ? null
                  : Border.all(color: AppColors.border.withAlpha(40)),
            ),
            child: Text(
              t,
              style: TextStyle(
                fontSize: 12,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel ? Colors.white : AppColors.textMedium,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard() {
    final svc = _services[_selectedService];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(svc.icon, color: svc.color, size: 20),
              const SizedBox(width: 8),
              Text(
                svc.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Text(
                svc.price,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: svc.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Text(
                '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Text(
                _selectedTime!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 14,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 6),
              const Text(
                'عنوانك المسجل',
                style: TextStyle(fontSize: 12, color: AppColors.textMedium),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تغيير العنوان — قريباً 🔜'),
                      backgroundColor: Color(0xFF3B82F6),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text(
                  'تغيير',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmBooking() {
    HapticFeedback.mediumImpact();
    final svc = _services[_selectedService];
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 36,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'تم حجز الخدمة',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${svc.name} — $_selectedTime',
                style: TextStyle(fontSize: 13, color: AppColors.textMedium),
              ),
              const SizedBox(height: 4),
              Text(
                '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('تم'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Service {
  final String name, desc;
  final IconData icon;
  final Color color;
  final String price;
  const _Service(this.name, this.desc, this.icon, this.color, this.price);
}
