import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../theme.dart';
import 'hospital_detail_screen.dart';
import 'map_tab.dart';

/// Private Hospitals — مستشفيات خاصة
class PrivateHospitalsScreen extends StatefulWidget {
  const PrivateHospitalsScreen({super.key});
  @override
  State<PrivateHospitalsScreen> createState() => _PrivateHospitalsScreenState();
}

class _PrivateHospitalsScreenState extends State<PrivateHospitalsScreen> {
  String _selectedGov = 'الكل';
  final _searchCtrl = TextEditingController();
  String _query = '';

  final _governorates = const ['الكل', 'عمّان', 'إربد', 'الزرقاء', 'العقبة'];

  final _hospitals = <_PrivateH>[
    _PrivateH(
      'مستشفى الأردن',
      'عمّان — الشميساني',
      'عمّان',
      4.8,
      12,
      ['قلب', 'عظام', 'أطفال', 'طوارئ', 'باطنية', 'جراحة'],
      'من أعرق المستشفيات الخاصة في الأردن',
      true,
      '💳 تأمين معتمد',
    ),
    _PrivateH(
      'مستشفى الاستقلال',
      'عمّان — شارع المدينة',
      'عمّان',
      4.6,
      10,
      ['جراحة', 'عظام', 'باطنية', 'قلب', 'مسالك'],
      'مستشفى خاص عريق وسط عمّان',
      true,
      '💳 تأمين معتمد',
    ),
    _PrivateH(
      'مستشفى الخالدي',
      'عمّان — جبل عمّان',
      'عمّان',
      4.7,
      8,
      ['قلب', 'أعصاب', 'جراحة', 'أورام', 'باطنية'],
      'مستشفى تخصصي متقدم',
      true,
      '💳 تأمين معتمد',
    ),
    _PrivateH(
      'مستشفى الإسراء',
      'عمّان — ضاحية الياسمين',
      'عمّان',
      4.5,
      15,
      ['طوارئ', 'باطنية', 'جراحة', 'أطفال', 'نسائية'],
      'مستشفى شامل في شمال عمّان',
      true,
      '💳 تأمين معتمد',
    ),
    _PrivateH(
      'مستشفى ابن الهيثم',
      'عمّان — البيادر',
      'عمّان',
      4.4,
      12,
      ['عيون', 'ليزك', 'جراحة عيون', 'قرنية'],
      'مستشفى تخصصي للعيون',
      false,
      '👁️ تخصص عيون',
    ),
    _PrivateH(
      'مستشفى الحياة',
      'إربد',
      'إربد',
      4.3,
      14,
      ['طوارئ', 'باطنية', 'جراحة', 'عظام'],
      'أكبر مستشفى خاص في إربد',
      true,
      '💳 تأمين معتمد',
    ),
    _PrivateH(
      'مستشفى فرح',
      'عمّان — عبدون',
      'عمّان',
      4.5,
      10,
      ['نسائية', 'ولادة', 'أطفال', 'IVF'],
      'مستشفى تخصصي للنساء والولادة',
      true,
      '👶 تخصص نساء وتوليد',
    ),
    _PrivateH(
      'مجموعة عبد الهادي الطبية',
      'عمّان — الشميساني',
      'عمّان',
      4.6,
      8,
      ['أسنان', 'تجميل', 'زراعة', 'تقويم'],
      'مجموعة طبية رائدة في طب الأسنان',
      false,
      '🦷 تخصص أسنان',
    ),
    _PrivateH(
      'مستشفى الملكة علياء العسكري',
      'عمّان — ماركا',
      'عمّان',
      4.4,
      20,
      ['طوارئ', 'قلب', 'جراحة', 'باطنية', 'عظام'],
      'مستشفى عسكري للجميع',
      true,
      '⭐ مستشفى عسكري',
    ),
  ];

  List<_PrivateH> get _filtered {
    var list = _hospitals.toList();
    if (_selectedGov != 'الكل') {
      list = list.where((h) => h.gov == _selectedGov).toList();
    }
    if (_query.isNotEmpty) {
      list = list
          .where(
            (h) =>
                h.name.contains(_query) ||
                h.address.contains(_query) ||
                h.specs.any((s) => s.contains(_query)),
          )
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
                          'المستشفيات الخاصة 🏨',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withAlpha(15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'خاص',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                        hintText: 'ابحث عن مستشفى أو تخصص...',
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
                        color: sel
                            ? const Color(0xFF8B5CF6)
                            : AppColors.surface,
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
                  const Text(
                    'تأمين • حجز فوري',
                    style: TextStyle(fontSize: 11, color: Color(0xFF8B5CF6)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                itemCount: hospitals.length,
                itemBuilder: (_, i) => _buildCard(hospitals[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(_PrivateH h) {
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
                availability: HospitalAvailability.open,
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
                    color: const Color(0xFF8B5CF6).withAlpha(15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 24,
                  ),
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
            const SizedBox(height: 8),
            Text(
              h.desc,
              style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
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
                        color: const Color(0xFF8B5CF6).withAlpha(10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: h.hasInsurance
                        ? const Color(0xFF10B981).withAlpha(10)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    h.badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: h.hasInsurance
                          ? const Color(0xFF10B981)
                          : AppColors.textMedium,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'احجز الآن',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B5CF6),
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
}

class _PrivateH {
  final String name, address, gov;
  final double rating;
  final int waitMin;
  final List<String> specs;
  final String desc;
  final bool hasInsurance;
  final String badge;
  const _PrivateH(
    this.name,
    this.address,
    this.gov,
    this.rating,
    this.waitMin,
    this.specs,
    this.desc,
    this.hasInsurance,
    this.badge,
  );
}
