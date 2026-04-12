import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Live Queue — الطابور الحي في المستشفيات العامة
/// See people in line + accurate ETA in real-time
class LiveQueueScreen extends StatefulWidget {
  const LiveQueueScreen({super.key});
  @override
  State<LiveQueueScreen> createState() => _LiveQueueScreenState();
}

class _LiveQueueScreenState extends State<LiveQueueScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  Timer? _timer;
  int _selectedHospital = 0;

  // Queue booking state
  bool _bookedInQueue = false;
  String _bookedHospital = '';
  String _bookedDept = '';
  int _myQueueNumber = 0;
  int _myEstimatedMinutes = 0;

  final _hospitals = [
    _HospitalQueue('مستشفى الجامعة الأردنية', 'عمّان', [
      _DeptQueue(
        'الطوارئ',
        23,
        45,
        const Color(0xFFEF4444),
        Icons.emergency_rounded,
      ),
      _DeptQueue(
        'العيادات الخارجية',
        56,
        90,
        const Color(0xFF3B82F6),
        Icons.local_hospital_rounded,
      ),
      _DeptQueue(
        'المختبر',
        12,
        20,
        const Color(0xFF10B981),
        Icons.science_rounded,
      ),
      _DeptQueue(
        'الأشعة',
        8,
        35,
        const Color(0xFFF59E0B),
        Icons.medical_information_rounded,
      ),
      _DeptQueue(
        'الصيدلية',
        15,
        15,
        const Color(0xFF8B5CF6),
        Icons.local_pharmacy_rounded,
      ),
    ]),
    _HospitalQueue('مستشفى البشير', 'عمّان', [
      _DeptQueue(
        'الطوارئ',
        31,
        60,
        const Color(0xFFEF4444),
        Icons.emergency_rounded,
      ),
      _DeptQueue(
        'العيادات الخارجية',
        78,
        120,
        const Color(0xFF3B82F6),
        Icons.local_hospital_rounded,
      ),
      _DeptQueue(
        'المختبر',
        20,
        30,
        const Color(0xFF10B981),
        Icons.science_rounded,
      ),
      _DeptQueue(
        'الأشعة',
        14,
        50,
        const Color(0xFFF59E0B),
        Icons.medical_information_rounded,
      ),
      _DeptQueue(
        'الصيدلية',
        25,
        25,
        const Color(0xFF8B5CF6),
        Icons.local_pharmacy_rounded,
      ),
    ]),
    _HospitalQueue('مستشفى الأمير حمزة', 'عمّان', [
      _DeptQueue(
        'الطوارئ',
        18,
        35,
        const Color(0xFFEF4444),
        Icons.emergency_rounded,
      ),
      _DeptQueue(
        'العيادات الخارجية',
        42,
        70,
        const Color(0xFF3B82F6),
        Icons.local_hospital_rounded,
      ),
      _DeptQueue(
        'المختبر',
        9,
        15,
        const Color(0xFF10B981),
        Icons.science_rounded,
      ),
      _DeptQueue(
        'الأشعة',
        5,
        25,
        const Color(0xFFF59E0B),
        Icons.medical_information_rounded,
      ),
      _DeptQueue(
        'الصيدلية',
        11,
        12,
        const Color(0xFF8B5CF6),
        Icons.local_pharmacy_rounded,
      ),
    ]),
    _HospitalQueue('مستشفى الملك المؤسس', 'عمّان', [
      _DeptQueue(
        'الطوارئ',
        15,
        30,
        const Color(0xFFEF4444),
        Icons.emergency_rounded,
      ),
      _DeptQueue(
        'العيادات الخارجية',
        35,
        55,
        const Color(0xFF3B82F6),
        Icons.local_hospital_rounded,
      ),
      _DeptQueue(
        'المختبر',
        7,
        12,
        const Color(0xFF10B981),
        Icons.science_rounded,
      ),
      _DeptQueue(
        'الأشعة',
        4,
        20,
        const Color(0xFFF59E0B),
        Icons.medical_information_rounded,
      ),
      _DeptQueue(
        'الصيدلية',
        8,
        10,
        const Color(0xFF8B5CF6),
        Icons.local_pharmacy_rounded,
      ),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    // Simulate live updates
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {
          for (final h in _hospitals) {
            for (final d in h.departments) {
              d.peopleInLine += Random().nextInt(3) - 1;
              if (d.peopleInLine < 0) d.peopleInLine = 0;
              d.etaMinutes += Random().nextInt(5) - 2;
              if (d.etaMinutes < 5) d.etaMinutes = 5;
            }
          }
          // Update my queue position
          if (_bookedInQueue && _myEstimatedMinutes > 0) {
            _myEstimatedMinutes -= Random().nextInt(3);
            if (_myEstimatedMinutes < 0) _myEstimatedMinutes = 0;
            // Simulate notification when close to turn
            if (_myEstimatedMinutes <= 10 && _myEstimatedMinutes > 7) {
              _showQueueNotification();
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

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
              title: Row(
                children: [
                  const Text(
                    'الطابور الحي',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, _) => Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          AppColors.success,
                          AppColors.success.withAlpha(100),
                          _pulseCtrl.value,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: _buildHospitalTabs()),
            if (_bookedInQueue) SliverToBoxAdapter(child: _buildMyQueueCard()),
            SliverToBoxAdapter(child: _buildSummaryCard()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _buildDeptCard(
                  _hospitals[_selectedHospital].departments[i],
                ),
                childCount: _hospitals[_selectedHospital].departments.length,
              ),
            ),
            SliverToBoxAdapter(child: _buildTipCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalTabs() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _hospitals.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _selectedHospital == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedHospital = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.border.withAlpha(40),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _hospitals[i].name.replaceAll('مستشفى ', ''),
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textMedium,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard() {
    final h = _hospitals[_selectedHospital];
    final totalPeople = h.departments.fold<int>(
      0,
      (sum, d) => sum + d.peopleInLine,
    );
    final avgEta =
        h.departments.fold<int>(0, (sum, d) => sum + d.etaMinutes) ~/
        h.departments.length;
    final busiestDept = h.departments.reduce(
      (a, b) => a.peopleInLine > b.peopleInLine ? a : b,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF0F172A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            h.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            h.location,
            style: const TextStyle(color: AppColors.textLight, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _summaryItem(
                'إجمالي المنتظرين',
                '$totalPeople',
                Icons.people_rounded,
                const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 12),
              _summaryItem(
                'متوسط الانتظار',
                '$avgEta د',
                Icons.access_time_rounded,
                const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 12),
              _summaryItem(
                'الأكثر ازدحاماً',
                busiestDept.name,
                Icons.trending_up_rounded,
                const Color(0xFFEF4444),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: AppColors.textLight, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptCard(_DeptQueue dept) {
    final crowdLevel = dept.peopleInLine > 50
        ? 'مزدحم'
        : dept.peopleInLine > 20
        ? 'متوسط'
        : 'هادئ';
    final crowdColor = dept.peopleInLine > 50
        ? const Color(0xFFEF4444)
        : dept.peopleInLine > 20
        ? const Color(0xFFF59E0B)
        : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: dept.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(dept.icon, color: dept.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dept.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: crowdColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          crowdLevel,
                          style: TextStyle(
                            color: crowdColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.people_rounded,
                        color: AppColors.textLight,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dept.peopleInLine}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '~${dept.etaMinutes} دقيقة',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (dept.peopleInLine / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.border.withAlpha(30),
              color: crowdColor,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'سيتم إشعارك عندما يقل الازدحام في ${dept.name}',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: dept.color,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_active_rounded,
                    size: 14,
                  ),
                  label: const Text(
                    'نبهني لما يقل',
                    style: TextStyle(fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: dept.color,
                    side: BorderSide(color: dept.color.withAlpha(60)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showBookingDialog(dept),
                  icon: const Icon(Icons.add_rounded, size: 14),
                  label: const Text(
                    'سجل بالدور',
                    style: TextStyle(fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dept.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyQueueCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.confirmation_number_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'دورك محجوز! ✅',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _bookedInQueue = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ تم إلغاء الدور'),
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
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _queueInfoBox('رقمك', '#$_myQueueNumber', Icons.tag_rounded),
              const SizedBox(width: 8),
              _queueInfoBox(
                'المكان',
                _bookedDept,
                Icons.local_hospital_rounded,
              ),
              const SizedBox(width: 8),
              _queueInfoBox(
                'الانتظار',
                '~$_myEstimatedMinutes د',
                Icons.timer_rounded,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$_bookedHospital — رح يوصلك إشعار قبل دورك بـ 10 دقائق',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_myEstimatedMinutes <= 10)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🔔 دورك قريب! انطلق للمستشفى الآن',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _queueInfoBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(_DeptQueue dept) {
    final hospital = _hospitals[_selectedHospital];
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'احجز دورك من البيت 🏠',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogInfoRow(
                Icons.local_hospital_rounded,
                hospital.name,
                const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 8),
              _dialogInfoRow(dept.icon, dept.name, dept.color),
              const SizedBox(height: 8),
              _dialogInfoRow(
                Icons.people_rounded,
                '${dept.peopleInLine} شخص قبلك',
                const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 8),
              _dialogInfoRow(
                Icons.timer_rounded,
                'الانتظار المتوقع: ~${dept.etaMinutes} دقيقة',
                const Color(0xFF10B981),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withAlpha(10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF06B6D4).withAlpha(30),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFF06B6D4),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'رح نرسلك إشعار قبل دورك بـ 10 دقائق عشان تنطلق',
                        style: TextStyle(
                          color: Color(0xFF06B6D4),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: AppColors.textLight),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                HapticFeedback.heavyImpact();
                setState(() {
                  _bookedInQueue = true;
                  _bookedHospital = hospital.name;
                  _bookedDept = dept.name;
                  _myQueueNumber = dept.peopleInLine + 1;
                  _myEstimatedMinutes = dept.etaMinutes + 5;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✅ تم حجز دورك #$_myQueueNumber في ${dept.name} — رح نبلغك لما يقترب!',
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF10B981),
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text(
                'احجز الدور',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _showQueueNotification() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '🔔 دورك قريب في $_bookedDept! الانتظار ~$_myEstimatedMinutes دقائق — انطلق الآن',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.info,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '💡 نصيحة: أفضل وقت للزيارة بين 10-12 صباحاً — الزحمة أقل بنسبة 40%',
              style: TextStyle(
                color: AppColors.info,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HospitalQueue {
  final String name, location;
  final List<_DeptQueue> departments;
  _HospitalQueue(this.name, this.location, this.departments);
}

class _DeptQueue {
  final String name;
  int peopleInLine, etaMinutes;
  final Color color;
  final IconData icon;
  _DeptQueue(
    this.name,
    this.peopleInLine,
    this.etaMinutes,
    this.color,
    this.icon,
  );
}
