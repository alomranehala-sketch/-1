import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/hms_service.dart';
import '../../theme.dart';

class HmsPatientsScreen extends StatefulWidget {
  final String role;
  const HmsPatientsScreen({super.key, required this.role});
  @override
  State<HmsPatientsScreen> createState() => _HmsPatientsScreenState();
}

class _HmsPatientsScreenState extends State<HmsPatientsScreen> {
  List<Map<String, dynamic>> _patients = [];
  bool _loading = true;
  String _filter = 'all';

  // Daily stats
  int _todayCases = 0;
  int _admittedToday = 0;
  int _dischargedToday = 0;
  double _occupancyRate = 0;
  final int _totalBeds = 120;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final patients = await HmsService.getPatients();
    if (mounted) {
      setState(() {
        _patients = patients.isNotEmpty ? patients : _demoPatients;
        _todayCases = _patients.length;
        _admittedToday = _patients
            .where((p) => p['status'] != 'discharged')
            .length;
        _dischargedToday = _patients
            .where((p) => p['status'] == 'discharged')
            .length;
        _occupancyRate = (_admittedToday / _totalBeds * 100).clamp(0, 100);
        _loading = false;
      });
    }
  }

  static final List<Map<String, dynamic>> _demoPatients = [
    {
      'id': 'p1',
      'name': 'أحمد محمد الخالدي',
      'age': 45,
      'gender': 'ذكر',
      'department': 'طوارئ',
      'triageLevel': 'red',
      'status': 'in-treatment',
      'complaint': 'ألم حاد في الصدر مع ضيق تنفس',
      'room': 'ER-03',
      'vitals': {'hr': 110, 'bp': '160/95', 'temp': 37.8, 'o2': 92},
      'admittedAt': '08:30',
    },
    {
      'id': 'p2',
      'name': 'فاطمة علي الحسن',
      'age': 32,
      'gender': 'أنثى',
      'department': 'نسائية',
      'triageLevel': 'yellow',
      'status': 'in-treatment',
      'complaint': 'آلام ولادة - الحمل الثالث',
      'room': 'OB-12',
      'vitals': {'hr': 88, 'bp': '125/80', 'temp': 37.2, 'o2': 98},
      'admittedAt': '06:15',
    },
    {
      'id': 'p3',
      'name': 'عمر سعيد النعيمي',
      'age': 67,
      'gender': 'ذكر',
      'department': 'قلب',
      'triageLevel': 'red',
      'status': 'in-surgery',
      'complaint': 'جلطة قلبية حادة',
      'room': 'CCU-01',
      'vitals': {'hr': 55, 'bp': '90/60', 'temp': 36.5, 'o2': 88},
      'admittedAt': '03:45',
    },
    {
      'id': 'p4',
      'name': 'ليلى حسين الزعبي',
      'age': 28,
      'gender': 'أنثى',
      'department': 'باطنية',
      'triageLevel': 'yellow',
      'status': 'observation',
      'complaint': 'ارتفاع حرارة وغثيان مستمر',
      'room': 'M-204',
      'vitals': {'hr': 95, 'bp': '130/85', 'temp': 39.1, 'o2': 96},
      'admittedAt': '11:00',
    },
    {
      'id': 'p5',
      'name': 'خالد إبراهيم عبدالله',
      'age': 55,
      'gender': 'ذكر',
      'department': 'عظام',
      'triageLevel': 'green',
      'status': 'waiting',
      'complaint': 'كسر في الساعد الأيمن',
      'room': 'OR-W2',
      'vitals': {'hr': 78, 'bp': '120/75', 'temp': 36.8, 'o2': 99},
      'admittedAt': '13:20',
    },
    {
      'id': 'p6',
      'name': 'سارة وليد المصري',
      'age': 8,
      'gender': 'أنثى',
      'department': 'أطفال',
      'triageLevel': 'yellow',
      'status': 'in-treatment',
      'complaint': 'حساسية شديدة مع طفح جلدي',
      'room': 'PED-06',
      'vitals': {'hr': 105, 'bp': '100/65', 'temp': 38.3, 'o2': 97},
      'admittedAt': '09:50',
    },
    {
      'id': 'p7',
      'name': 'محمود عادل الشمالي',
      'age': 72,
      'gender': 'ذكر',
      'department': 'أعصاب',
      'triageLevel': 'red',
      'status': 'in-treatment',
      'complaint': 'اشتباه جلطة دماغية - ضعف بالجانب الأيسر',
      'room': 'NICU-02',
      'vitals': {'hr': 68, 'bp': '180/110', 'temp': 37.0, 'o2': 94},
      'admittedAt': '07:10',
    },
    {
      'id': 'p8',
      'name': 'نور الدين محمد',
      'age': 40,
      'gender': 'ذكر',
      'department': 'جراحة',
      'triageLevel': 'green',
      'status': 'discharged',
      'complaint': 'استئصال الزائدة الدودية - بعد العملية',
      'room': 'S-108',
      'vitals': {'hr': 72, 'bp': '118/72', 'temp': 36.9, 'o2': 99},
      'admittedAt': '05:00',
    },
    {
      'id': 'p9',
      'name': 'رنا أمجد الطراونة',
      'age': 50,
      'gender': 'أنثى',
      'department': 'عناية مركزة',
      'triageLevel': 'red',
      'status': 'in-treatment',
      'complaint': 'قصور تنفسي حاد - تحتاج تنفس اصطناعي',
      'room': 'ICU-04',
      'vitals': {'hr': 120, 'bp': '85/55', 'temp': 38.5, 'o2': 85},
      'admittedAt': '01:30',
    },
    {
      'id': 'p10',
      'name': 'يوسف كمال البطاينة',
      'age': 19,
      'gender': 'ذكر',
      'department': 'طوارئ',
      'triageLevel': 'green',
      'status': 'discharged',
      'complaint': 'جرح بسيط في الرأس - تم خياطته',
      'room': 'ER-07',
      'vitals': {'hr': 80, 'bp': '115/70', 'temp': 36.7, 'o2': 99},
      'admittedAt': '12:45',
    },
    {
      'id': 'p11',
      'name': 'هند سامي القضاة',
      'age': 35,
      'gender': 'أنثى',
      'department': 'باطنية',
      'triageLevel': 'yellow',
      'status': 'waiting',
      'complaint': 'آلام شديدة في البطن مع تقيؤ',
      'room': 'M-W1',
      'vitals': {'hr': 92, 'bp': '128/82', 'temp': 37.6, 'o2': 97},
      'admittedAt': '14:05',
    },
    {
      'id': 'p12',
      'name': 'عبدالرحمن فيصل',
      'age': 60,
      'gender': 'ذكر',
      'department': 'قلب',
      'triageLevel': 'yellow',
      'status': 'observation',
      'complaint': 'خفقان وعدم انتظام ضربات القلب',
      'room': 'CCU-05',
      'vitals': {'hr': 130, 'bp': '145/90', 'temp': 36.6, 'o2': 95},
      'admittedAt': '10:20',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'all') return _patients;
    if (_filter == 'red' || _filter == 'yellow' || _filter == 'green') {
      return _patients.where((p) => p['triageLevel'] == _filter).toList();
    }
    return _patients.where((p) => p['status'] == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 12),
          color: const Color(0xFF1E293B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🏥', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  const Text(
                    'المرضى',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_patients.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('الكل', 'all'),
                    _chip('🔴 حرج', 'red'),
                    _chip('🟡 متوسط', 'yellow'),
                    _chip('🟢 بسيط', 'green'),
                    _chip('بالانتظار', 'waiting'),
                    _chip('قيد العلاج', 'in-treatment'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Daily stats cards
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          color: const Color(0xFF0F172A),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  const Text(
                    'إحصائيات اليوم',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _todayDate(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withAlpha(100),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _statCard(
                    'حالات اليوم',
                    '$_todayCases',
                    Icons.people_alt_rounded,
                    AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  _statCard(
                    'نسبة الإشغال',
                    '${_occupancyRate.toStringAsFixed(0)}%',
                    Icons.hotel_rounded,
                    _occupancyRate > 80
                        ? AppColors.error
                        : _occupancyRate > 60
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _statCard(
                    'دخلوا اليوم',
                    '$_admittedToday',
                    Icons.login_rounded,
                    const Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 8),
                  _statCard(
                    'خرجوا اليوم',
                    '$_dischargedToday',
                    Icons.logout_rounded,
                    AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Occupancy progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _occupancyRate / 100,
                  minHeight: 6,
                  backgroundColor: Colors.white.withAlpha(15),
                  color: _occupancyRate > 80
                      ? AppColors.error
                      : _occupancyRate > 60
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إجمالي الأسرّة: $_totalBeds',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withAlpha(80),
                    ),
                  ),
                  Text(
                    'مشغولة: $_admittedToday | متاحة: ${_totalBeds - _admittedToday}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withAlpha(80),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Patient list
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'لا يوجد مرضى',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _patientCard(_filtered[i]),
                        ),
                ),
        ),
      ],
    );
  }

  String _todayDate() {
    final now = DateTime.now();
    final months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${now.day} ${months[now.month]} ${now.year}';
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(120),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final active = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _filter = value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withAlpha(30)
                : Colors.white.withAlpha(8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active
                  ? AppColors.primary.withAlpha(60)
                  : Colors.white.withAlpha(15),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primary : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _patientCard(Map<String, dynamic> p) {
    final triage = p['triageLevel'] as String? ?? 'green';
    final triageColor = triage == 'red'
        ? AppColors.error
        : triage == 'yellow'
        ? AppColors.warning
        : AppColors.success;
    final status = p['status'] as String? ?? '';
    final vitals = p['vitals'] != null
        ? Map<String, dynamic>.from(p['vitals'] as Map)
        : <String, dynamic>{};

    String statusLabel;
    Color statusColor;
    switch (status) {
      case 'waiting':
        statusLabel = 'بالانتظار';
        statusColor = AppColors.warning;
        break;
      case 'in-treatment':
        statusLabel = 'قيد العلاج';
        statusColor = AppColors.info;
        break;
      case 'in-surgery':
        statusLabel = 'في العمليات';
        statusColor = AppColors.error;
        break;
      case 'observation':
        statusLabel = 'مراقبة';
        statusColor = const Color(0xFFA855F7);
        break;
      case 'discharged':
        statusLabel = 'خرج';
        statusColor = AppColors.success;
        break;
      default:
        statusLabel = status;
        statusColor = Colors.white70;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border(right: BorderSide(color: triageColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Triage dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: triageColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: triageColor.withAlpha(80), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  p['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${p['age']}y • ${p['gender']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withAlpha(120),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.local_hospital_rounded,
                size: 12,
                color: Colors.white.withAlpha(80),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  p['department'] ?? '—',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(120),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if ((p['complaint'] as String?)?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '💬 ${p['complaint']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withAlpha(160),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 8),
          // Vitals row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _vital('❤️', '${vitals['hr'] ?? 0}', 'نبض'),
                _vital('🩸', '${vitals['bp'] ?? '—'}', 'ضغط'),
                _vital('🌡️', '${vitals['temp'] ?? 0}°', 'حرارة'),
                _vital('🫁', '${vitals['o2'] ?? 0}%', 'أكسجين'),
                if (p['room'] != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '📍 ${p['room']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Action buttons
          Row(
            children: [
              _actionBtn(
                'تحديث حالة',
                Icons.edit_rounded,
                AppColors.info,
                () => _showStatusDialog(p),
              ),
              const SizedBox(width: 8),
              _actionBtn(
                'نقل قسم',
                Icons.swap_horiz_rounded,
                AppColors.warning,
                () => _showTransferDialog(p),
              ),
              const SizedBox(width: 8),
              _actionBtn(
                'خروج',
                Icons.logout_rounded,
                AppColors.success,
                () => _dischargePatient(p),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vital(String emoji, String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 10)),
              const SizedBox(width: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.white.withAlpha(80)),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withAlpha(30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusDialog(Map<String, dynamic> p) {
    final statuses = [
      'waiting',
      'in-treatment',
      'in-surgery',
      'observation',
      'discharged',
    ];
    final labels = ['بالانتظار', 'قيد العلاج', 'في العمليات', 'مراقبة', 'خرج'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'تحديث حالة المريض',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              RadioGroup<String>(
                groupValue: p['status'] as String? ?? '',
                onChanged: (v) async {
                  Navigator.pop(context);
                  await HmsService.updatePatientStatus(p['id'] ?? '', {
                    'status': v,
                  });
                  _load();
                },
                child: Column(
                  children: List.generate(
                    statuses.length,
                    (i) => RadioListTile<String>(
                      title: Text(
                        labels[i],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      value: statuses[i],
                      activeColor: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransferDialog(Map<String, dynamic> p) {
    final departments = [
      'طوارئ',
      'باطنية',
      'جراحة',
      'أطفال',
      'قلب',
      'نسائية',
      'عظام',
      'أعصاب',
      'عناية مركزة',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'نقل المريض لقسم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: departments
                    .map(
                      (d) => GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          await HmsService.updatePatientStatus(p['id'] ?? '', {
                            'department': d,
                          });
                          _load();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم نقل ${p['name']} إلى $d'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: d == p['department']
                                ? AppColors.primary.withAlpha(30)
                                : Colors.white.withAlpha(8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: d == p['department']
                                  ? AppColors.primary
                                  : Colors.white.withAlpha(15),
                            ),
                          ),
                          child: Text(
                            d,
                            style: TextStyle(
                              fontSize: 13,
                              color: d == p['department']
                                  ? AppColors.primary
                                  : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _dischargePatient(Map<String, dynamic> p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'تأكيد خروج المريض',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          content: Text(
            'هل تريد إخراج ${p['name']}؟',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text(
                'تأكيد الخروج',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await HmsService.updatePatientStatus(p['id'] ?? '', {
        'status': 'discharged',
      });
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إخراج ${p['name']} بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
