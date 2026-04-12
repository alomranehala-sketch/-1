import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../theme.dart';
import 'hospital_detail_screen.dart';
import 'map_tab.dart';

/// Government Hospitals — مستشفيات حكومية
/// Shows all government hospitals in Jordan with live map + list
class GovHospitalsScreen extends StatefulWidget {
  const GovHospitalsScreen({super.key});
  @override
  State<GovHospitalsScreen> createState() => _GovHospitalsScreenState();
}

class _GovHospitalsScreenState extends State<GovHospitalsScreen> {
  String _selectedGov = 'الكل';
  String _selectedFilter = 'الكل';
  final _searchCtrl = TextEditingController();
  String _query = '';

  final _governorates = const [
    'الكل',
    'عمّان',
    'إربد',
    'الزرقاء',
    'العقبة',
    'السلط',
    'المفرق',
    'الكرك',
    'الطفيلة',
    'مادبا',
    'جرش',
    'عجلون',
    'معان',
  ];

  final _filters = const ['الكل', 'طوارئ', 'عيادات', 'عمليات', 'ولادة'];

  final _hospitals = <_GovHospital>[
    _GovHospital(
      'مستشفى البشير',
      'عمّان — الأشرفية',
      'عمّان',
      Icons.local_hospital_rounded,
      4.2,
      15,
      true,
      ['طوارئ', 'باطنية', 'جراحة', 'عظام', 'نسائية', 'أطفال'],
      'أكبر مستشفى حكومي في الأردن',
    ),
    _GovHospital(
      'مستشفى الجامعة الأردنية',
      'عمّان — الجبيهة',
      'عمّان',
      Icons.school_rounded,
      4.6,
      20,
      true,
      ['طوارئ', 'قلب', 'أعصاب', 'أورام', 'كلى', 'باطنية'],
      'مستشفى تعليمي — جامعة الأردن',
    ),
    _GovHospital(
      'مستشفى الأمير حمزة',
      'عمّان — ماركا',
      'عمّان',
      Icons.local_hospital_rounded,
      4.3,
      12,
      true,
      ['طوارئ', 'باطنية', 'جراحة', 'عظام', 'أطفال'],
      'مستشفى حكومي شمال عمّان',
    ),
    _GovHospital(
      'مستشفى الأميرة بسمة',
      'إربد — وسط المدينة',
      'إربد',
      Icons.local_hospital_rounded,
      4.1,
      18,
      true,
      ['طوارئ', 'باطنية', 'جراحة', 'نسائية', 'أطفال'],
      'المستشفى الحكومي الرئيسي في إربد',
    ),
    _GovHospital(
      'مستشفى الزرقاء الحكومي',
      'الزرقاء — وسط المدينة',
      'الزرقاء',
      Icons.local_hospital_rounded,
      3.9,
      22,
      true,
      ['طوارئ', 'باطنية', 'جراحة', 'عظام'],
      'المستشفى الحكومي الرئيسي في الزرقاء',
    ),
    _GovHospital(
      'مستشفى الأمير زيد بن الحسين',
      'الطفيلة',
      'الطفيلة',
      Icons.local_hospital_rounded,
      4.0,
      10,
      false,
      ['طوارئ', 'باطنية', 'جراحة'],
      'مستشفى الطفيلة الحكومي',
    ),
    _GovHospital(
      'مستشفى الكرك الحكومي',
      'الكرك — وسط المدينة',
      'الكرك',
      Icons.local_hospital_rounded,
      4.0,
      14,
      true,
      ['طوارئ', 'باطنية', 'جراحة', 'نسائية'],
      'المستشفى الحكومي في الكرك',
    ),
    _GovHospital(
      'مستشفى العقبة الحكومي',
      'العقبة',
      'العقبة',
      Icons.local_hospital_rounded,
      4.1,
      8,
      true,
      ['طوارئ', 'باطنية', 'جراحة', 'أطفال'],
      'مستشفى العقبة الحكومي',
    ),
    _GovHospital(
      'مدينة الحسين الطبية',
      'عمّان — تلاع العلي',
      'عمّان',
      Icons.military_tech_rounded,
      4.7,
      25,
      true,
      ['طوارئ', 'قلب', 'أعصاب', 'أورام', 'زراعة أعضاء', 'جراحة'],
      'المستشفى العسكري الرئيسي',
    ),
    _GovHospital(
      'مستشفى الأمير حسين بن عبدالله',
      'السلط',
      'السلط',
      Icons.local_hospital_rounded,
      4.0,
      12,
      true,
      ['طوارئ', 'باطنية', 'جراحة', 'أطفال'],
      'مستشفى السلط الحكومي الجديد',
    ),
  ];

  List<_GovHospital> get _filtered {
    var list = _hospitals.toList();
    if (_selectedGov != 'الكل') {
      list = list.where((h) => h.gov == _selectedGov).toList();
    }
    if (_selectedFilter != 'الكل') {
      list = list
          .where((h) => h.specs.any((s) => s.contains(_selectedFilter)))
          .toList();
    }
    if (_query.isNotEmpty) {
      list = list
          .where((h) => h.name.contains(_query) || h.address.contains(_query))
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final hospitals = _filtered;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // ── Header ──
            Container(
              padding: EdgeInsets.fromLTRB(8, topPad + 8, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.border.withAlpha(40)),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'المستشفيات الحكومية 🏥',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      _badge('حكيم', const Color(0xFF3B82F6)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Search
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'ابحث عن مستشفى...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: AppColors.textLight,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Governorate filter ──
            SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _governorates.length,
                itemBuilder: (_, i) {
                  final sel = _selectedGov == _governorates[i];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedGov = _governorates[i]),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: sel
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _governorates[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.textMedium,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Spec filter ──
            SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (_, i) {
                  final sel = _selectedFilter == _filters[i];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = _filters[i]),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFF3B82F6)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: sel
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _filters[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.textMedium,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Count ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  Text(
                    '${hospitals.length} مستشفى',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF3B82F6),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'مرتبطة بنظام حكيم',
                    style: TextStyle(fontSize: 11, color: Color(0xFF3B82F6)),
                  ),
                ],
              ),
            ),

            // ── List ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                itemCount: hospitals.length,
                itemBuilder: (_, i) => _buildHospitalCard(hospitals[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildHospitalCard(_GovHospital h) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HospitalDetailScreen(
              hospital: HospitalData(
                name: h.name,
                location: const LatLng(31.95, 35.91),
                address: h.address,
                phone: '06-000-0000',
                rating: h.rating,
                availability: h.hasER
                    ? HospitalAvailability.open
                    : HospitalAvailability.busy,
                specialties: h.specs,
                waitTime: h.waitMin,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withAlpha(40)),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withAlpha(15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(h.icon, color: const Color(0xFF3B82F6), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        h.address,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${h.rating}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '~${h.waitMin} د',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              h.desc,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMedium,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: h.specs
                  .take(5)
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withAlpha(10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (h.hasER) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emergency_rounded,
                      color: Color(0xFFEF4444),
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'طوارئ 24 ساعة',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GovHospital {
  final String name, address, gov;
  final IconData icon;
  final double rating;
  final int waitMin;
  final bool hasER;
  final List<String> specs;
  final String desc;
  const _GovHospital(
    this.name,
    this.address,
    this.gov,
    this.icon,
    this.rating,
    this.waitMin,
    this.hasER,
    this.specs,
    this.desc,
  );
}
