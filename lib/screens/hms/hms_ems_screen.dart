import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/hms_service.dart';
import '../../theme.dart';

class HmsEmsScreen extends StatefulWidget {
  const HmsEmsScreen({super.key});
  @override
  State<HmsEmsScreen> createState() => _HmsEmsScreenState();
}

class _HmsEmsScreenState extends State<HmsEmsScreen> {
  List<Map<String, dynamic>> _ems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  static final List<Map<String, dynamic>> _demoEms = [
    {
      'patientDesc': 'ذكر 45 سنة — حادث سير، إصابة رأس',
      'triage': 'red',
      'from': 'موقع الحادث — شارع المدينة',
      'ambulanceId': 'EMS-201',
      'paramedic': 'عادل السالم',
      'etaMinutes': 3,
      'vitals': {'hr': 120, 'temp': 37.8},
    },
    {
      'patientDesc': 'أنثى 32 سنة — ألم صدري حاد',
      'triage': 'red',
      'from': 'منزل — حي النزهة',
      'ambulanceId': 'EMS-105',
      'paramedic': 'ريما الحمد',
      'etaMinutes': 7,
      'vitals': {'hr': 95, 'temp': 36.9},
    },
    {
      'patientDesc': 'ذكر 68 سنة — ضيق تنفس',
      'triage': 'yellow',
      'from': 'مركز صحي الرمثا',
      'ambulanceId': 'EMS-309',
      'paramedic': 'سامر عبيدات',
      'etaMinutes': 12,
      'vitals': {'hr': 88, 'temp': 37.1},
    },
    {
      'patientDesc': 'طفل 8 سنوات — كسر مفتوح ساق',
      'triage': 'yellow',
      'from': 'مدرسة الأمل',
      'ambulanceId': 'EMS-412',
      'paramedic': 'هدى القاسم',
      'etaMinutes': 18,
      'vitals': {'hr': 110, 'temp': 37.0},
    },
  ];

  Future<void> _load() async {
    final data = await HmsService.getEmsIncoming();
    if (mounted) {
      setState(() {
        _ems = data.isNotEmpty ? data : _demoEms;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 12),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  const Text('🚑', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'الإسعاف القادمة (${_ems.length})',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _ems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🟢', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'لا توجد سيارات إسعاف قادمة',
                            style: TextStyle(
                              color: Colors.white.withAlpha(120),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          _buildEmsSummary(),
                          const SizedBox(height: 12),
                          ..._ems.map(_emsCard),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
          ],
        ),
        // FAB: طلب إسعاف
        Positioned(
          left: 16,
          bottom: 24,
          child: FloatingActionButton.extended(
            heroTag: 'ems_dispatch',
            onPressed: _showDispatchSheet,
            backgroundColor: AppColors.error,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'طلب إسعاف',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDispatchSheet() {
    HapticFeedback.mediumImpact();
    String priority = 'red';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setBS) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '🚑 طلب سيارة إسعاف',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'درجة الأولوية',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withAlpha(160),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _priorityChip(
                      'red',
                      '🔴 حرج',
                      AppColors.error,
                      priority,
                      (v) => setBS(() => priority = v),
                    ),
                    const SizedBox(width: 8),
                    _priorityChip(
                      'yellow',
                      '🟡 متوسط',
                      const Color(0xFFF59E0B),
                      priority,
                      (v) => setBS(() => priority = v),
                    ),
                    const SizedBox(width: 8),
                    _priorityChip(
                      'green',
                      '🟢 عادي',
                      AppColors.success,
                      priority,
                      (v) => setBS(() => priority = v),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'الموقع / العنوان',
                    hintStyle: TextStyle(
                      color: Colors.white.withAlpha(60),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.location_on_rounded,
                      color: Colors.white.withAlpha(60),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'ملاحظات إضافية (اختياري)',
                    hintStyle: TextStyle(
                      color: Colors.white.withAlpha(60),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      HapticFeedback.heavyImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم إرسال طلب إسعاف — أولوية: ${priority == 'red'
                                ? 'حرجة'
                                : priority == 'yellow'
                                ? 'متوسطة'
                                : 'عادية'} 🚑',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    label: const Text(
                      'إرسال الطلب',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _priorityChip(
    String value,
    String label,
    Color color,
    String current,
    ValueChanged<String> onSelect,
  ) {
    final selected = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withAlpha(25) : Colors.white.withAlpha(6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.white.withAlpha(15),
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : Colors.white.withAlpha(120),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmsSummary() {
    final urgent = _ems
        .where((e) => ((e['etaMinutes'] as int?) ?? 0) <= 5)
        .length;
    final avgEta = _ems.isEmpty
        ? 0
        : (_ems.fold<int>(
                    0,
                    (sum, e) => sum + ((e['etaMinutes'] as int?) ?? 0),
                  ) /
                  _ems.length)
              .round();
    final redCount = _ems.where((e) => e['triage'] == 'red').length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withAlpha(20)),
      ),
      child: Row(
        children: [
          _summaryItem('🚨', 'عاجل', '$urgent', AppColors.error),
          _summaryDivider(),
          _summaryItem('🔴', 'حرج', '$redCount', const Color(0xFFF59E0B)),
          _summaryDivider(),
          _summaryItem('⏱️', 'متوسط ETA', '$avgEta د', AppColors.info),
          _summaryDivider(),
          _summaryItem('🚑', 'المجموع', '${_ems.length}', AppColors.primary),
        ],
      ),
    );
  }

  Widget _summaryItem(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.white.withAlpha(100)),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Container(width: 1, height: 40, color: Colors.white.withAlpha(10));
  }

  Widget _emsCard(Map<String, dynamic> ems) {
    final eta = (ems['etaMinutes'] as int?) ?? 0;
    final isUrgent = eta <= 5;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? AppColors.error.withAlpha(60)
              : Colors.white.withAlpha(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isUrgent ? '🚨' : '🚑',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ems['patientDesc'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _triageColor(
                              ems['triage'] ?? 'yellow',
                            ).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ems['triage']?.toString().toUpperCase() ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _triageColor(ems['triage'] ?? 'yellow'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'من: ${ems['from'] ?? ''}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withAlpha(100),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ETA
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? AppColors.error.withAlpha(20)
                      : AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$eta',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isUrgent ? AppColors.error : AppColors.primary,
                      ),
                    ),
                    Text(
                      'دقيقة',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Info row
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _chip(Icons.local_hospital_rounded, ems['ambulanceId'] ?? ''),
              _chip(Icons.person_rounded, ems['paramedic'] ?? ''),
              if (ems['vitals'] != null) ...[
                _chip(Icons.favorite_rounded, 'HR: ${ems['vitals']['hr']}'),
                _chip(Icons.thermostat_rounded, '${ems['vitals']['temp']}°'),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // ETA progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'وقت الوصول المتوقع',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withAlpha(80),
                    ),
                  ),
                  Text(
                    '$eta دقيقة',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isUrgent ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (1 - (eta / 30)).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withAlpha(10),
                  valueColor: AlwaysStoppedAnimation(
                    isUrgent ? AppColors.error : AppColors.primary,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحضير فريق الاستقبال 🏥'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'تحضير الاستقبال',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تخصيص سرير طوارئ 🛏️'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.info.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'تخصيص سرير',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white.withAlpha(80)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(120)),
        ),
      ],
    );
  }

  Color _triageColor(String t) {
    switch (t) {
      case 'red':
        return AppColors.error;
      case 'yellow':
        return const Color(0xFFF59E0B);
      case 'green':
        return AppColors.success;
      default:
        return Colors.white54;
    }
  }
}
