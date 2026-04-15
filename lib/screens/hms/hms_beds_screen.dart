import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await HmsService.getBeds();
    if (mounted) {
      setState(() {
        _data = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final beds =
        (_data['beds'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
    final summary = _data['summary'] != null
        ? Map<String, dynamic>.from(_data['summary'] as Map)
        : <String, dynamic>{};

    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 16),
          color: const Color(0xFF1E293B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🛏️', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 8),
                  Text(
                    'لوحة الأسرّة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Summary row
              Row(
                children: [
                  _summaryChip(
                    'إجمالي',
                    '${summary['total'] ?? 0}',
                    Colors.white54,
                  ),
                  _summaryChip(
                    'متاح',
                    '${summary['available'] ?? 0}',
                    AppColors.success,
                  ),
                  _summaryChip(
                    'مشغول',
                    '${summary['occupied'] ?? 0}',
                    AppColors.error,
                  ),
                  _summaryChip(
                    'محجوز',
                    '${summary['reserved'] ?? 0}',
                    AppColors.warning,
                  ),
                  _summaryChip(
                    'تنظيف',
                    '${summary['cleaning'] ?? 0}',
                    AppColors.info,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : RefreshIndicator(onRefresh: _load, child: _buildBedGrid(beds)),
        ),
      ],
    );
  }

  Widget _summaryChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8),
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
      ),
    );
  }

  Widget _buildBedGrid(List<Map<String, dynamic>> beds) {
    // Group by ward
    final wards = <String, List<Map<String, dynamic>>>{};
    for (final bed in beds) {
      final ward = bed['ward'] as String? ?? 'أخرى';
      wards.putIfAbsent(ward, () => []).add(bed);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: wards.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '🏥 ${entry.key}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.value.map((bed) => _bedTile(bed)).toList(),
              ),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
      ),
    );
  }

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
      default:
        color = Colors.white54;
        icon = Icons.bed_rounded;
    }

    return Container(
      width: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            bed['id'] ?? '',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            bed['room'] ?? '',
            style: TextStyle(fontSize: 9, color: Colors.white.withAlpha(100)),
          ),
        ],
      ),
    );
  }
}
