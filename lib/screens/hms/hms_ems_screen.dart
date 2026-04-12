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

  Future<void> _load() async {
    final data = await HmsService.getEmsIncoming();
    if (mounted) {
      setState(() {
        _ems = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 12),
          color: const Color(0xFF1E293B),
          child: const Row(
            children: [
              Text('🚑', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text(
                'سيارات الإسعاف القادمة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
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
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _ems.length,
                    itemBuilder: (_, i) => _emsCard(_ems[i]),
                  ),
                ),
        ),
      ],
    );
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
                        Text(
                          'من: ${ems['from'] ?? ''}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withAlpha(100),
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
