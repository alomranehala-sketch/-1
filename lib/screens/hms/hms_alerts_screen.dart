import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/hms_service.dart';
import '../../theme.dart';

class HmsAlertsScreen extends StatefulWidget {
  const HmsAlertsScreen({super.key});
  @override
  State<HmsAlertsScreen> createState() => _HmsAlertsScreenState();
}

class _HmsAlertsScreenState extends State<HmsAlertsScreen> {
  List<Map<String, dynamic>> _alerts = [];
  List<Map<String, dynamic>> _feedback = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  static final List<Map<String, dynamic>> _demoAlerts = [
    {
      'id': 'a1',
      'type': 'critical',
      'title': 'حالة حرجة — غرفة 302',
      'body': 'انخفاض ضغط الدم الحاد للمريض أحمد الخالدي. يحتاج تدخل فوري.',
      'acknowledged': false,
    },
    {
      'id': 'a2',
      'type': 'critical',
      'title': 'توقف قلبي — العناية المركزة',
      'body': 'المريضة سارة المصري، سرير 7. فريق الإنعاش في الطريق.',
      'acknowledged': false,
    },
    {
      'id': 'a3',
      'type': 'ems',
      'title': 'إسعاف قادم — 3 دقائق',
      'body': 'حادث سير، إصابة في الرأس. ETA: 3 دقائق.',
      'acknowledged': false,
    },
    {
      'id': 'a4',
      'type': 'bed',
      'title': 'نقص أسرّة — قسم الطوارئ',
      'body': 'إشغال 100%. يجب نقل مرضى مستقرين لأقسام أخرى.',
      'acknowledged': false,
    },
    {
      'id': 'a5',
      'type': 'critical',
      'title': 'ارتفاع حرارة — جناح الأطفال',
      'body': 'الطفل ياسر، حرارة 40.2°. تم إعطاء خافض حرارة.',
      'acknowledged': true,
    },
    {
      'id': 'a6',
      'type': 'info',
      'title': 'صيانة جهاز MRI',
      'body': 'جهاز الرنين المغناطيسي متوقف للصيانة حتى 2:00 م.',
      'acknowledged': true,
    },
    {
      'id': 'a7',
      'type': 'ems',
      'title': 'إسعاف جوي — 15 دقيقة',
      'body': 'نقل مريض من مستشفى الزرقاء. حالة قلبية.',
      'acknowledged': false,
    },
  ];

  static final List<Map<String, dynamic>> _demoFeedback = [
    {
      'patientName': 'نورا الأحمد',
      'doctor': 'د. سامي',
      'department': 'طوارئ',
      'rating': 3,
      'comment': 'استجابة سريعة وخدمة ممتازة',
    },
    {
      'patientName': 'محمد العلي',
      'doctor': 'د. ليلى',
      'department': 'باطنية',
      'rating': 2,
      'comment': 'وقت الانتظار طويل لكن العلاج جيد',
    },
    {
      'patientName': 'فاطمة الحسن',
      'doctor': 'د. خالد',
      'department': 'نسائية',
      'rating': 3,
      'comment': 'رعاية مميزة وطاقم محترف',
    },
    {
      'patientName': 'عمر النعيمي',
      'doctor': 'د. ريم',
      'department': 'قلب',
      'rating': 3,
      'comment': '',
    },
    {
      'patientName': 'سعاد البكري',
      'doctor': 'د. أحمد',
      'department': 'عظام',
      'rating': 1,
      'comment': 'يحتاج تحسين في التواصل',
    },
  ];

  Future<void> _load() async {
    final results = await Future.wait([
      HmsService.getAlerts(),
      HmsService.getFeedback(),
    ]);
    if (mounted) {
      setState(() {
        _alerts = results[0].isNotEmpty ? results[0] : _demoAlerts;
        _feedback = results[1].isNotEmpty ? results[1] : _demoFeedback;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    // Sort alerts: unacknowledged first, then by priority
    final sortedAlerts = List<Map<String, dynamic>>.from(_alerts)
      ..sort((a, b) {
        final ackA = a['acknowledged'] == true ? 1 : 0;
        final ackB = b['acknowledged'] == true ? 1 : 0;
        if (ackA != ackB) return ackA.compareTo(ackB);
        const order = {'critical': 0, 'ems': 1, 'bed': 2, 'info': 3};
        return (order[a['type']] ?? 9).compareTo(order[b['type']] ?? 9);
      });

    final critCount = _alerts.where((a) => a['type'] == 'critical').length;
    final unackCount = _alerts.where((a) => a['acknowledged'] != true).length;
    final avgRating = _feedback.isEmpty
        ? 0.0
        : _feedback.fold<double>(
                0,
                (s, f) => s + ((f['rating'] as int?) ?? 0),
              ) /
              _feedback.length;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 12),
          color: const Color(0xFF1E293B),
          child: Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'التنبيهات والتقييمات (${_alerts.length})',
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
        // Summary bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: const Color(0xFF0F172A),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _statChip('🔴', 'حرجة', '$critCount', AppColors.error),
                const SizedBox(width: 14),
                _statChip(
                  '🔔',
                  'بانتظار',
                  '$unackCount',
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 14),
                _statChip(
                  '✅',
                  'تمت',
                  '${_alerts.length - unackCount}',
                  AppColors.success,
                ),
                const SizedBox(width: 14),
                _statChip(
                  '⭐',
                  'متوسط التقييم',
                  avgRating.toStringAsFixed(1),
                  AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التنبيهات الحرجة',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...sortedAlerts.map(_alertCard),
                        const SizedBox(height: 24),
                        Text(
                          'تقييمات المرضى ⭐',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._feedback.map(_feedbackCard),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _statChip(String emoji, String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(100)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _alertCard(Map<String, dynamic> alert) {
    final type = alert['type'] as String? ?? 'info';
    final ack = alert['acknowledged'] == true;
    Color color;
    IconData icon;
    switch (type) {
      case 'critical':
        color = AppColors.error;
        icon = Icons.warning_rounded;
        break;
      case 'ems':
        color = const Color(0xFFF59E0B);
        icon = Icons.local_hospital_rounded;
        break;
      case 'bed':
        color = AppColors.info;
        icon = Icons.bed_rounded;
        break;
      default:
        color = Colors.white54;
        icon = Icons.info_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ack ? const Color(0xFF1E293B) : color.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ack ? Colors.white.withAlpha(10) : color.withAlpha(40),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  alert['title'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ack ? Colors.white54 : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert['body'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(ack ? 80 : 140),
                  ),
                ),
              ],
            ),
          ),
          if (!ack)
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() {
                  alert['acknowledged'] = true;
                });
                HmsService.acknowledgeAlert(alert['id']);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم استلام التنبيه ✅'),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _feedbackCard(Map<String, dynamic> fb) {
    final rating = (fb['rating'] as int?) ?? 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Rating stars
          Row(
            children: List.generate(
              3,
              (i) => Icon(
                i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i < rating
                    ? const Color(0xFFF59E0B)
                    : Colors.white.withAlpha(30),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fb['patientName'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${fb['doctor'] ?? ''} • ${fb['department'] ?? ''}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withAlpha(100),
                  ),
                ),
                if ((fb['comment'] as String?)?.isNotEmpty == true)
                  Text(
                    '"${fb['comment']}"',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(140),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
