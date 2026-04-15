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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final patients = await HmsService.getPatients();
    if (mounted) {
      setState(() {
        _patients = patients;
        _loading = false;
      });
    }
  }

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
              Text(
                p['name'] ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
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
              Text(
                p['department'] ?? '—',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withAlpha(120),
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
          Row(
            children: [
              _vital('❤️', '${vitals['hr'] ?? 0}', 'نبض'),
              _vital('🩸', '${vitals['bp'] ?? '—'}', 'ضغط'),
              _vital('🌡️', '${vitals['temp'] ?? 0}°', 'حرارة'),
              _vital('🫁', '${vitals['o2'] ?? 0}%', 'أكسجين'),
              const Spacer(),
              if (p['room'] != null)
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
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ),
            ],
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
