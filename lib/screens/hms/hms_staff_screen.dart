import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme.dart';

class HmsStaffScreen extends StatefulWidget {
  const HmsStaffScreen({super.key});
  @override
  State<HmsStaffScreen> createState() => _HmsStaffScreenState();
}

class _HmsStaffScreenState extends State<HmsStaffScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _searchQuery = '';
  String _deptFilter = 'الكل';

  static const _departments = [
    'الكل',
    'طوارئ',
    'باطنية',
    'قلب',
    'جراحة',
    'عظام',
    'أطفال',
    'عناية مركزة',
    'نسائية',
  ];

  // ── Demo Staff Data ──
  static final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'د. سامي الخطيب',
      'specialty': 'طوارئ',
      'dept': 'طوارئ',
      'phone': '0791234567',
      'status': 'on-duty',
      'shiftStart': '07:00',
      'shiftEnd': '19:00',
      'patientsToday': 12,
      'yearsExp': 15,
      'rating': 4.8,
      'avatar': '👨‍⚕️',
      'badges': ['أفضل طبيب Q1', 'إنجاز 1000 حالة'],
    },
    {
      'name': 'د. ليلى الأحمد',
      'specialty': 'قلب وأوعية',
      'dept': 'قلب',
      'phone': '0797654321',
      'status': 'on-duty',
      'shiftStart': '08:00',
      'shiftEnd': '16:00',
      'patientsToday': 8,
      'yearsExp': 12,
      'rating': 4.9,
      'avatar': '👩‍⚕️',
      'badges': ['متخصصة قسطرة'],
    },
    {
      'name': 'د. خالد العمري',
      'specialty': 'جراحة عامة',
      'dept': 'جراحة',
      'phone': '0781112233',
      'status': 'on-duty',
      'shiftStart': '07:00',
      'shiftEnd': '15:00',
      'patientsToday': 5,
      'yearsExp': 20,
      'rating': 4.7,
      'avatar': '👨‍⚕️',
      'badges': ['رئيس قسم الجراحة'],
    },
    {
      'name': 'د. ريم الحسن',
      'specialty': 'أطفال',
      'dept': 'أطفال',
      'phone': '0799887766',
      'status': 'off-duty',
      'shiftStart': '19:00',
      'shiftEnd': '07:00',
      'patientsToday': 0,
      'yearsExp': 8,
      'rating': 4.6,
      'avatar': '👩‍⚕️',
      'badges': [],
    },
    {
      'name': 'د. أحمد النجار',
      'specialty': 'عناية مركزة',
      'dept': 'عناية مركزة',
      'phone': '0785554433',
      'status': 'on-duty',
      'shiftStart': '07:00',
      'shiftEnd': '19:00',
      'patientsToday': 9,
      'yearsExp': 18,
      'rating': 4.9,
      'avatar': '👨‍⚕️',
      'badges': ['أفضل أداء ICU'],
    },
    {
      'name': 'د. منى القاسم',
      'specialty': 'نسائية وتوليد',
      'dept': 'نسائية',
      'phone': '0792223344',
      'status': 'on-leave',
      'shiftStart': '-',
      'shiftEnd': '-',
      'patientsToday': 0,
      'yearsExp': 10,
      'rating': 4.5,
      'avatar': '👩‍⚕️',
      'badges': [],
    },
    {
      'name': 'د. عمر الصالح',
      'specialty': 'باطنية',
      'dept': 'باطنية',
      'phone': '0786667788',
      'status': 'on-duty',
      'shiftStart': '08:00',
      'shiftEnd': '20:00',
      'patientsToday': 11,
      'yearsExp': 14,
      'rating': 4.4,
      'avatar': '👨‍⚕️',
      'badges': [],
    },
    {
      'name': 'د. هند الزعبي',
      'specialty': 'عظام',
      'dept': 'عظام',
      'phone': '0793334455',
      'status': 'on-duty',
      'shiftStart': '07:00',
      'shiftEnd': '15:00',
      'patientsToday': 6,
      'yearsExp': 9,
      'rating': 4.7,
      'avatar': '👩‍⚕️',
      'badges': ['زمالة عظام بريطانية'],
    },
  ];

  static final List<Map<String, dynamic>> _nurses = [
    {
      'name': 'فاطمة الحمد',
      'specialty': 'تمريض طوارئ',
      'dept': 'طوارئ',
      'phone': '0791001001',
      'status': 'on-duty',
      'shiftStart': '07:00',
      'shiftEnd': '19:00',
      'patientsToday': 15,
      'yearsExp': 7,
      'rating': 4.8,
      'avatar': '👩‍⚕️',
      'badges': ['رئيسة تمريض الطوارئ'],
    },
    {
      'name': 'نور الشريف',
      'specialty': 'عناية مركزة',
      'dept': 'عناية مركزة',
      'phone': '0792002002',
      'status': 'on-duty',
      'shiftStart': '07:00',
      'shiftEnd': '19:00',
      'patientsToday': 4,
      'yearsExp': 10,
      'rating': 4.9,
      'avatar': '👩‍⚕️',
      'badges': ['شهادة ACLS'],
    },
    {
      'name': 'أمجد العبادي',
      'specialty': 'تمريض جراحة',
      'dept': 'جراحة',
      'phone': '0783003003',
      'status': 'on-duty',
      'shiftStart': '08:00',
      'shiftEnd': '20:00',
      'patientsToday': 7,
      'yearsExp': 5,
      'rating': 4.5,
      'avatar': '🧑‍⚕️',
      'badges': [],
    },
    {
      'name': 'سلمى البكري',
      'specialty': 'تمريض أطفال',
      'dept': 'أطفال',
      'phone': '0794004004',
      'status': 'off-duty',
      'shiftStart': '19:00',
      'shiftEnd': '07:00',
      'patientsToday': 0,
      'yearsExp': 6,
      'rating': 4.6,
      'avatar': '👩‍⚕️',
      'badges': [],
    },
    {
      'name': 'يزن الكيلاني',
      'specialty': 'تمريض قلب',
      'dept': 'قلب',
      'phone': '0785005005',
      'status': 'on-duty',
      'shiftStart': '07:00',
      'shiftEnd': '15:00',
      'patientsToday': 6,
      'yearsExp': 8,
      'rating': 4.7,
      'avatar': '🧑‍⚕️',
      'badges': ['مسؤول أجهزة القلب'],
    },
    {
      'name': 'رنا الخالدي',
      'specialty': 'تمريض باطنية',
      'dept': 'باطنية',
      'phone': '0796006006',
      'status': 'on-leave',
      'shiftStart': '-',
      'shiftEnd': '-',
      'patientsToday': 0,
      'yearsExp': 4,
      'rating': 4.3,
      'avatar': '👩‍⚕️',
      'badges': [],
    },
    {
      'name': 'طارق المعاني',
      'specialty': 'تمريض عظام',
      'dept': 'عظام',
      'phone': '0787007007',
      'status': 'on-duty',
      'shiftStart': '07:00',
      'shiftEnd': '19:00',
      'patientsToday': 8,
      'yearsExp': 11,
      'rating': 4.8,
      'avatar': '🧑‍⚕️',
      'badges': ['أخصائي جبائر'],
    },
    {
      'name': 'دينا الرفاعي',
      'specialty': 'تمريض نسائية',
      'dept': 'نسائية',
      'phone': '0798008008',
      'status': 'on-duty',
      'shiftStart': '08:00',
      'shiftEnd': '16:00',
      'patientsToday': 5,
      'yearsExp': 9,
      'rating': 4.6,
      'avatar': '👩‍⚕️',
      'badges': [],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> list) {
    return list.where((s) {
      if (_deptFilter != 'الكل' && s['dept'] != _deptFilter) return false;
      if (_searchQuery.isNotEmpty &&
          !(s['name'] as String).contains(_searchQuery) &&
          !(s['specialty'] as String).contains(_searchQuery))
        return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        // ── Header ──
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 0),
          color: const Color(0xFF1E293B),
          child: Column(
            children: [
              const Row(
                children: [
                  Text('🩺', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'الكادر الطبي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم أو التخصص...',
                    hintStyle: TextStyle(
                      color: Colors.white.withAlpha(60),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withAlpha(60),
                      size: 20,
                    ),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(height: 10),
              // Department filter
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _departments.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final d = _departments[i];
                    final sel = d == _deptFilter;
                    return GestureDetector(
                      onTap: () => setState(() => _deptFilter = d),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primary.withAlpha(30)
                              : Colors.white.withAlpha(6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel
                                ? AppColors.primary
                                : Colors.white.withAlpha(15),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: sel
                                  ? AppColors.primary
                                  : Colors.white.withAlpha(120),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Tab bar
              TabBar(
                controller: _tab,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.white.withAlpha(100),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('الأطباء'),
                        const SizedBox(width: 6),
                        _countBadge(_filtered(_doctors).length),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('التمريض'),
                        const SizedBox(width: 6),
                        _countBadge(_filtered(_nurses).length),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // ── Summary bar ──
        _buildSummaryBar(),
        // ── List ──
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _buildStaffList(_filtered(_doctors)),
              _buildStaffList(_filtered(_nurses)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _countBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSummaryBar() {
    final allStaff = [..._doctors, ..._nurses];
    final onDuty = allStaff.where((s) => s['status'] == 'on-duty').length;
    final offDuty = allStaff.where((s) => s['status'] == 'off-duty').length;
    final onLeave = allStaff.where((s) => s['status'] == 'on-leave').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF0F172A),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _summaryChip('مناوب', onDuty, AppColors.success),
            const SizedBox(width: 12),
            _summaryChip('خارج الدوام', offDuty, AppColors.warning),
            const SizedBox(width: 12),
            _summaryChip('إجازة', onLeave, const Color(0xFF94A3B8)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'المجموع: ${allStaff.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(140)),
        ),
      ],
    );
  }

  Widget _buildStaffList(List<Map<String, dynamic>> staff) {
    if (staff.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد نتائج',
          style: TextStyle(color: Colors.white.withAlpha(80), fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      itemCount: staff.length,
      itemBuilder: (_, i) => _staffCard(staff[i]),
    );
  }

  Widget _staffCard(Map<String, dynamic> s) {
    final status = s['status'] as String;
    final Color statusColor;
    final String statusLabel;
    switch (status) {
      case 'on-duty':
        statusColor = AppColors.success;
        statusLabel = 'مناوب';
        break;
      case 'off-duty':
        statusColor = AppColors.warning;
        statusLabel = 'خارج الدوام';
        break;
      default:
        statusColor = const Color(0xFF94A3B8);
        statusLabel = 'إجازة';
    }

    final rating = (s['rating'] as double?) ?? 0.0;
    final badges = (s['badges'] as List?) ?? [];

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showStaffDetail(s);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: status == 'on-duty'
                ? statusColor.withAlpha(25)
                : Colors.white.withAlpha(6),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor.withAlpha(50),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      s['avatar'] ?? '👤',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${s['specialty']} • ${s['dept']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withAlpha(100),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status + shift
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
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
                    const SizedBox(height: 4),
                    if (status == 'on-duty')
                      Text(
                        '${s['shiftStart']} - ${s['shiftEnd']}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withAlpha(80),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Bottom row: rating + patients + badges
            Wrap(
              spacing: 10,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Rating
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                // Experience
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.work_history_rounded,
                      color: Colors.white.withAlpha(80),
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${s['yearsExp']} سنة',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withAlpha(100),
                      ),
                    ),
                  ],
                ),
                // Patients today
                if ((s['patientsToday'] as int) > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_rounded,
                        color: Colors.white.withAlpha(80),
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${s['patientsToday']} مريض',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withAlpha(100),
                        ),
                      ),
                    ],
                  ),
                // Badges
                if (badges.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA855F7).withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🏅 ${badges.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFA855F7),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Quick actions row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('جاري الاتصال بـ ${s['name']} 📞'),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            color: AppColors.success,
                            size: 15,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'اتصال',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('رسالة إلى ${s['name']} 💬'),
                          backgroundColor: AppColors.info,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withAlpha(12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message_rounded,
                            color: AppColors.info,
                            size: 15,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'رسالة',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStaffDetail(Map<String, dynamic> s) {
    final status = s['status'] as String;
    final Color statusColor;
    final String statusLabel;
    switch (status) {
      case 'on-duty':
        statusColor = AppColors.success;
        statusLabel = 'مناوب الآن';
        break;
      case 'off-duty':
        statusColor = AppColors.warning;
        statusLabel = 'خارج الدوام';
        break;
      default:
        statusColor = const Color(0xFF94A3B8);
        statusLabel = 'في إجازة';
    }

    final badges = (s['badges'] as List?) ?? [];
    final rating = (s['rating'] as double?) ?? 0.0;

    // Weekly schedule demo
    const weekDays = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    final schedule = List.generate(7, (i) {
      if (i == 5)
        return {'day': weekDays[i], 'shift': 'إجازة', 'active': false};
      if (status == 'on-leave')
        return {'day': weekDays[i], 'shift': 'إجازة', 'active': false};
      if (i % 2 == 0) {
        return {
          'day': weekDays[i],
          'shift': '${s['shiftStart']} - ${s['shiftEnd']}',
          'active': true,
        };
      }
      return {'day': weekDays[i], 'shift': 'راحة', 'active': false};
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.all(20),
              children: [
                // Handle
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
                const SizedBox(height: 20),
                // Avatar + name
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(15),
                          shape: BoxShape.circle,
                          border: Border.all(color: statusColor, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            s['avatar'] ?? '👤',
                            style: const TextStyle(fontSize: 34),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        s['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s['specialty'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(120),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withAlpha(50)),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Stats row
                Row(
                  children: [
                    _detailStat(
                      'التقييم',
                      '⭐ ${rating.toStringAsFixed(1)}',
                      const Color(0xFFF59E0B),
                    ),
                    _detailStat(
                      'الخبرة',
                      '${s['yearsExp']} سنة',
                      AppColors.info,
                    ),
                    _detailStat(
                      'مرضى اليوم',
                      '${s['patientsToday']}',
                      AppColors.primary,
                    ),
                    _detailStat(
                      'القسم',
                      s['dept'] ?? '',
                      const Color(0xFFA855F7),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Contact section
                _sectionTitle('معلومات التواصل'),
                const SizedBox(height: 8),
                _infoRow(Icons.phone_rounded, 'الهاتف', s['phone'] ?? ''),
                _infoRow(
                  Icons.access_time_rounded,
                  'الوردية',
                  status == 'on-leave'
                      ? 'في إجازة'
                      : '${s['shiftStart']} - ${s['shiftEnd']}',
                ),
                _infoRow(Icons.apartment_rounded, 'القسم', s['dept'] ?? ''),

                const SizedBox(height: 20),
                // Weekly schedule
                _sectionTitle('جدول الأسبوع'),
                const SizedBox(height: 8),
                ...schedule.map(
                  (day) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: (day['active'] as bool)
                          ? AppColors.success.withAlpha(8)
                          : Colors.white.withAlpha(4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (day['active'] as bool)
                            ? AppColors.success.withAlpha(25)
                            : Colors.white.withAlpha(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            day['day'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withAlpha(160),
                            ),
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: (day['active'] as bool)
                                ? AppColors.success
                                : Colors.white.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          day['shift'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: (day['active'] as bool)
                                ? AppColors.success
                                : Colors.white.withAlpha(80),
                            fontWeight: (day['active'] as bool)
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Badges
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _sectionTitle('الشهادات والإنجازات'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: badges
                        .map(
                          (b) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA855F7).withAlpha(12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFA855F7).withAlpha(30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🏅',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  b.toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFA855F7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                // Actions
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _actionBtn(
                        'اتصال',
                        Icons.phone_rounded,
                        AppColors.success,
                        () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('جاري الاتصال بـ ${s['name']}...'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionBtn(
                        'رسالة',
                        Icons.message_rounded,
                        AppColors.info,
                        () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('رسالة إلى ${s['name']}'),
                              backgroundColor: AppColors.info,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionBtn(
                        'تقرير',
                        Icons.description_rounded,
                        const Color(0xFFA855F7),
                        () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('جاري تحضير التقرير...'),
                              backgroundColor: Color(0xFFA855F7),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withAlpha(100),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.white.withAlpha(200),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white.withAlpha(80)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(100)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
