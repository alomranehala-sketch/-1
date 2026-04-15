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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await HmsService.getPatients(status: 'waiting');
    if (mounted) {
      setState(() {
        _patients = data;
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
            'الفرز الطبي الذكي 🤖',
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
            : _patients.isEmpty
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
                  itemCount: _patients.length,
                  itemBuilder: (_, i) => _triageCard(_patients[i]),
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
    await HmsService.updateTriage(id.toString(), {'triage': level});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث مستوى الفرز إلى $level ✓'),
        backgroundColor: _triageColor(level),
      ),
    );
    _load();
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
