import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme.dart';

/// Clinics Directory — دليل العيادات
/// All medical specialties → clinics in Jordan → live map
class ClinicsDirectoryScreen extends StatefulWidget {
  const ClinicsDirectoryScreen({super.key});
  @override
  State<ClinicsDirectoryScreen> createState() => _ClinicsDirectoryScreenState();
}

class _ClinicsDirectoryScreenState extends State<ClinicsDirectoryScreen> {
  int _selectedSpec = -1;
  int _selectedClinic = -1;
  bool _showMap = false;
  String _sortBy = 'rating';
  final _searchCtrl = TextEditingController();
  String _query = '';

  final _specialties = const <_Specialty>[
    _Specialty(
      'طب عام',
      Icons.medical_services_rounded,
      Color(0xFF3B82F6),
      'كشف عام، فحص شامل',
    ),
    _Specialty(
      'جراحة',
      Icons.content_cut_rounded,
      Color(0xFFEF4444),
      'جراحة عامة، مناظير',
    ),
    _Specialty(
      'أسنان',
      Icons.mood_rounded,
      Color(0xFF06B6D4),
      'تقويم، زراعة، تجميل',
    ),
    _Specialty(
      'أطفال',
      Icons.child_care_rounded,
      Color(0xFFF59E0B),
      'طب أطفال، تطعيمات',
    ),
    _Specialty(
      'قلب وشرايين',
      Icons.favorite_rounded,
      Color(0xFFEF4444),
      'قسطرة، إيكو، جهد',
    ),
    _Specialty(
      'جلدية',
      Icons.face_rounded,
      Color(0xFF8B5CF6),
      'جلدية، تجميل، ليزر',
    ),
    _Specialty(
      'عظام',
      Icons.accessibility_new_rounded,
      Color(0xFF10B981),
      'مفاصل، كسور، عمود',
    ),
    _Specialty(
      'عيون',
      Icons.visibility_rounded,
      Color(0xFF3B82F6),
      'ليزك، قرنية، شبكية',
    ),
    _Specialty(
      'أعصاب',
      Icons.psychology_rounded,
      Color(0xFF6366F1),
      'أعصاب، صرع، تخطيط',
    ),
    _Specialty(
      'نسائية وتوليد',
      Icons.pregnant_woman_rounded,
      Color(0xFFEC4899),
      'حمل، ولادة، نسائية',
    ),
    _Specialty(
      'مسالك بولية',
      Icons.water_drop_rounded,
      Color(0xFF0EA5E9),
      'كلى، مثانة، بروستات',
    ),
    _Specialty(
      'باطنية',
      Icons.monitor_heart_rounded,
      Color(0xFFF97316),
      'سكري، ضغط، غدد',
    ),
    _Specialty(
      'أنف وأذن وحنجرة',
      Icons.hearing_rounded,
      Color(0xFF14B8A6),
      'سمع، لوز، جيوب',
    ),
    _Specialty(
      'طب نفسي',
      Icons.self_improvement_rounded,
      Color(0xFF8B5CF6),
      'اكتئاب، قلق، علاج نفسي',
    ),
    _Specialty(
      'أشعة',
      Icons.filter_hdr_rounded,
      Color(0xFF64748B),
      'رنين، طبقي، سونار',
    ),
    _Specialty(
      'تحاليل مخبرية',
      Icons.science_rounded,
      Color(0xFF10B981),
      'دم، بول، هرمونات',
    ),
    _Specialty(
      'علاج طبيعي',
      Icons.sports_gymnastics_rounded,
      Color(0xFF0284C7),
      'تأهيل، رياضي، إصابات',
    ),
    _Specialty(
      'تغذية',
      Icons.restaurant_rounded,
      Color(0xFF22C55E),
      'حمية، سمنة، تغذية علاجية',
    ),
  ];

  // Clinics per specialty — comprehensive realistic data
  final Map<int, List<_Clinic>> _clinicsBySpec = {
    0: [
      // طب عام
      _Clinic(
        'عيادة د. محمد العبادي',
        'عمّان — الشميساني',
        4.7,
        2.5,
        true,
        'متاح اليوم',
        '15 د.أ',
        const LatLng(31.9750, 35.8900),
        'خبرة 15 سنة — طب عائلي',
      ),
      _Clinic(
        'عيادة د. سارة الناصر',
        'عمّان — خلدا',
        4.8,
        3.2,
        true,
        'متاح غداً',
        '20 د.أ',
        const LatLng(31.9650, 35.8700),
        'بورد أردني — طب عام',
      ),
      _Clinic(
        'مركز الشفاء الطبي',
        'عمّان — الجبيهة',
        4.5,
        4.0,
        true,
        'متاح اليوم',
        '12 د.أ',
        const LatLng(31.9800, 35.8800),
        'مركز متعدد التخصصات',
      ),
      _Clinic(
        'عيادة د. أحمد المصري',
        'إربد — شارع الجامعة',
        4.4,
        50.0,
        true,
        'متاح اليوم',
        '10 د.أ',
        const LatLng(32.5568, 35.8469),
        'طب عام — إربد',
      ),
      _Clinic(
        'عيادة د. لينا خطاب',
        'الزرقاء — وسط البلد',
        4.3,
        25.0,
        false,
        'مشغول',
        '10 د.أ',
        const LatLng(32.0633, 36.0880),
        'طب عام — الزرقاء',
      ),
    ],
    1: [
      // جراحة
      _Clinic(
        'د. خالد الزعبي — جراحة عامة',
        'عمّان — عبدون',
        4.9,
        3.0,
        true,
        'متاح',
        '30 د.أ',
        const LatLng(31.9560, 35.8770),
        'استشاري جراحة — 20 سنة خبرة',
      ),
      _Clinic(
        'د. رامي السعود — جراحة مناظير',
        'عمّان — الشميساني',
        4.8,
        2.8,
        true,
        'متاح',
        '35 د.أ',
        const LatLng(31.9730, 35.8900),
        'زميل الكلية الملكية',
      ),
      _Clinic(
        'د. فادي نصار — جراحة أوعية',
        'عمّان — الدوار الخامس',
        4.7,
        4.5,
        true,
        'متاح غداً',
        '25 د.أ',
        const LatLng(31.9630, 35.8570),
        'جراحة أوعية دموية',
      ),
    ],
    2: [
      // أسنان
      _Clinic(
        'مركز ابتسامة الأردن',
        'عمّان — عبدون',
        4.9,
        2.0,
        true,
        'متاح اليوم',
        '25 د.أ',
        const LatLng(31.9565, 35.8750),
        'تقويم، زراعة، تجميل',
      ),
      _Clinic(
        'عيادة د. ليلى حداد',
        'عمّان — الصويفية',
        4.7,
        3.5,
        true,
        'متاح',
        '20 د.أ',
        const LatLng(31.9590, 35.8550),
        'تجميل أسنان + ابتسامة هوليوود',
      ),
      _Clinic(
        'عيادة د. طارق القاسم',
        'إربد',
        4.6,
        48.0,
        true,
        'متاح',
        '15 د.أ',
        const LatLng(32.5500, 35.8500),
        'جراحة فم ولثة',
      ),
      _Clinic(
        'مركز الأسنان الحديث',
        'عمّان — الجاردنز',
        4.5,
        5.0,
        true,
        'متاح اليوم',
        '18 د.أ',
        const LatLng(31.9700, 35.8600),
        'كشف + تنظيف',
      ),
    ],
    3: [
      // أطفال
      _Clinic(
        'د. نادية الرفاعي — أطفال',
        'عمّان — الدوار الرابع',
        4.8,
        2.5,
        true,
        'متاح اليوم',
        '20 د.أ',
        const LatLng(31.9610, 35.8600),
        'بورد أطفال — تطعيمات',
      ),
      _Clinic(
        'د. عمر بركات — أطفال',
        'عمّان — خلدا',
        4.7,
        3.0,
        true,
        'متاح غداً',
        '18 د.أ',
        const LatLng(31.9660, 35.8720),
        'حساسية أطفال',
      ),
      _Clinic(
        'مركز الطفل السعيد',
        'إربد',
        4.5,
        50.0,
        true,
        'متاح',
        '12 د.أ',
        const LatLng(32.5510, 35.8480),
        'أطفال — تطعيمات — تغذية',
      ),
    ],
    4: [
      // قلب
      _Clinic(
        'د. باسم الشريف — قلب',
        'عمّان — الشميساني',
        4.9,
        2.0,
        true,
        'متاح',
        '40 د.أ',
        const LatLng(31.9740, 35.8910),
        'إيكو قلب + قسطرة',
      ),
      _Clinic(
        'مركز القلب الأردني',
        'عمّان — عبدون',
        4.8,
        3.0,
        true,
        'متاح',
        '35 د.أ',
        const LatLng(31.9550, 35.8760),
        'مركز تخصصي قلب',
      ),
    ],
    5: [
      // جلدية
      _Clinic(
        'د. هالة منصور — جلدية',
        'عمّان — الصويفية',
        4.8,
        2.5,
        true,
        'متاح اليوم',
        '25 د.أ',
        const LatLng(31.9580, 35.8540),
        'جلدية + ليزر + تجميل',
      ),
      _Clinic(
        'مركز ديرما كلينك',
        'عمّان — عبدون',
        4.7,
        3.0,
        true,
        'متاح',
        '30 د.أ',
        const LatLng(31.9570, 35.8730),
        'بوتوكس، فيلر، ليزر',
      ),
    ],
    6: [
      // عظام
      _Clinic(
        'د. فراس الزعبي — عظام',
        'عمّان — الشميساني',
        4.8,
        2.8,
        true,
        'متاح',
        '25 د.أ',
        const LatLng(31.9745, 35.8880),
        'مفاصل + إصابات رياضية',
      ),
      _Clinic(
        'د. وليد حمدان — عمود فقري',
        'عمّان — مرج الحمام',
        4.7,
        5.0,
        true,
        'متاح غداً',
        '30 د.أ',
        const LatLng(31.9400, 35.8400),
        'جراحة عمود فقري',
      ),
    ],
    7: [
      // عيون
      _Clinic(
        'مركز العيون التخصصي',
        'عمّان — الشميساني',
        4.9,
        2.0,
        true,
        'متاح',
        '20 د.أ',
        const LatLng(31.9735, 35.8920),
        'ليزك + فيمتو + شبكية',
      ),
      _Clinic(
        'د. رنا القيسي — عيون',
        'عمّان — خلدا',
        4.7,
        3.5,
        true,
        'متاح',
        '18 د.أ',
        const LatLng(31.9655, 35.8710),
        'عيون أطفال + حول',
      ),
    ],
  };

  List<_Clinic> get _currentClinics {
    var list = _clinicsBySpec[_selectedSpec] ?? [];
    if (_query.isNotEmpty) {
      list = list
          .where((c) => c.name.contains(_query) || c.address.contains(_query))
          .toList();
    }
    if (_sortBy == 'rating') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'distance') {
      list.sort((a, b) => a.distKm.compareTo(b.distKm));
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
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_selectedClinic >= 0) {
                        setState(() => _selectedClinic = -1);
                      } else if (_selectedSpec >= 0) {
                        setState(() {
                          _selectedSpec = -1;
                          _showMap = false;
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.textDark,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _selectedSpec < 0
                          ? 'دليل العيادات 🏥'
                          : _selectedClinic >= 0
                          ? _currentClinics[_selectedClinic].name
                          : _specialties[_selectedSpec].name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_selectedSpec >= 0 && _selectedClinic < 0)
                    GestureDetector(
                      onTap: () => setState(() => _showMap = !_showMap),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _showMap
                              ? const Color(0xFF10B981).withAlpha(15)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showMap ? Icons.list_rounded : Icons.map_rounded,
                              size: 16,
                              color: _showMap
                                  ? const Color(0xFF10B981)
                                  : AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _showMap ? 'قائمة' : 'خريطة',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _showMap
                                    ? const Color(0xFF10B981)
                                    : AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: _selectedClinic >= 0
                  ? _buildClinicDetail(_currentClinics[_selectedClinic])
                  : _selectedSpec < 0
                  ? _buildSpecialtiesGrid()
                  : _showMap
                  ? _buildMapView()
                  : _buildClinicsList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Specialties Grid ──
  Widget _buildSpecialtiesGrid() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withAlpha(30),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'جميع التخصصات الطبية',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_specialties.length} تخصص — عيادات في كل الأردن',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _heroBadge('حكيم', Icons.verified_rounded),
                        const SizedBox(width: 6),
                        _heroBadge('سند', Icons.account_balance_rounded),
                        const SizedBox(width: 6),
                        _heroBadge('خريطة حية', Icons.map_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.medical_services_rounded,
                size: 52,
                color: Colors.white24,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Search
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withAlpha(40)),
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
            decoration: const InputDecoration(
              hintText: 'ابحث عن تخصص أو عيادة...',
              hintStyle: TextStyle(fontSize: 13, color: AppColors.textLight),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.textLight,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: _specialties.length,
          itemBuilder: (_, i) {
            final s = _specialties[i];
            if (_query.isNotEmpty &&
                !s.name.contains(_query) &&
                !s.desc.contains(_query)) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedSpec = i;
                  _selectedClinic = -1;
                  _query = '';
                  _searchCtrl.clear();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: s.color.withAlpha(25)),
                  boxShadow: [
                    BoxShadow(
                      color: s.color.withAlpha(8),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: s.color.withAlpha(15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(s.icon, color: s.color, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.desc,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _heroBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Clinics List ──
  Widget _buildClinicsList() {
    final clinics = _currentClinics;
    return Column(
      children: [
        // Sort row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              Text(
                '${clinics.length} عيادة',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMedium,
                ),
              ),
              const Spacer(),
              _sortChip('تقييم', 'rating'),
              const SizedBox(width: 6),
              _sortChip('المسافة', 'distance'),
            ],
          ),
        ),
        Expanded(
          child: clinics.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد عيادات متاحة حالياً',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: clinics.length,
                  itemBuilder: (_, i) => _buildClinicCard(i, clinics[i]),
                ),
        ),
      ],
    );
  }

  Widget _sortChip(String label, String value) {
    final sel = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: sel
              ? const Color(0xFF10B981).withAlpha(15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: sel ? const Color(0xFF10B981) : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: sel ? const Color(0xFF10B981) : AppColors.textLight,
          ),
        ),
      ),
    );
  }

  Widget _buildClinicCard(int index, _Clinic c) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedClinic = index);
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
                    color: _specialties[_selectedSpec].color.withAlpha(15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: _specialties[_selectedSpec].color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.address,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              c.desc,
              style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _infoChip(
                  Icons.star_rounded,
                  '${c.rating}',
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 8),
                _infoChip(
                  Icons.location_on_rounded,
                  '${c.distKm} كم',
                  const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 8),
                _infoChip(
                  c.available
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  c.avStatus,
                  c.available
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
                const Spacer(),
                Text(
                  c.price,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Map View ──
  Widget _buildMapView() {
    final clinics = _currentClinics;
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: clinics.isNotEmpty
                ? clinics.first.location
                : const LatLng(31.95, 35.91),
            initialZoom: 12,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.teryaq.health',
            ),
            MarkerLayer(
              markers: clinics.asMap().entries.map((e) {
                final c = e.value;
                return Marker(
                  point: c.location,
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedClinic = e.key),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _specialties[_selectedSpec].color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _specialties[_selectedSpec].color.withAlpha(
                              50,
                            ),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        // Bottom list peek
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withAlpha(0),
                  AppColors.background,
                ],
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
              scrollDirection: Axis.horizontal,
              itemCount: clinics.length,
              itemBuilder: (_, i) {
                final c = clinics[i];
                return GestureDetector(
                  onTap: () => setState(() => _selectedClinic = i),
                  child: Container(
                    width: 220,
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border.withAlpha(60)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.address,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textLight,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFF59E0B),
                            ),
                            Text(
                              ' ${c.rating}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${c.distKm} كم',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textLight,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              c.price,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 4: Clinic Detail ──
  Widget _buildClinicDetail(_Clinic c) {
    final specColor = _selectedSpec >= 0
        ? _specialties[_selectedSpec].color
        : AppColors.primary;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Map preview
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(initialCenter: c.location, initialZoom: 15),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.teryaq.health',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: c.location,
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: specColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: specColor.withAlpha(50),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Info card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: specColor.withAlpha(25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: specColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: specColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.address,
                          style: const TextStyle(
                            fontSize: 12,
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
                            size: 18,
                          ),
                          Text(
                            ' ${c.rating}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.price,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                c.desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _detailChip(
                    Icons.location_on_rounded,
                    '${c.distKm} كم',
                    const Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 8),
                  _detailChip(
                    c.available
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    c.avStatus,
                    c.available
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ تم حجز موعد في ${c.name}'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                label: const Text(
                  'احجز موعد',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: specColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🗺️ يتم فتح التنقل...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.navigation_rounded, size: 18),
                label: const Text(
                  'تنقل بالخريطة',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: specColor,
                  side: BorderSide(color: specColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Call button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => HapticFeedback.mediumImpact(),
            icon: const Icon(Icons.phone_rounded, size: 18),
            label: const Text(
              'اتصل بالعيادة',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF10B981),
              side: const BorderSide(color: Color(0xFF10B981)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _detailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Specialty {
  final String name, desc;
  final IconData icon;
  final Color color;
  const _Specialty(this.name, this.icon, this.color, this.desc);
}

class _Clinic {
  final String name, address;
  final double rating, distKm;
  final bool available;
  final String avStatus, price, desc;
  final LatLng location;
  const _Clinic(
    this.name,
    this.address,
    this.rating,
    this.distKm,
    this.available,
    this.avStatus,
    this.price,
    this.location,
    this.desc,
  );
}
