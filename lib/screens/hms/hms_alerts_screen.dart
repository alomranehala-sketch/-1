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

  Future<void> _load() async {
    final results = await Future.wait([
      HmsService.getAlerts(),
      HmsService.getFeedback(),
    ]);
    if (mounted) {
      setState(() {
        _alerts = results[0];
        _feedback = results[1];
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
              Text('⚠️', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text(
                'التنبيهات والتقييمات',
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
                        ..._alerts.map(_alertCard),
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
              onTap: () async {
                HapticFeedback.mediumImpact();
                await HmsService.acknowledgeAlert(alert['id']);
                _load();
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
