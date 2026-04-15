import 'package:flutter/material.dart';
import '../../services/hms_service.dart';
import '../../theme.dart';

/// Patient Tracking — Timeline of patient journey through the hospital
class HmsTrackingScreen extends StatefulWidget {
  const HmsTrackingScreen({super.key});
  @override
  State<HmsTrackingScreen> createState() => _HmsTrackingScreenState();
}

class _HmsTrackingScreenState extends State<HmsTrackingScreen> {
  List<Map<String, dynamic>> _patients = [];
  bool _loading = true;
  Map<String, dynamic>? _selected;

  static final List<Map<String, dynamic>> _demoPatients = [
    {
      'id': 'tr1',
      'name': 'أحمد النمر',
      'age': 45,
      'gender': 'ذكر',
      'triage': 'red',
      'department': 'طوارئ',
      'room': '101',
      'step': 4, // 0-5, current step index
      'complaint': 'ألم صدري مع ضيق تنفس',
      'admitTime': '07:15',
      'estimatedDischarge': '14:00',
    },
    {
      'id': 'tr2',
      'name': 'منى الحربي',
      'age': 38,
      'gender': 'أنثى',
      'triage': 'yellow',
      'department': 'باطنية',
      'room': '204',
      'step': 3,
      'complaint': 'حمى مستمرة وغثيان',
      'admitTime': '08:30',
      'estimatedDischarge': '16:00',
    },
    {
      'id': 'tr3',
      'name': 'نواف الزهراني',
      'age': 22,
      'gender': 'ذكر',
      'triage': 'yellow',
      'department': 'جراحة',
      'room': '310',
      'step': 2,
      'complaint': 'كسر في الكاحل',
      'admitTime': '09:00',
      'estimatedDischarge': '18:00',
    },
    {
      'id': 'tr4',
      'name': 'ريم الشمري',
      'age': 55,
      'gender': 'أنثى',
      'triage': 'green',
      'department': 'باطنية',
      'room': '215',
      'step': 4,
      'complaint': 'صداع وارتفاع طفيف في السكر',
      'admitTime': '06:45',
      'estimatedDischarge': '13:00',
    },
    {
      'id': 'tr5',
      'name': 'عبدالله القرني',
      'age': 72,
      'gender': 'ذكر',
      'triage': 'red',
      'department': 'عناية مركزة',
      'room': 'ICU-3',
      'step': 3,
      'complaint': 'سكتة دماغية طارئة',
      'admitTime': '05:20',
      'estimatedDischarge': '—',
    },
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await HmsService.getPatients(status: 'in-treatment');
    if (mounted) {
      setState(() {
        _patients = data.isNotEmpty ? data : _demoPatients;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'تتبع المرضى 📍',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _selected != null
            ? _patientTimeline(_selected!)
            : _patientList(),
      ),
    );
  }

  Widget _patientList() {
    if (_patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📋', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'لا يوجد مرضى قيد العلاج حاليًا',
              style: TextStyle(
                color: Colors.white.withAlpha(120),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _patients.length,
        itemBuilder: (_, i) {
          final p = _patients[i];
          final triColor = _triageColor(p['triage'] ?? 'green');
          final step = (p['step'] as int?) ?? 3;
          final progress = ((step + 1) / 6).clamp(0.0, 1.0);

          return GestureDetector(
            onTap: () => setState(() => _selected = p),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border(right: BorderSide(color: triColor, width: 4)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: triColor.withAlpha(20),
                        child: Text(
                          (p['name'] as String? ?? '؟')[0],
                          style: TextStyle(
                            color: triColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${p['department'] ?? ''} • غرفة ${p['room'] ?? '-'}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withAlpha(100),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'دخول ${p['admitTime'] ?? '--:--'}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withAlpha(70),
                            ),
                          ),
                          if ((p['estimatedDischarge'] as String?)
                                      ?.isNotEmpty ==
                                  true &&
                              p['estimatedDischarge'] != '—')
                            Text(
                              'خروج ~${p['estimatedDischarge']}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white.withAlpha(60),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Journey progress bar
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _stepLabel(step),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withAlpha(100),
                              ),
                            ),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white.withAlpha(10),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  triColor,
                                ),
                                minHeight: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${((progress) * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: triColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _stepLabel(int step) {
    const labels = [
      'تسجيل الدخول',
      'الفرز الطبي',
      'الفحص الطبي',
      'التحاليل والأشعة',
      'قيد العلاج',
      'جاهز للخروج',
    ];
    if (step < labels.length) return '📍 ${labels[step]}';
    return '📍 قيد العلاج';
  }

  Widget _patientTimeline(Map<String, dynamic> patient) {
    final currentStep = (patient['step'] as int?) ?? 3;
    final admitTime = patient['admitTime'] as String? ?? '--:--';
    final triColor = _triageColor(patient['triage'] ?? 'green');

    // Generate steps with dynamic done/time based on current step
    final stepDefs = [
      {
        'title': 'تسجيل الدخول',
        'desc': 'الاستقبال — تسجيل بيانات المريض',
        'icon': Icons.login_rounded,
      },
      {
        'title': 'الفرز الطبي',
        'desc': 'تقييم أولي — مستوى ${patient['triage'] ?? 'أخضر'}',
        'icon': Icons.smart_toy_rounded,
      },
      {
        'title': 'الفحص الطبي',
        'desc':
            'قسم ${patient['department'] ?? 'طوارئ'} — غرفة ${patient['room'] ?? '-'}',
        'icon': Icons.medical_services_rounded,
      },
      {
        'title': 'التحاليل والأشعة',
        'desc': 'طلب تحاليل دم + أشعة سينية',
        'icon': Icons.biotech_rounded,
      },
      {
        'title': 'قيد العلاج',
        'desc': 'علاج معتمد — مراقبة حيوية',
        'icon': Icons.healing_rounded,
      },
      {
        'title': 'الخروج',
        'desc':
            'بانتظار إذن الطبيب — خروج متوقع ${patient['estimatedDischarge'] ?? '--:--'}',
        'icon': Icons.exit_to_app_rounded,
      },
    ];

    // Generate realistic times based on admit time
    int baseMin = 0;
    try {
      final parts = admitTime.split(':');
      baseMin = (int.parse(parts[0]) * 60) + int.parse(parts[1]);
    } catch (_) {}
    final timeOffsets = [0, 5, 15, 30, 60, 180];

    final steps = List.generate(stepDefs.length, (i) {
      final isDone = i <= currentStep;
      final totalMin = baseMin + timeOffsets[i];
      final h = (totalMin ~/ 60).toString().padLeft(2, '0');
      final m = (totalMin % 60).toString().padLeft(2, '0');
      return {
        ...stepDefs[i],
        'done': isDone,
        'time': isDone ? '$h:$m' : '--:--',
      };
    });

    return Column(
      children: [
        // Patient header
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1E293B),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selected = null),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundColor: triColor.withAlpha(20),
                child: Text(
                  (patient['name'] as String? ?? '؟')[0],
                  style: TextStyle(
                    color: triColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${patient['age'] ?? ''} سنة • ${patient['department'] ?? ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: steps.length,
            itemBuilder: (_, i) {
              final step = steps[i];
              final done = step['done'] as bool;
              final isLast = i == steps.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline line
                    SizedBox(
                      width: 40,
                      child: Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done
                                  ? AppColors.success.withAlpha(20)
                                  : Colors.white.withAlpha(8),
                              border: Border.all(
                                color: done
                                    ? AppColors.success
                                    : Colors.white.withAlpha(20),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              done
                                  ? Icons.check_rounded
                                  : (step['icon'] as IconData),
                              size: 14,
                              color: done
                                  ? AppColors.success
                                  : Colors.white.withAlpha(60),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                color: done
                                    ? AppColors.success.withAlpha(40)
                                    : Colors.white.withAlpha(10),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: done
                              ? const Color(0xFF1E293B)
                              : Colors.white.withAlpha(5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: done
                                ? AppColors.success.withAlpha(15)
                                : Colors.white.withAlpha(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step['title'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: done
                                          ? Colors.white
                                          : Colors.white.withAlpha(80),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    step['desc'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withAlpha(
                                        done ? 120 : 60,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              step['time'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: done
                                    ? AppColors.success
                                    : Colors.white.withAlpha(40),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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
