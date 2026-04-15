import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/hms_service.dart';
import '../../theme.dart';

class HmsTriageScreen extends StatefulWidget {
  const HmsTriageScreen({super.key});
  @override
  State<HmsTriageScreen> createState() => _HmsTriageScreenState();
}

class _HmsTriageScreenState extends State<HmsTriageScreen> {
  List<Map<String, dynamic>> _patients = [];
  bool _loading = true;
  String _filter = 'الكل'; // الكل / red / yellow / green

  static final List<Map<String, dynamic>> _demoPatients = [
    {
      'id': 't1',
      'name': 'فالح العنزي',
      'age': 52,
      'gender': 'ذكر',
      'complaint': 'ألم شديد في الصدر مع ضيق تنفس مستمر',
      'vitals': {'hr': 118, 'temp': 37.2, 'o2': 88, 'bp': '170/100'},
      'arrivalTime': '08:42',
    },
    {
      'id': 't2',
      'name': 'سلمى الرشيد',
      'age': 34,
      'gender': 'أنثى',
      'complaint': 'حرارة مرتفعة منذ يومين مع قيء',
      'vitals': {'hr': 104, 'temp': 39.4, 'o2': 93, 'bp': '110/70'},
      'arrivalTime': '09:05',
    },
    {
      'id': 't3',
      'name': 'خالد المطيري',
      'age': 28,
      'gender': 'ذكر',
      'complaint': 'كسر مشتبه به في الكاحل بعد حادثة',
      'vitals': {'hr': 88, 'temp': 37.0, 'o2': 98, 'bp': '125/82'},
      'arrivalTime': '09:20',
    },
    {
      'id': 't4',
      'name': 'نورة القحطاني',
      'age': 67,
      'gender': 'أنثى',
      'complaint': 'دوخة شديدة وارتباك ذهني مفاجئ',
      'vitals': {'hr': 95, 'temp': 37.8, 'o2': 91, 'bp': '155/95'},
      'arrivalTime': '09:30',
    },
    {
      'id': 't5',
      'name': 'ماجد الشهري',
      'age': 19,
      'gender': 'ذكر',
      'complaint': 'ألم بطن خفيف مع غثيان',
      'vitals': {'hr': 80, 'temp': 37.4, 'o2': 97, 'bp': '118/76'},
      'arrivalTime': '09:45',
    },
    {
      'id': 't6',
      'name': 'هند العتيبي',
      'age': 41,
      'gender': 'أنثى',
      'complaint': 'صداع نصفي متكرر مع حساسية للضوء',
      'vitals': {'hr': 72, 'temp': 36.8, 'o2': 99, 'bp': '122/78'},
      'arrivalTime': '09:58',
    },
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await HmsService.getPatients(status: 'waiting');
    if (mounted) {
      setState(() {
        _patients = List<Map<String, dynamic>>.from(
          data.isNotEmpty ? data : _demoPatients,
        );
        _loading = false;
      });
    }
  }

  String _aiLevel(Map<String, dynamic> vitals) {
    final hr = vitals['hr'] as int? ?? 80;
    final temp = (vitals['temp'] as num?)?.toDouble() ?? 37.0;
    final o2 = vitals['o2'] as int? ?? 98;
    if (hr > 110 || temp > 39.0 || o2 < 90) return 'red';
    if (hr > 100 || temp > 38.0 || o2 < 94) return 'yellow';
    return 'green';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'الكل'
        ? _patients
        : _patients.where((p) {
            final v = Map<String, dynamic>.from(
              (p['vitals'] as Map?) ?? <String, dynamic>{},
            );
            return _aiLevel(v) == _filter;
          }).toList();

    final redCount = _patients.where((p) {
      final v = Map<String, dynamic>.from(
        (p['vitals'] as Map?) ?? <String, dynamic>{},
      );
      return _aiLevel(v) == 'red';
    }).length;
    final yellowCount = _patients.where((p) {
      final v = Map<String, dynamic>.from(
        (p['vitals'] as Map?) ?? <String, dynamic>{},
      );
      return _aiLevel(v) == 'yellow';
    }).length;
    final greenCount = _patients.length - redCount - yellowCount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'الفرز الطبي الذكي 🤖',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withAlpha(40)),
                  ),
                  child: Text(
                    '${_patients.length} بانتظار',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Column(
                children: [
                  // Summary bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    color: const Color(0xFF1E293B),
                    child: Row(
                      children: [
                        _summaryBadge(
                          '🔴',
                          '$redCount',
                          'حرج',
                          AppColors.error,
                        ),
                        const SizedBox(width: 10),
                        _summaryBadge(
                          '🟡',
                          '$yellowCount',
                          'متوسط',
                          const Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 10),
                        _summaryBadge(
                          '🟢',
                          '$greenCount',
                          'مستقر',
                          AppColors.success,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _load,
                          child: Icon(
                            Icons.refresh_rounded,
                            color: Colors.white.withAlpha(80),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Filter chips
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: const Color(0xFF0F172A),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip('الكل', Colors.white54),
                          const SizedBox(width: 8),
                          _filterChip('red', AppColors.error),
                          const SizedBox(width: 8),
                          _filterChip('yellow', const Color(0xFFF59E0B)),
                          const SizedBox(width: 8),
                          _filterChip('green', AppColors.success),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('✅', style: TextStyle(fontSize: 48)),
                                const SizedBox(height: 12),
                                Text(
                                  'لا يوجد مرضى بانتظار الفرز',
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
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) => _triageCard(filtered[i]),
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _summaryBadge(String emoji, String count, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(100)),
        ),
      ],
    );
  }

  Widget _filterChip(String value, Color color) {
    final selected = _filter == value;
    final label = value == 'الكل'
        ? 'الكل'
        : value == 'red'
        ? '🔴 حرج'
        : value == 'yellow'
        ? '🟡 متوسط'
        : '🟢 مستقر';
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(25) : Colors.white.withAlpha(6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.white.withAlpha(15),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? color : Colors.white.withAlpha(120),
          ),
        ),
      ),
    );
  }

  Widget _triageCard(Map<String, dynamic> patient) {
    final vitals = patient['vitals'] != null
        ? Map<String, dynamic>.from(patient['vitals'] as Map)
        : <String, dynamic>{};
    final hr = vitals['hr'] as int? ?? 80;
    final temp = (vitals['temp'] as num?)?.toDouble() ?? 37.0;
    final o2 = vitals['o2'] as int? ?? 98;
    final bp = vitals['bp'] as String? ?? '120/80';

    // AI triage suggestion
    String aiSuggestion;
    Color aiColor;
    if (hr > 110 || temp > 39.0 || o2 < 90) {
      aiSuggestion = '🔴 حالة حرجة — أولوية قصوى';
      aiColor = AppColors.error;
    } else if (hr > 100 || temp > 38.0 || o2 < 94) {
      aiSuggestion = '🟡 حالة متوسطة — مراقبة فورية';
      aiColor = const Color(0xFFF59E0B);
    } else {
      aiSuggestion = '🟢 حالة مستقرة — انتظار عادي';
      aiColor = AppColors.success;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border(right: BorderSide(color: aiColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: aiColor.withAlpha(20),
                child: Text(
                  (patient['name'] as String? ?? '؟')[0],
                  style: TextStyle(
                    color: aiColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${patient['age'] ?? ''} سنة • ${patient['gender'] ?? ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
              // Arrival time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: Colors.white.withAlpha(60),
                  ),
                  Text(
                    patient['arrivalTime'] as String? ?? '--:--',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(80),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Complaint
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.medical_information_rounded,
                  size: 16,
                  color: Colors.white.withAlpha(80),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    patient['complaint'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(160),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Vitals row
          Row(
            children: [
              _vital('❤️', '$hr', 'نبض'),
              _vital('🌡️', '$temp°', 'حرارة'),
              _vital('💉', bp, 'ضغط'),
              _vital('🫁', '$o2%', 'أكسجين'),
            ],
          ),
          const SizedBox(height: 12),
          // AI suggestion
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: aiColor.withAlpha(12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: aiColor.withAlpha(30)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.smart_toy_rounded,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  'تقييم AI:',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withAlpha(120),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    aiSuggestion,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: aiColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              _triageButton(
                'أحمر',
                AppColors.error,
                () => _setTriage(patient['id'], 'red'),
              ),
              const SizedBox(width: 8),
              _triageButton(
                'أصفر',
                const Color(0xFFF59E0B),
                () => _setTriage(patient['id'], 'yellow'),
              ),
              const SizedBox(width: 8),
              _triageButton(
                'أخضر',
                AppColors.success,
                () => _setTriage(patient['id'], 'green'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vital(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.white.withAlpha(80)),
          ),
        ],
      ),
    );
  }

  Widget _triageButton(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withAlpha(40)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setTriage(dynamic id, String level) async {
    if (id == null) return;
    HapticFeedback.mediumImpact();
    // Instantly remove from list for better UX
    setState(() {
      _patients.removeWhere((p) => p['id'] == id);
    });
    HmsService.updateTriage(id.toString(), {'triage': level});
    if (!mounted) return;
    final labels = {'red': 'أحمر', 'yellow': 'أصفر', 'green': 'أخضر'};
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تصنيف المريض مستوى ${labels[level] ?? level} ✓'),
        backgroundColor: _triageColor(level),
        duration: const Duration(seconds: 2),
      ),
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
