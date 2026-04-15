import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/hms_service.dart';
import '../../theme.dart';

class HmsBedsScreen extends StatefulWidget {
  const HmsBedsScreen({super.key});
  @override
  State<HmsBedsScreen> createState() => _HmsBedsScreenState();
}

class _HmsBedsScreenState extends State<HmsBedsScreen> {
  Map<String, dynamic> _data = {};
  bool _loading = true;
  String _selectedFloor = 'all';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await HmsService.getBeds();
    if (mounted) {
      setState(() {
        // Use API data if available, otherwise demo
        if (data['beds'] != null && (data['beds'] as List).isNotEmpty) {
          _data = data;
        } else {
          _data = _demoBedData;
        }
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _allBeds =>
      (_data['beds'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList() ??
      [];

  List<Map<String, dynamic>> get _filteredBeds {
    var beds = _allBeds;
    if (_selectedFloor != 'all') {
      beds = beds.where((b) => b['floor'] == _selectedFloor).toList();
    }
    if (_statusFilter != 'all') {
      beds = beds.where((b) => b['status'] == _statusFilter).toList();
    }
    return beds;
  }

  Map<String, dynamic> get _summary {
    final beds = _allBeds;
    final total = beds.length;
    final available = beds.where((b) => b['status'] == 'available').length;
    final occupied = beds.where((b) => b['status'] == 'occupied').length;
    final reserved = beds.where((b) => b['status'] == 'reserved').length;
    final cleaning = beds.where((b) => b['status'] == 'cleaning').length;
    final maintenance = beds.where((b) => b['status'] == 'maintenance').length;
    return {
      'total': total,
      'available': available,
      'occupied': occupied,
      'reserved': reserved,
      'cleaning': cleaning,
      'maintenance': maintenance,
      'occupancyRate': total > 0 ? (occupied / total * 100) : 0.0,
    };
  }

  Set<String> get _floors {
    return _allBeds.map((b) => b['floor'] as String? ?? '1').toSet();
  }

  // ──────────────────── DEMO DATA ────────────────────
  static final Map<String, dynamic> _demoBedData = {
    'beds': [
      // ── الطابق 1: الطوارئ ──
      _bed(
        'ER-101',
        'طوارئ',
        '1',
        '101',
        'occupied',
        'أحمد الخالدي',
        'حرج',
        'red',
      ),
      _bed(
        'ER-102',
        'طوارئ',
        '1',
        '101',
        'occupied',
        'سارة المصري',
        'متوسط',
        'yellow',
      ),
      _bed('ER-103', 'طوارئ', '1', '102', 'available', null, null, null),
      _bed(
        'ER-104',
        'طوارئ',
        '1',
        '102',
        'occupied',
        'عمر النعيمي',
        'حرج',
        'red',
      ),
      _bed('ER-105', 'طوارئ', '1', '103', 'cleaning', null, null, null),
      _bed('ER-106', 'طوارئ', '1', '103', 'available', null, null, null),
      _bed(
        'ER-107',
        'طوارئ',
        '1',
        '104',
        'reserved',
        'محمد سعيد',
        'قادم',
        'yellow',
      ),
      _bed(
        'ER-108',
        'طوارئ',
        '1',
        '104',
        'occupied',
        'فاطمة علي',
        'متوسط',
        'yellow',
      ),
      // ── الطابق 2: الباطنية + القلب ──
      _bed(
        'M-201',
        'باطنية',
        '2',
        '201',
        'occupied',
        'هند القضاة',
        'مستقر',
        'green',
      ),
      _bed('M-202', 'باطنية', '2', '201', 'available', null, null, null),
      _bed(
        'M-203',
        'باطنية',
        '2',
        '202',
        'occupied',
        'ليلى الزعبي',
        'متوسط',
        'yellow',
      ),
      _bed('M-204', 'باطنية', '2', '202', 'cleaning', null, null, null),
      _bed('M-205', 'باطنية', '2', '203', 'available', null, null, null),
      _bed('M-206', 'باطنية', '2', '203', 'available', null, null, null),
      _bed(
        'C-207',
        'قلب',
        '2',
        '207',
        'occupied',
        'عبدالرحمن فيصل',
        'حرج',
        'red',
      ),
      _bed(
        'C-208',
        'قلب',
        '2',
        '207',
        'occupied',
        'عادل محمود',
        'متوسط',
        'yellow',
      ),
      _bed('C-209', 'قلب', '2', '208', 'available', null, null, null),
      _bed(
        'C-210',
        'قلب',
        '2',
        '208',
        'reserved',
        'نادية حسن',
        'منقولة',
        'yellow',
      ),
      // ── الطابق 3: الجراحة + العظام ──
      _bed(
        'S-301',
        'جراحة',
        '3',
        '301',
        'occupied',
        'نور الدين محمد',
        'بعد العملية',
        'green',
      ),
      _bed('S-302', 'جراحة', '3', '301', 'available', null, null, null),
      _bed('S-303', 'جراحة', '3', '302', 'maintenance', null, null, null),
      _bed(
        'S-304',
        'جراحة',
        '3',
        '302',
        'occupied',
        'رائد العمري',
        'مستقر',
        'green',
      ),
      _bed(
        'O-305',
        'عظام',
        '3',
        '305',
        'occupied',
        'خالد عبدالله',
        'كسر',
        'yellow',
      ),
      _bed('O-306', 'عظام', '3', '305', 'available', null, null, null),
      _bed('O-307', 'عظام', '3', '306', 'available', null, null, null),
      _bed(
        'O-308',
        'عظام',
        '3',
        '306',
        'reserved',
        'سامي الشوبكي',
        'جدولة',
        'green',
      ),
      // ── الطابق 4: العناية المركزة + الأطفال ──
      _bed(
        'ICU-401',
        'عناية مركزة',
        '4',
        '401',
        'occupied',
        'رنا الطراونة',
        'حرج جداً',
        'red',
      ),
      _bed(
        'ICU-402',
        'عناية مركزة',
        '4',
        '401',
        'occupied',
        'محمود الشمالي',
        'حرج',
        'red',
      ),
      _bed('ICU-403', 'عناية مركزة', '4', '402', 'available', null, null, null),
      _bed(
        'ICU-404',
        'عناية مركزة',
        '4',
        '402',
        'occupied',
        'عيسى كمال',
        'حرج',
        'red',
      ),
      _bed(
        'P-405',
        'أطفال',
        '4',
        '405',
        'occupied',
        'سارة وليد',
        'حساسية',
        'yellow',
      ),
      _bed('P-406', 'أطفال', '4', '405', 'available', null, null, null),
      _bed('P-407', 'أطفال', '4', '406', 'available', null, null, null),
      _bed('P-408', 'أطفال', '4', '406', 'cleaning', null, null, null),
      // ── الطابق 5: النسائية + خاصة ──
      _bed(
        'OB-501',
        'نسائية',
        '5',
        '501',
        'occupied',
        'فاطمة علي الحسن',
        'ولادة',
        'yellow',
      ),
      _bed('OB-502', 'نسائية', '5', '501', 'available', null, null, null),
      _bed(
        'OB-503',
        'نسائية',
        '5',
        '502',
        'occupied',
        'منى الجبور',
        'بعد ولادة',
        'green',
      ),
      _bed('OB-504', 'نسائية', '5', '502', 'available', null, null, null),
      _bed(
        'VIP-505',
        'جناح خاص',
        '5',
        '505',
        'occupied',
        'أ. ناصر الهادي',
        'VIP',
        'green',
      ),
      _bed('VIP-506', 'جناح خاص', '5', '506', 'available', null, null, null),
      _bed(
        'VIP-507',
        'جناح خاص',
        '5',
        '507',
        'reserved',
        'د. ليلى عمران',
        'VIP',
        'green',
      ),
      _bed('VIP-508', 'جناح خاص', '5', '508', 'available', null, null, null),
    ],
  };

  static Map<String, dynamic> _bed(
    String id,
    String ward,
    String floor,
    String room,
    String status,
    String? patient,
    String? condition,
    String? triage,
  ) => {
    'id': id,
    'ward': ward,
    'floor': floor,
    'room': room,
    'status': status,
    'patient': patient,
    'condition': condition,
    'triage': triage,
  };

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final summary = _summary;

    return Column(
      children: [
        // ── Header ──
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 12),
          color: const Color(0xFF1E293B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🛏️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'لوحة الأسرّة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
                      '${summary['total']} سرير',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Summary chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _summaryChip(
                      'إجمالي',
                      '${summary['total']}',
                      Colors.white54,
                    ),
                    _summaryChip(
                      'متاح',
                      '${summary['available']}',
                      AppColors.success,
                    ),
                    _summaryChip(
                      'مشغول',
                      '${summary['occupied']}',
                      AppColors.error,
                    ),
                    _summaryChip(
                      'محجوز',
                      '${summary['reserved']}',
                      AppColors.warning,
                    ),
                    _summaryChip(
                      'تنظيف',
                      '${summary['cleaning']}',
                      AppColors.info,
                    ),
                    if ((summary['maintenance'] as int) > 0)
                      _summaryChip(
                        'صيانة',
                        '${summary['maintenance']}',
                        Colors.grey,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Occupancy bar
              _buildOccupancyBar(summary),
              const SizedBox(height: 10),
              // Floor filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      [
                        _floorChip('الكل', 'all'),
                        ..._floors.toList()..sort(),
                      ].map((f) {
                        if (f is Widget) return f;
                        final floor = f as String;
                        if (floor == 'all')
                          return _floorChip('كل الطوابق', 'all');
                        return _floorChip('الطابق $floor', floor);
                      }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              // Status filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _statusChip('الكل', 'all', Colors.white54),
                    _statusChip('متاح', 'available', AppColors.success),
                    _statusChip('مشغول', 'occupied', AppColors.error),
                    _statusChip('محجوز', 'reserved', AppColors.warning),
                    _statusChip('تنظيف', 'cleaning', AppColors.info),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ── Bed Grid ──
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _buildBedGrid(_filteredBeds),
                ),
        ),
      ],
    );
  }

  // ──────────────────── OCCUPANCY BAR ────────────────────
  Widget _buildOccupancyBar(Map<String, dynamic> summary) {
    final rate = (summary['occupancyRate'] as double);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'نسبة الإشغال: ${rate.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: rate > 80
                    ? AppColors.error
                    : rate > 60
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ),
            Text(
              'متاح ${summary['available']} من ${summary['total']}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withAlpha(100),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                _barSegment(
                  summary['occupied'] as int,
                  AppColors.error,
                  summary['total'] as int,
                ),
                _barSegment(
                  summary['reserved'] as int,
                  AppColors.warning,
                  summary['total'] as int,
                ),
                _barSegment(
                  summary['cleaning'] as int,
                  AppColors.info,
                  summary['total'] as int,
                ),
                _barSegment(
                  summary['maintenance'] as int,
                  Colors.grey,
                  summary['total'] as int,
                ),
                Expanded(child: Container(color: Colors.white.withAlpha(15))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _legendDot(AppColors.error, 'مشغول'),
            _legendDot(AppColors.warning, 'محجوز'),
            _legendDot(AppColors.info, 'تنظيف'),
            _legendDot(AppColors.success, 'متاح'),
          ],
        ),
      ],
    );
  }

  Widget _barSegment(int count, Color color, int total) {
    if (count == 0 || total == 0) return const SizedBox.shrink();
    return Flexible(
      flex: count,
      child: Container(color: color),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.white.withAlpha(120)),
          ),
        ],
      ),
    );
  }

  // ──────────────────── CHIPS ────────────────────
  Widget _summaryChip(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: color.withAlpha(180)),
          ),
        ],
      ),
    );
  }

  Widget _floorChip(String label, String value) {
    final active = _selectedFloor == value;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedFloor = value);
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primary : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String label, String value, Color color) {
    final active = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _statusFilter = value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: active ? color.withAlpha(30) : Colors.white.withAlpha(8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? color.withAlpha(60) : Colors.white.withAlpha(15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: active ? color : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────── BED GRID ────────────────────
  Widget _buildBedGrid(List<Map<String, dynamic>> beds) {
    if (beds.isEmpty) {
      return const Center(
        child: Text('لا توجد أسرّة', style: TextStyle(color: Colors.white54)),
      );
    }

    // Group by floor then ward
    final floors = <String, Map<String, List<Map<String, dynamic>>>>{};
    for (final bed in beds) {
      final floor = bed['floor'] as String? ?? '1';
      final ward = bed['ward'] as String? ?? 'أخرى';
      floors.putIfAbsent(floor, () => {});
      floors[floor]!.putIfAbsent(ward, () => []).add(bed);
    }

    final sortedFloors = floors.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Floor-by-floor
        for (final floor in sortedFloors) ...[
          _floorHeader(floor, floors[floor]!),
          for (final ward in floors[floor]!.entries) ...[
            _wardHeader(ward.key, ward.value),
            // Room grouping
            _buildRoomGrid(ward.value),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 4),
        ],
      ],
    );
  }

  Widget _floorHeader(
    String floor,
    Map<String, List<Map<String, dynamic>>> wards,
  ) {
    final allBeds = wards.values.expand((e) => e).toList();
    final occupied = allBeds.where((b) => b['status'] == 'occupied').length;
    final total = allBeds.length;
    final rate = total > 0 ? (occupied / total * 100) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E293B), AppColors.primary.withAlpha(15)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                floor,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الطابق $floor',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${wards.length} أقسام • $total سرير • $occupied مشغول',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withAlpha(120),
                  ),
                ),
              ],
            ),
          ),
          // Mini occupancy
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: rate / 100,
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withAlpha(15),
                  color: rate > 80
                      ? AppColors.error
                      : rate > 60
                      ? AppColors.warning
                      : AppColors.success,
                ),
                Text(
                  '${rate.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _wardHeader(String ward, List<Map<String, dynamic>> beds) {
    final avail = beds.where((b) => b['status'] == 'available').length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, right: 4),
      child: Row(
        children: [
          const Text('🏥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            ward,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($avail متاح من ${beds.length})',
            style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(100)),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomGrid(List<Map<String, dynamic>> beds) {
    // Group by room
    final rooms = <String, List<Map<String, dynamic>>>{};
    for (final bed in beds) {
      final room = bed['room'] as String? ?? '';
      rooms.putIfAbsent(room, () => []).add(bed);
    }

    return Column(
      children: rooms.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.meeting_room_rounded,
                    size: 14,
                    color: Colors.white.withAlpha(120),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'غرفة ${entry.key}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(180),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${entry.value.length} أسرّة',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withAlpha(80),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.value.map((bed) => _bedTile(bed)).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ──────────────────── BED TILE ────────────────────
  Widget _bedTile(Map<String, dynamic> bed) {
    final status = bed['status'] as String? ?? 'available';
    Color color;
    IconData icon;
    switch (status) {
      case 'available':
        color = AppColors.success;
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'occupied':
        color = AppColors.error;
        icon = Icons.person_rounded;
        break;
      case 'reserved':
        color = AppColors.warning;
        icon = Icons.lock_clock_rounded;
        break;
      case 'cleaning':
        color = AppColors.info;
        icon = Icons.cleaning_services_rounded;
        break;
      case 'maintenance':
        color = Colors.grey;
        icon = Icons.build_rounded;
        break;
      default:
        color = Colors.white54;
        icon = Icons.bed_rounded;
    }

    final hasTriage = bed['triage'] != null;
    Color? triageColor;
    if (hasTriage) {
      switch (bed['triage']) {
        case 'red':
          triageColor = AppColors.error;
          break;
        case 'yellow':
          triageColor = AppColors.warning;
          break;
        default:
          triageColor = AppColors.success;
      }
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showBedDetail(bed);
      },
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 16),
                if (hasTriage) ...[
                  const SizedBox(width: 3),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: triageColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: triageColor!.withAlpha(80),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 3),
            Text(
              bed['id'] ?? '',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (bed['patient'] != null)
              Text(
                bed['patient'],
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white.withAlpha(120),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
          ],
        ),
      ),
    );
  }

  // ──────────────────── BED DETAIL SHEET ────────────────────
  void _showBedDetail(Map<String, dynamic> bed) {
    final status = bed['status'] as String? ?? 'available';
    Color color;
    String statusLabel;
    switch (status) {
      case 'available':
        color = AppColors.success;
        statusLabel = 'متاح';
        break;
      case 'occupied':
        color = AppColors.error;
        statusLabel = 'مشغول';
        break;
      case 'reserved':
        color = AppColors.warning;
        statusLabel = 'محجوز';
        break;
      case 'cleaning':
        color = AppColors.info;
        statusLabel = 'قيد التنظيف';
        break;
      case 'maintenance':
        color = Colors.grey;
        statusLabel = 'صيانة';
        break;
      default:
        color = Colors.white54;
        statusLabel = status;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Bed icon + ID
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.bed_rounded, color: color, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                'سرير ${bed['id']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Details
              _detailRow(
                'القسم',
                bed['ward'] ?? '—',
                Icons.local_hospital_rounded,
              ),
              _detailRow('الطابق', bed['floor'] ?? '—', Icons.layers_rounded),
              _detailRow(
                'الغرفة',
                bed['room'] ?? '—',
                Icons.meeting_room_rounded,
              ),
              if (bed['patient'] != null) ...[
                _detailRow('المريض', bed['patient'], Icons.person_rounded),
                _detailRow(
                  'الحالة',
                  bed['condition'] ?? '—',
                  Icons.medical_information_rounded,
                ),
              ],
              const SizedBox(height: 20),
              // Actions
              if (status == 'available')
                _sheetAction(
                  'حجز السرير',
                  Icons.lock_clock_rounded,
                  AppColors.warning,
                  () {
                    Navigator.pop(context);
                    setState(() => bed['status'] = 'reserved');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم حجز سرير ${bed['id']}')),
                    );
                  },
                )
              else if (status == 'occupied')
                _sheetAction(
                  'إخلاء السرير',
                  Icons.logout_rounded,
                  AppColors.success,
                  () {
                    Navigator.pop(context);
                    setState(() {
                      bed['status'] = 'cleaning';
                      bed['patient'] = null;
                      bed['condition'] = null;
                      bed['triage'] = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم إخلاء سرير ${bed['id']} — قيد التنظيف',
                        ),
                      ),
                    );
                  },
                )
              else if (status == 'cleaning')
                _sheetAction(
                  'إتمام التنظيف',
                  Icons.check_circle_rounded,
                  AppColors.success,
                  () {
                    Navigator.pop(context);
                    setState(() => bed['status'] = 'available');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('سرير ${bed['id']} أصبح متاحاً')),
                    );
                  },
                )
              else if (status == 'reserved')
                _sheetAction(
                  'إلغاء الحجز',
                  Icons.cancel_rounded,
                  AppColors.error,
                  () {
                    Navigator.pop(context);
                    setState(() {
                      bed['status'] = 'available';
                      bed['patient'] = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم إلغاء حجز سرير ${bed['id']}')),
                    );
                  },
                ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white.withAlpha(100)),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(120)),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetAction(
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
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
