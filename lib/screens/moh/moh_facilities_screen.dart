import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MohFacilitiesScreen extends StatefulWidget {
  const MohFacilitiesScreen({super.key});
  @override
  State<MohFacilitiesScreen> createState() => _MohFacilitiesScreenState();
}

class _MohFacilitiesScreenState extends State<MohFacilitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _govFilter = 'الكل';
  String _search = '';

  // ── Governorates ─────────────────────────
  static const _govs = [
    'الكل',
    'الرياض',
    'مكة المكرمة',
    'المدينة المنورة',
    'القصيم',
    'المنطقة الشرقية',
    'عسير',
    'تبوك',
    'حائل',
    'جازان',
    'نجران',
    'الباحة',
    'الجوف',
    'الحدود الشمالية',
  ];

  // ── Demo Hospitals ────────────────────────
  static final _hospitals = <Map<String, dynamic>>[
    // الرياض
    {
      'name': 'مستشفى الملك فهد التخصصي',
      'gov': 'الرياض',
      'type': 'حكومي تخصصي',
      'dept': 'قلب وأوعية',
      'beds': 1200,
      'occupied': 1056,
      'icu': 80,
      'icuOcc': 72,
      'er': 180,
      'waitList': 34,
    },
    {
      'name': 'مستشفى الملك سلمان العام',
      'gov': 'الرياض',
      'type': 'حكومي عام',
      'dept': 'متعدد التخصصات',
      'beds': 850,
      'occupied': 620,
      'icu': 60,
      'icuOcc': 44,
      'er': 120,
      'waitList': 12,
    },
    {
      'name': 'مستشفى الحرس الوطني',
      'gov': 'الرياض',
      'type': 'حكومي تخصصي',
      'dept': 'أورام',
      'beds': 900,
      'occupied': 815,
      'icu': 70,
      'icuOcc': 65,
      'er': 150,
      'waitList': 22,
    },
    {
      'name': 'مستشفى الأمير سلطان العسكري',
      'gov': 'الرياض',
      'type': 'عسكري',
      'dept': 'جراحة عامة',
      'beds': 650,
      'occupied': 540,
      'icu': 45,
      'icuOcc': 38,
      'er': 90,
      'waitList': 8,
    },
    // مكة المكرمة
    {
      'name': 'مستشفى الملك عبدالعزيز بجدة',
      'gov': 'مكة المكرمة',
      'type': 'حكومي عام',
      'dept': 'متعدد التخصصات',
      'beds': 1000,
      'occupied': 875,
      'icu': 65,
      'icuOcc': 60,
      'er': 200,
      'waitList': 45,
    },
    {
      'name': 'مستشفى الأمومة والطفولة بجدة',
      'gov': 'مكة المكرمة',
      'type': 'تخصصي',
      'dept': 'نساء وولادة',
      'beds': 400,
      'occupied': 312,
      'icu': 40,
      'icuOcc': 35,
      'er': 60,
      'waitList': 15,
    },
    {
      'name': 'مركز الملك فيصل التخصصي بجدة',
      'gov': 'مكة المكرمة',
      'type': 'تخصصي',
      'dept': 'زراعة أعضاء',
      'beds': 280,
      'occupied': 252,
      'icu': 38,
      'icuOcc': 36,
      'er': 40,
      'waitList': 20,
    },
    // المدينة المنورة
    {
      'name': 'مستشفى الملك فهد بالمدينة',
      'gov': 'المدينة المنورة',
      'type': 'حكومي عام',
      'dept': 'متعدد التخصصات',
      'beds': 700,
      'occupied': 560,
      'icu': 50,
      'icuOcc': 42,
      'er': 110,
      'waitList': 18,
    },
    {
      'name': 'مستشفى المدينة المنورة المركزي',
      'gov': 'المدينة المنورة',
      'type': 'حكومي',
      'dept': 'عام',
      'beds': 450,
      'occupied': 370,
      'icu': 35,
      'icuOcc': 28,
      'er': 75,
      'waitList': 10,
    },
    // القصيم
    {
      'name': 'مستشفى بريدة المركزي',
      'gov': 'القصيم',
      'type': 'حكومي عام',
      'dept': 'متعدد التخصصات',
      'beds': 550,
      'occupied': 430,
      'icu': 40,
      'icuOcc': 30,
      'er': 85,
      'waitList': 9,
    },
    {
      'name': 'مستشفى القصيم التخصصي للقلب',
      'gov': 'القصيم',
      'type': 'تخصصي',
      'dept': 'أمراض القلب',
      'beds': 300,
      'occupied': 265,
      'icu': 25,
      'icuOcc': 22,
      'er': 50,
      'waitList': 5,
    },
    // المنطقة الشرقية
    {
      'name': 'مستشفى الملك فهد بالدمام',
      'gov': 'المنطقة الشرقية',
      'type': 'حكومي تخصصي',
      'dept': 'قلب وجراحة',
      'beds': 1100,
      'occupied': 995,
      'icu': 85,
      'icuOcc': 81,
      'er': 190,
      'waitList': 55,
    },
    {
      'name': 'مستشفى أرامكو الطبي',
      'gov': 'المنطقة الشرقية',
      'type': 'مؤسسي',
      'dept': 'متعدد التخصصات',
      'beds': 600,
      'occupied': 450,
      'icu': 50,
      'icuOcc': 40,
      'er': 80,
      'waitList': 6,
    },
    // عسير
    {
      'name': 'مستشفى أبها المركزي',
      'gov': 'عسير',
      'type': 'حكومي عام',
      'dept': 'متعدد التخصصات',
      'beds': 480,
      'occupied': 392,
      'icu': 38,
      'icuOcc': 30,
      'er': 70,
      'waitList': 11,
    },
    // تبوك
    {
      'name': 'مستشفى الأمير فهد بتبوك',
      'gov': 'تبوك',
      'type': 'حكومي عام',
      'dept': 'متعدد التخصصات',
      'beds': 420,
      'occupied': 310,
      'icu': 32,
      'icuOcc': 24,
      'er': 65,
      'waitList': 6,
    },
    // حائل
    {
      'name': 'مستشفى حائل المركزي',
      'gov': 'حائل',
      'type': 'حكومي عام',
      'dept': 'عام',
      'beds': 290,
      'occupied': 212,
      'icu': 22,
      'icuOcc': 15,
      'er': 45,
      'waitList': 4,
    },
    // جازان
    {
      'name': 'مستشفى جازان العام',
      'gov': 'جازان',
      'type': 'حكومي',
      'dept': 'متعدد التخصصات',
      'beds': 380,
      'occupied': 332,
      'icu': 28,
      'icuOcc': 25,
      'er': 60,
      'waitList': 14,
    },
    // نجران
    {
      'name': 'مستشفى نجران العام',
      'gov': 'نجران',
      'type': 'حكومي',
      'dept': 'عام',
      'beds': 260,
      'occupied': 200,
      'icu': 20,
      'icuOcc': 16,
      'er': 40,
      'waitList': 3,
    },
    // الباحة
    {
      'name': 'مستشفى الباحة العام',
      'gov': 'الباحة',
      'type': 'حكومي',
      'dept': 'عام',
      'beds': 220,
      'occupied': 170,
      'icu': 18,
      'icuOcc': 12,
      'er': 35,
      'waitList': 2,
    },
    // الجوف
    {
      'name': 'مستشفى الجوف المركزي',
      'gov': 'الجوف',
      'type': 'حكومي',
      'dept': 'عام',
      'beds': 200,
      'occupied': 145,
      'icu': 16,
      'icuOcc': 11,
      'er': 30,
      'waitList': 2,
    },
    // الحدود الشمالية
    {
      'name': 'مستشفى عرعر المركزي',
      'gov': 'الحدود الشمالية',
      'type': 'حكومي',
      'dept': 'عام',
      'beds': 180,
      'occupied': 130,
      'icu': 14,
      'icuOcc': 9,
      'er': 28,
      'waitList': 1,
    },
  ];

  // ── Demo Health Centers ───────────────────
  static final _centers = <Map<String, dynamic>>[
    {
      'name': 'مركز الملك عبدالله الصحي',
      'gov': 'الرياض',
      'type': 'ثانوي',
      'address': 'حي العليا، الرياض',
      'phone': '011-234-5678',
      'services': ['باطنية', 'أطفال', 'نساء', 'أسنان', 'عيون'],
    },
    {
      'name': 'مركز صحة الأسرة - الروضة',
      'gov': 'الرياض',
      'type': 'أولي',
      'address': 'حي الروضة، الرياض',
      'phone': '011-239-8765',
      'services': ['عام', 'تطعيم', 'أمراض مزمنة'],
    },
    {
      'name': 'مركز الفيصلية الصحي',
      'gov': 'الرياض',
      'type': 'أولي',
      'address': 'حي الفيصلية، الرياض',
      'phone': '011-231-2345',
      'services': ['عام', 'تطعيم', 'طب أسرة'],
    },
    {
      'name': 'مركز جدة الصحي المركزي',
      'gov': 'مكة المكرمة',
      'type': 'ثانوي',
      'address': 'شارع فلسطين، جدة',
      'phone': '012-224-5678',
      'services': ['باطنية', 'أمراض مزمنة', 'أسنان', 'نساء', 'أطفال'],
    },
    {
      'name': 'مركز حي الرحمانية الصحي',
      'gov': 'مكة المكرمة',
      'type': 'أولي',
      'address': 'حي الرحمانية، جدة',
      'phone': '012-229-8765',
      'services': ['عام', 'تطعيم', 'نساء'],
    },
    {
      'name': 'مركز العيون التخصصي - جدة',
      'gov': 'مكة المكرمة',
      'type': 'تخصصي',
      'address': 'شارع التحلية، جدة',
      'phone': '012-233-1100',
      'services': ['عيون', 'ليزر', 'قياس نظر', 'تدخل جراحي'],
    },
    {
      'name': 'مركز المدينة الصحي الشمالي',
      'gov': 'المدينة المنورة',
      'type': 'أولي',
      'address': 'شمال المدينة المنورة',
      'phone': '014-881-2345',
      'services': ['عام', 'تطعيم', 'طب أسرة'],
    },
    {
      'name': 'مركز العيون بالمدينة',
      'gov': 'المدينة المنورة',
      'type': 'تخصصي',
      'address': 'وسط المدينة المنورة',
      'phone': '014-885-6789',
      'services': ['عيون', 'ليزر', 'نظارات'],
    },
    {
      'name': 'مركز صحة بريدة الثانوي',
      'gov': 'القصيم',
      'type': 'ثانوي',
      'address': 'شارع الملك فهد، بريدة',
      'phone': '016-331-2345',
      'services': ['باطنية', 'أطفال', 'أسنان', 'تطعيم'],
    },
    {
      'name': 'مركز الدمام الصحي الساحلي',
      'gov': 'المنطقة الشرقية',
      'type': 'ثانوي',
      'address': 'حي الشاطئ، الدمام',
      'phone': '013-884-5678',
      'services': ['عيون', 'باطنية', 'أسنان', 'أطفال', 'نساء'],
    },
    {
      'name': 'مركز الخبر الصحي الأولي',
      'gov': 'المنطقة الشرقية',
      'type': 'أولي',
      'address': 'حي الخبر الشمالي',
      'phone': '013-881-2345',
      'services': ['عام', 'تطعيم', 'طب أسرة'],
    },
    {
      'name': 'مركز أبها الصحي المركزي',
      'gov': 'عسير',
      'type': 'ثانوي',
      'address': 'شارع الأمير سلطان، أبها',
      'phone': '017-224-5678',
      'services': ['باطنية', 'أسنان', 'أطفال', 'نساء'],
    },
    {
      'name': 'مركز تبوك الصحي المتكامل',
      'gov': 'تبوك',
      'type': 'ثانوي',
      'address': 'حي الملك فهد، تبوك',
      'phone': '014-441-2345',
      'services': ['باطنية', 'أسنان', 'نساء', 'تطعيم'],
    },
    {
      'name': 'مركز جازان الصحي الأولي',
      'gov': 'جازان',
      'type': 'أولي',
      'address': 'وسط جازان',
      'phone': '017-331-2345',
      'services': ['عام', 'تطعيم', 'أمراض مزمنة'],
    },
    {
      'name': 'مركز حائل الصحي الأولي',
      'gov': 'حائل',
      'type': 'أولي',
      'address': 'حي الملك فهد، حائل',
      'phone': '016-362-1234',
      'services': ['عام', 'تطعيم'],
    },
    {
      'name': 'مركز نجران الصحي',
      'gov': 'نجران',
      'type': 'أولي',
      'address': 'وسط نجران',
      'phone': '017-551-2345',
      'services': ['عام', 'تطعيم', 'أسنان'],
    },
    {
      'name': 'مركز الباحة الصحي',
      'gov': 'الباحة',
      'type': 'أولي',
      'address': 'مركز مدينة الباحة',
      'phone': '017-725-1234',
      'services': ['عام', 'تطعيم', 'طب أسرة'],
    },
    {
      'name': 'مركز الجوف الصحي المركزي',
      'gov': 'الجوف',
      'type': 'ثانوي',
      'address': 'سكاكا، الجوف',
      'phone': '014-622-3456',
      'services': ['باطنية', 'أطفال', 'أسنان'],
    },
  ];

  // ── Demo Pharmacies ───────────────────────
  static final _pharmacies = <Map<String, dynamic>>[
    {
      'name': 'صيدلية النهدي - طريق الملك فهد',
      'gov': 'الرياض',
      'address': 'طريق الملك فهد، الرياض',
      'insurance': true,
      'insuranceTypes': ['بوبا', 'ميدغلف', 'تأمين الوطنية'],
      'dispensingRate': 87,
      'dispensingValue': 1240000,
      'topMeds': ['ابتراليس', 'ميتفورمين', 'روستر', 'كونكور'],
      'shortage': ['رانيتيدين'],
    },
    {
      'name': 'صيدلية الدواء - حي النخيل',
      'gov': 'الرياض',
      'address': 'حي النخيل، الرياض',
      'insurance': true,
      'insuranceTypes': ['بوبا', 'تأمين الراجحي'],
      'dispensingRate': 92,
      'dispensingValue': 980000,
      'topMeds': ['أوميبرازول', 'أملوديبين', 'ثايروكسين', 'أتورفاستاتين'],
      'shortage': <String>[],
    },
    {
      'name': 'صيدلية ابن سينا - العليا',
      'gov': 'الرياض',
      'address': 'حي العليا، الرياض',
      'insurance': false,
      'insuranceTypes': <String>[],
      'dispensingRate': 74,
      'dispensingValue': 650000,
      'topMeds': ['باراسيتامول', 'إيبوبروفين', 'فيتامين د'],
      'shortage': ['كلوروكوين'],
    },
    {
      'name': 'صيدلية الرعاية - شارع التحلية',
      'gov': 'مكة المكرمة',
      'address': 'شارع التحلية، جدة',
      'insurance': true,
      'insuranceTypes': ['ميدغلف', 'بوبا السعودية', 'تويليو'],
      'dispensingRate': 95,
      'dispensingValue': 2100000,
      'topMeds': ['أسبرين', 'ريفاروكسابان', 'إنسولين غلارجين', 'ليفوثيروكسين'],
      'shortage': <String>[],
    },
    {
      'name': 'صيدلية النهدي - جدة الشمال',
      'gov': 'مكة المكرمة',
      'address': 'حي الشاطئ، جدة',
      'insurance': true,
      'insuranceTypes': ['بوبا', 'ميدغلف'],
      'dispensingRate': 83,
      'dispensingValue': 780000,
      'topMeds': ['فيتامين ج', 'زنك', 'باراسيتامول', 'سيتيريزين'],
      'shortage': ['أموكسيسيلين جرعة طفل'],
    },
    {
      'name': 'صيدلية الأندلس - المدينة المنورة',
      'gov': 'المدينة المنورة',
      'address': 'حي الأندلس، المدينة',
      'insurance': true,
      'insuranceTypes': ['تأمين الوطنية', 'بوبا'],
      'dispensingRate': 80,
      'dispensingValue': 540000,
      'topMeds': ['أتورفاستاتين', 'ملتيفيتامين', 'كريم ببابانثين'],
      'shortage': <String>[],
    },
    {
      'name': 'صيدلية بريدة الرئيسية',
      'gov': 'القصيم',
      'address': 'شارع الملك فيصل، بريدة',
      'insurance': false,
      'insuranceTypes': <String>[],
      'dispensingRate': 70,
      'dispensingValue': 320000,
      'topMeds': ['إيبوبروفين', 'باراسيتامول', 'أنتاسيد'],
      'shortage': ['غابابنتين 300'],
    },
    {
      'name': 'صيدلية الدمام المركزية',
      'gov': 'المنطقة الشرقية',
      'address': 'حي الشاطئ، الدمام',
      'insurance': true,
      'insuranceTypes': ['أرامكو', 'بوبا', 'ميدغلف'],
      'dispensingRate': 96,
      'dispensingValue': 3200000,
      'topMeds': ['إنسولين', 'موزابريد', 'أتورفاستاتين', 'بريدنيزون'],
      'shortage': <String>[],
    },
    {
      'name': 'صيدلية الصفا - الخبر',
      'gov': 'المنطقة الشرقية',
      'address': 'حي الصفا، الخبر',
      'insurance': true,
      'insuranceTypes': ['أرامكو', 'تويليو'],
      'dispensingRate': 89,
      'dispensingValue': 1100000,
      'topMeds': ['أوميبرازول', 'سيرترالين', 'فيتامين د', 'كالسيوم'],
      'shortage': <String>[],
    },
    {
      'name': 'صيدلية أبها الرئيسية',
      'gov': 'عسير',
      'address': 'وسط أبها',
      'insurance': false,
      'insuranceTypes': <String>[],
      'dispensingRate': 68,
      'dispensingValue': 280000,
      'topMeds': ['باراسيتامول', 'أموكسيسيلين', 'سيتيريزين'],
      'shortage': ['إبينيفرين قلم'],
    },
    {
      'name': 'صيدلية تبوك العلاجية',
      'gov': 'تبوك',
      'address': 'شارع المدينة، تبوك',
      'insurance': true,
      'insuranceTypes': ['بوبا'],
      'dispensingRate': 78,
      'dispensingValue': 410000,
      'topMeds': ['أملوديبين', 'ميتفورمين', 'أسبرين'],
      'shortage': <String>[],
    },
    {
      'name': 'صيدلية جازان الخضراء',
      'gov': 'جازان',
      'address': 'شارع الملك خالد، جازان',
      'insurance': false,
      'insuranceTypes': <String>[],
      'dispensingRate': 62,
      'dispensingValue': 190000,
      'topMeds': ['باراسيتامول', 'فيريفين', 'إيبوبروفين'],
      'shortage': ['كلوروكوين', 'دوكسيسيكلين'],
    },
    {
      'name': 'صيدلية حائل الصحية',
      'gov': 'حائل',
      'address': 'حي الملك فهد، حائل',
      'insurance': false,
      'insuranceTypes': <String>[],
      'dispensingRate': 71,
      'dispensingValue': 210000,
      'topMeds': ['باراسيتامول', 'أملوديبين', 'فيتامين ب'],
      'shortage': <String>[],
    },
    {
      'name': 'صيدلية مدينة العيون - الجوف',
      'gov': 'الجوف',
      'address': 'مدينة العيون، الجوف',
      'insurance': true,
      'insuranceTypes': ['تأمين الوطنية'],
      'dispensingRate': 76,
      'dispensingValue': 240000,
      'topMeds': ['ميتفورمين', 'أوميبرازول', 'كالسيوم'],
      'shortage': <String>[],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // ── Derived Stats ─────────────────────────
  int get _totalBeds => _hospitals.fold(0, (s, h) => s + (h['beds'] as int));
  int get _totalOccupied =>
      _hospitals.fold(0, (s, h) => s + (h['occupied'] as int));
  double get _avgOccupancy => _totalBeds > 0 ? _totalOccupied / _totalBeds : 0;

  List<Map<String, dynamic>> get _filteredHospitals => _hospitals
      .where(
        (h) =>
            (_govFilter == 'الكل' || h['gov'] == _govFilter) &&
            (_search.isEmpty ||
                h['name'].toString().contains(_search) ||
                h['gov'].toString().contains(_search)),
      )
      .toList();

  List<Map<String, dynamic>> get _filteredCenters => _centers
      .where(
        (c) =>
            (_govFilter == 'الكل' || c['gov'] == _govFilter) &&
            (_search.isEmpty ||
                c['name'].toString().contains(_search) ||
                c['address'].toString().contains(_search)),
      )
      .toList();

  List<Map<String, dynamic>> get _filteredPharmacies => _pharmacies
      .where(
        (p) =>
            (_govFilter == 'الكل' || p['gov'] == _govFilter) &&
            (_search.isEmpty ||
                p['name'].toString().contains(_search) ||
                p['address'].toString().contains(_search)),
      )
      .toList();

  Map<String, List<Map<String, dynamic>>> get _hospitalsByGov {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final h in _filteredHospitals) {
      map.putIfAbsent(h['gov'] as String, () => []).add(h);
    }
    return map;
  }

  // ── Build ─────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 0),
          color: const Color(0xFF1E293B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  const Text('🏥', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'المرافق الصحية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: _govFilter != 'الكل'
                          ? const Color(0xFF10B981)
                          : Colors.white54,
                      size: 22,
                    ),
                    onPressed: _showFilterSheet,
                    tooltip: 'تصفية المنطقة',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Summary chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _summaryChip('🏥', '${_hospitals.length}', 'مستشفى'),
                    const SizedBox(width: 8),
                    _summaryChip('🛏️', '$_totalBeds', 'سرير'),
                    const SizedBox(width: 8),
                    _summaryChip(
                      '📊',
                      '${(_avgOccupancy * 100).toStringAsFixed(0)}%',
                      'إشغال وطني',
                    ),
                    const SizedBox(width: 8),
                    _summaryChip('🏢', '${_centers.length}', 'مركز صحي'),
                    const SizedBox(width: 8),
                    _summaryChip('💊', '${_pharmacies.length}', 'صيدلية'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Search
              TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'بحث عن مرفق، منطقة...',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(60)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white38,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: Colors.white.withAlpha(8),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Active region filter
              if (_govFilter != 'الكل')
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () => setState(() => _govFilter = 'الكل'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withAlpha(80),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFF10B981),
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _govFilter,
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF10B981),
                            size: 13,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Tab bar
              TabBar(
                controller: _tab,
                indicatorColor: const Color(0xFF10B981),
                labelColor: const Color(0xFF10B981),
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: 'مستشفيات (${_filteredHospitals.length})'),
                  Tab(text: 'مراكز صحية (${_filteredCenters.length})'),
                  Tab(text: 'صيدليات (${_filteredPharmacies.length})'),
                ],
              ),
            ],
          ),
        ),
        // Body
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [_hospitalsTab(), _centersTab(), _pharmaciesTab()],
          ),
        ),
      ],
    );
  }

  // ── Hospitals Tab ─────────────────────────
  Widget _hospitalsTab() {
    final grouped = _hospitalsByGov;
    if (grouped.isEmpty) {
      return _empty('لا توجد مستشفيات');
    }
    final items = <Widget>[];
    for (final entry in grouped.entries) {
      final govHospitals = entry.value;
      final govBeds = govHospitals.fold(0, (s, h) => s + (h['beds'] as int));
      final govOcc = govHospitals.fold(0, (s, h) => s + (h['occupied'] as int));
      final occRate = govBeds > 0 ? govOcc / govBeds : 0.0;
      final occColor = _occColor(occRate);

      // Region section header
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: occColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.location_city_rounded,
                  color: occColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${govHospitals.length} مستشفى  •  إشغال ${(occRate * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: occColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );

      // Hospital cards — directly tappable, no expand needed
      items.addAll(govHospitals.map(_hospitalCard));
      items.add(const SizedBox(height: 4));
    }

    return ListView(padding: const EdgeInsets.all(12), children: items);
  }

  Widget _hospitalCard(Map<String, dynamic> h) {
    final beds = h['beds'] as int;
    final occ = h['occupied'] as int;
    final icuTotal = h['icu'] as int;
    final icuOcc = h['icuOcc'] as int;
    final occRate = occ / beds;
    final icuRate = icuTotal > 0 ? icuOcc / icuTotal : 0.0;
    final occC = _occColor(occRate);
    final icuC = icuRate > 0.85
        ? Colors.redAccent
        : icuRate > 0.65
        ? const Color(0xFFF59E0B)
        : const Color(0xFF10B981);

    return GestureDetector(
      onTap: () => _showHospitalDetail(h),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [occC.withAlpha(60), Colors.white.withAlpha(5)],
            stops: const [0.0, 0.08],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: occC.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + type badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    h['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    h['type'] as String,
                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '🏥 ${h['dept']}',
              style: TextStyle(color: Colors.white.withAlpha(110), fontSize: 11),
            ),
            const SizedBox(height: 10),
            // Beds bar
            Row(
              children: [
                const Text('🛏️', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text(
                    'الأسرة العامة',
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$occ/$beds',
                  style: TextStyle(color: occC, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: occRate.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withAlpha(12),
                valueColor: AlwaysStoppedAnimation(occC),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 8),
            // ICU bar
            Row(
              children: [
                const Text('🫀', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text(
                    'ICU',
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$icuOcc/$icuTotal',
                  style: TextStyle(color: icuC, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: icuRate.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withAlpha(12),
                valueColor: AlwaysStoppedAnimation(icuC),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 10),
            // Stats row — icons only, no long text
            Row(
              children: [
                Icon(Icons.emergency_rounded, color: Colors.redAccent, size: 13),
                const SizedBox(width: 3),
                Text(
                  '${h['er']}',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 12),
                Icon(Icons.hourglass_bottom_rounded, color: const Color(0xFFF59E0B), size: 13),
                const SizedBox(width: 3),
                Text(
                  '${h['waitList']}',
                  style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Icon(
                  occRate >= 0.95 ? Icons.dangerous_rounded
                      : occRate >= 0.8 ? Icons.warning_amber_rounded
                      : Icons.check_circle_rounded,
                  color: occC,
                  size: 13,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Tap hint button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: occC.withAlpha(18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: occC.withAlpha(40)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.open_in_new_rounded, color: occC, size: 11),
                  const SizedBox(width: 5),
                  Text(
                    'اضغط لعرض التفاصيل',
                    style: TextStyle(color: occC, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressRow(
    String emoji,
    String label,
    int val,
    int total,
    Color color,
  ) {
    final rate = total > 0 ? val / total : 0.0;
    return Column(
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$val / $total',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rate.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withAlpha(12),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  // ── Health Centers Tab ────────────────────
  Widget _centersTab() {
    final list = _filteredCenters;
    if (list.isEmpty) return _empty('لا توجد مراكز');
    // Group count by type
    final primary = list.where((c) => c['type'] == 'أولي').length;
    final secondary = list.where((c) => c['type'] == 'ثانوي').length;
    final special = list.where((c) => c['type'] == 'تخصصي').length;

    return Column(
      children: [
        // Centers summary bar
        Container(
          color: const Color(0xFF1E293B),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _tabStat('🟢', '$primary', 'أولي'),
              _tabStat('🔵', '$secondary', 'ثانوي'),
              _tabStat('🟣', '$special', 'تخصصي'),
              _tabStat('📍', '${list.length}', 'إجمالي'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) => _centerCard(list[i]),
          ),
        ),
      ],
    );
  }

  Widget _centerCard(Map<String, dynamic> c) {
    final type = c['type'] as String;
    final typeColor = type == 'ثانوي'
        ? const Color(0xFF3B82F6)
        : type == 'تخصصي'
        ? const Color(0xFFA855F7)
        : const Color(0xFF10B981);
    final services = (c['services'] as List).cast<String>();

    return GestureDetector(
      onTap: () => _showCenterDetail(c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [typeColor.withAlpha(60), const Color(0xFF1E293B)],
            stops: const [0.0, 0.08],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: typeColor.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.health_and_safety_rounded,
                    color: typeColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                color: typeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            c['gov'] as String,
                            style: TextStyle(
                              color: Colors.white.withAlpha(100),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white38,
                  size: 13,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    c['address'] as String,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.phone_rounded,
                  color: Colors.white38,
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  c['phone'] as String,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: services
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withAlpha(15)),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: typeColor.withAlpha(18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: typeColor.withAlpha(40)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.open_in_new_rounded, color: typeColor, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    'اضغط لعرض التفاصيل الكاملة',
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: typeColor.withAlpha(180),
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pharmacies Tab ────────────────────────
  Widget _pharmaciesTab() {
    final list = _filteredPharmacies;
    if (list.isEmpty) return _empty('لا توجد صيدليات');

    final totalValue = list.fold<int>(
      0,
      (s, p) => s + (p['dispensingValue'] as int),
    );
    final avgRate =
        list.fold<int>(0, (s, p) => s + (p['dispensingRate'] as int)) /
        list.length;
    final withInsurance = list.where((p) => p['insurance'] as bool).length;
    final shortageCount = list
        .where((p) => ((p['shortage'] as List).isNotEmpty))
        .length;

    return Column(
      children: [
        // Pharmacy summary bar
        Container(
          color: const Color(0xFF1E293B),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _tabStat('🛡️', '$withInsurance', 'بتأمين'),
              _tabStat('📈', '${avgRate.toStringAsFixed(0)}%', 'متوسط صرف'),
              _tabStat(
                '💰',
                '${(totalValue / 1000000).toStringAsFixed(1)}م ر',
                'إجمالي صرف',
              ),
              _tabStat('⚠️', '$shortageCount', 'فيها نقص'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) => _pharmacyCard(list[i]),
          ),
        ),
      ],
    );
  }

  Widget _pharmacyCard(Map<String, dynamic> p) {
    final hasInsurance = p['insurance'] as bool;
    final dispRate = p['dispensingRate'] as int;
    final dispValue = p['dispensingValue'] as int;
    final dispColor = dispRate >= 90
        ? const Color(0xFF10B981)
        : dispRate >= 75
        ? const Color(0xFFF59E0B)
        : Colors.redAccent;
    final insuranceTypes = (p['insuranceTypes'] as List).cast<String>();
    final topMeds = (p['topMeds'] as List).cast<String>();
    final shortage = (p['shortage'] as List).cast<String>();

    return GestureDetector(
      onTap: () => _showPharmacyDetail(p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [dispColor.withAlpha(60), const Color(0xFF1E293B)],
            stops: const [0.0, 0.08],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: dispColor.withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('💊', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white38,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              p['address'] as String,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (hasInsurance)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withAlpha(60),
                      ),
                    ),
                    child: const Text(
                      '🛡️ تأمين',
                      style: TextStyle(
                        color: Color(0xFF60A5FA),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Dispensing rate progress
            Row(
              children: [
                const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white38,
                  size: 14,
                ),
                const SizedBox(width: 5),
                const Text(
                  'نسبة الصرف',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '$dispRate%',
                  style: TextStyle(
                    color: dispColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: dispRate / 100,
                backgroundColor: Colors.white.withAlpha(12),
                valueColor: AlwaysStoppedAnimation(dispColor),
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  'إجمالي الصرف: ',
                  style: TextStyle(
                    color: Colors.white.withAlpha(100),
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${(dispValue / 1000).toStringAsFixed(0)} ألف ريال',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            // Insurance types
            if (hasInsurance && insuranceTypes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.shield_rounded,
                    color: Color(0xFF60A5FA),
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'التأمين المقبول',
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: insuranceTypes
                    .map(
                      (ins) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withAlpha(12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withAlpha(40),
                          ),
                        ),
                        child: Text(
                          ins,
                          style: const TextStyle(
                            color: Color(0xFF93C5FD),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            // Top medicines
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.medication_rounded,
                  color: Color(0xFF6EE7B7),
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  'الأدوية الأكثر صرفاً',
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: topMeds
                  .map(
                    (med) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withAlpha(40),
                        ),
                      ),
                      child: Text(
                        med,
                        style: const TextStyle(
                          color: Color(0xFF6EE7B7),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            // Shortage alert
            if (shortage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orangeAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'نقص في المخزون',
                    style: TextStyle(
                      color: Colors.orange.withAlpha(200),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: shortage
                    .map(
                      (s) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.orange.withAlpha(50),
                          ),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: dispColor.withAlpha(18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: dispColor.withAlpha(40)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.open_in_new_rounded, color: dispColor, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    'اضغط لعرض التفاصيل الكاملة',
                    style: TextStyle(
                      color: dispColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: dispColor.withAlpha(180),
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────
  Color _occColor(double rate) => rate > 0.9
      ? Colors.redAccent
      : rate > 0.7
      ? const Color(0xFFF59E0B)
      : const Color(0xFF10B981);

  Widget _summaryChip(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 1),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _tabStat(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, Color color, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  Widget _empty(String msg) {
    return Center(
      child: Text(
        msg,
        style: const TextStyle(color: Colors.white54, fontSize: 14),
      ),
    );
  }

  // ── Detail Sheets ─────────────────────────
  void _showHospitalDetail(Map<String, dynamic> h) {
    HapticFeedback.mediumImpact();
    final beds = h['beds'] as int;
    final occ = h['occupied'] as int;
    final available = beds - occ;
    final icu = h['icu'] as int;
    final icuOcc = h['icuOcc'] as int;
    final er = h['er'] as int;
    final wait = h['waitList'] as int;
    final occRate = occ / beds;
    final icuRate = icu > 0 ? icuOcc / icu : 0.0;
    final occC = _occColor(occRate);
    final icuC = icuRate > 0.85
        ? Colors.redAccent
        : icuRate > 0.65
        ? const Color(0xFFF59E0B)
        : const Color(0xFF10B981);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, ctrl) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: occC.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.local_hospital_rounded,
                        color: occC,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _detailBadge(h['type'] as String, Colors.white30),
                              _detailBadge(
                                h['gov'] as String,
                                const Color(0xFF10B981),
                              ),
                              _detailBadge(
                                h['dept'] as String,
                                const Color(0xFF3B82F6),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: occC.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: occC.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        occRate >= 0.95
                            ? Icons.dangerous_rounded
                            : occRate >= 0.8
                            ? Icons.warning_rounded
                            : Icons.check_circle_rounded,
                        color: occC,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              occRate >= 0.95
                                  ? '⛔ الطاقة الاستيعابية ممتلئة'
                                  : occRate >= 0.8
                                  ? '⚠️ يقترب من الطاقة القصوى'
                                  : '✅ الوضع مستقر',
                              style: TextStyle(
                                color: occC,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'إشغال ${(occRate * 100).toStringAsFixed(1)}% — ${beds - occ} سرير متاح من $beds',
                              style: TextStyle(
                                color: occC.withAlpha(180),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _detailSectionTitle('📊 الإشغال الحالي'),
                const SizedBox(height: 12),
                _detailProgressBar('🛏️ الأسرة العامة', occ, beds, occC),
                const SizedBox(height: 10),
                _detailProgressBar(
                  '🫀 العناية المركزة (ICU)',
                  icuOcc,
                  icu,
                  icuC,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.05,
                  children: [
                    _statCell(
                      '🟢',
                      '$available',
                      'متاح',
                      const Color(0xFF10B981),
                    ),
                    _statCell('🔴', '$occ', 'مشغول', Colors.redAccent),
                    _statCell('🚨', '$er', 'طاقة طوارئ', Colors.orange),
                    _statCell('⏳', '$wait', 'انتظار', const Color(0xFFF59E0B)),
                    _statCell(
                      '🫀',
                      '$icu',
                      'أسرة ICU',
                      const Color(0xFF8B5CF6),
                    ),
                    _statCell(
                      '📊',
                      '${(occRate * 100).toStringAsFixed(0)}%',
                      'الإشغال',
                      occC,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _detailSectionTitle('🏥 معلومات المستشفى'),
                const SizedBox(height: 10),
                _infoRow2(
                  Icons.apartment_rounded,
                  'القسم الرئيسي',
                  h['dept'] as String,
                ),
                _infoRow2(
                  Icons.business_center_rounded,
                  'النوع',
                  h['type'] as String,
                ),
                _infoRow2(
                  Icons.location_on_rounded,
                  'المنطقة',
                  h['gov'] as String,
                ),
                _infoRow2(
                  Icons.calendar_today_rounded,
                  'سنة التأسيس',
                  '${1960 + (beds % 40)}',
                ),
                _infoRow2(
                  Icons.star_rounded,
                  'التقييم',
                  '⭐ ${(3.5 + (beds % 15) / 10).toStringAsFixed(1)} من 5',
                ),
                _infoRow2(
                  Icons.people_rounded,
                  'عدد الأطباء',
                  '${beds ~/ 6} طبيب',
                ),
                _infoRow2(
                  Icons.medical_services_rounded,
                  'عدد التمريض',
                  '${beds ~/ 3} ممرض/ة',
                ),
                _infoRow2(
                  Icons.access_time_rounded,
                  'ساعات العمل',
                  '24 ساعة / 7 أيام',
                ),
                _infoRow2(
                  Icons.hourglass_top_rounded,
                  'وقت الانتظار المتوقع',
                  '${wait > 0 ? (wait * 3 + 15) : 10} دقيقة',
                ),
                _infoRow2(
                  Icons.local_parking_rounded,
                  'موقف السيارات',
                  'متاح على مدار الساعة',
                ),
                const SizedBox(height: 20),
                _detailSectionTitle('🏥 الأقسام الطبية'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                            h['dept'] as String,
                            'طب الطوارئ',
                            'الباطنية',
                            'الجراحة',
                            'التخدير',
                            'الأشعة',
                            'المختبر',
                            'الصيدلة',
                          ]
                          .map(
                            (d) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: occC.withAlpha(12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: occC.withAlpha(30)),
                              ),
                              child: Text(
                                d,
                                style: TextStyle(color: occC, fontSize: 11),
                              ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 24),
                _detailSectionTitle('⚡ إجراءات'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _actionBtn(
                        Icons.phone_rounded,
                        'اتصال',
                        const Color(0xFF10B981),
                        () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn(
                        Icons.bed_rounded,
                        'حجز سرير',
                        const Color(0xFF3B82F6),
                        () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn(
                        Icons.share_rounded,
                        'مشاركة',
                        const Color(0xFF8B5CF6),
                        () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCenterDetail(Map<String, dynamic> c) {
    HapticFeedback.mediumImpact();
    final type = c['type'] as String;
    final services = (c['services'] as List).cast<String>();
    final typeColor = type == 'ثانوي'
        ? const Color(0xFF3B82F6)
        : type == 'تخصصي'
        ? const Color(0xFFA855F7)
        : const Color(0xFF10B981);
    final docCount = type == 'تخصصي'
        ? 12
        : type == 'ثانوي'
        ? 8
        : 4;
    final nurseCount = type == 'تخصصي'
        ? 20
        : type == 'ثانوي'
        ? 14
        : 8;
    final patientsPerDay = type == 'تخصصي'
        ? 180
        : type == 'ثانوي'
        ? 120
        : 60;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, ctrl) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: typeColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.health_and_safety_rounded,
                        color: typeColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              _detailBadge(type, typeColor),
                              _detailBadge(
                                c['gov'] as String,
                                const Color(0xFF10B981),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _statCell(
                        '👨‍⚕️',
                        '$docCount',
                        'طبيب',
                        const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _statCell(
                        '👩‍⚕️',
                        '$nurseCount',
                        'ممرض/ة',
                        const Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _statCell(
                        '🧑',
                        '$patientsPerDay',
                        'مريض/يوم',
                        const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _detailSectionTitle('📍 معلومات المركز'),
                const SizedBox(height: 10),
                _infoRow2(
                  Icons.location_on_rounded,
                  'العنوان',
                  c['address'] as String,
                ),
                _infoRow2(Icons.phone_rounded, 'الهاتف', c['phone'] as String),
                _infoRow2(Icons.business_rounded, 'النوع', type),
                _infoRow2(
                  Icons.location_city_rounded,
                  'المنطقة',
                  c['gov'] as String,
                ),
                _infoRow2(
                  Icons.access_time_rounded,
                  'أوقات العمل',
                  'الأحد - الخميس: 7ص - 11م',
                ),
                _infoRow2(Icons.today_rounded, 'الجمعة والسبت', '9ص - 2م'),
                const SizedBox(height: 20),
                _detailSectionTitle('🩺 الخدمات المتاحة'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: services
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withAlpha(12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: typeColor.withAlpha(40)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: typeColor,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                s,
                                style: TextStyle(
                                  color: typeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                _detailSectionTitle('🏢 المرافق'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _facilityChip('🅿️', 'موقف سيارات'),
                    _facilityChip('🕌', 'مصلى'),
                    _facilityChip('♿', 'ذوو الاحتياجات'),
                    _facilityChip('🚑', 'طوارئ'),
                    if (type != 'أولي') _facilityChip('💉', 'مختبر'),
                    if (type == 'تخصصي') _facilityChip('🔬', 'أجهزة متقدمة'),
                  ],
                ),
                const SizedBox(height: 24),
                _detailSectionTitle('⚡ إجراءات'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _actionBtn(
                        Icons.phone_rounded,
                        'اتصال',
                        typeColor,
                        () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn(
                        Icons.calendar_month_rounded,
                        'حجز موعد',
                        const Color(0xFF3B82F6),
                        () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn(
                        Icons.map_rounded,
                        'الموقع',
                        const Color(0xFFF59E0B),
                        () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPharmacyDetail(Map<String, dynamic> p) {
    HapticFeedback.mediumImpact();
    final dispRate = p['dispensingRate'] as int;
    final dispValue = p['dispensingValue'] as int;
    final hasInsurance = p['insurance'] as bool;
    final insuranceTypes = (p['insuranceTypes'] as List).cast<String>();
    final topMeds = (p['topMeds'] as List).cast<String>();
    final shortage = (p['shortage'] as List).cast<String>();
    final dispColor = dispRate >= 90
        ? const Color(0xFF10B981)
        : dispRate >= 75
        ? const Color(0xFFF59E0B)
        : Colors.redAccent;
    final medCategories = <String, List<String>>{
      'الأكثر صرفاً': topMeds,
      'أدوية مزمنة': ['ميتفورمين', 'أملوديبين', 'ليزينوبريل', 'ثايروكسين'],
      'مسكنات': ['باراسيتامول', 'إيبوبروفين', 'ديكلوفيناك'],
      'مضادات حيوية': ['أموكسيسيلين', 'أزيثروميسين', 'سيبروفلوكساسين'],
      'فيتامينات': ['فيتامين د', 'فيتامين ج', 'زنك', 'كالسيوم', 'أوميغا3'],
    };
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, ctrl) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('💊', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white38,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  p['address'] as String,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              _detailBadge(
                                p['gov'] as String,
                                const Color(0xFF10B981),
                              ),
                              if (hasInsurance)
                                _detailBadge(
                                  '🛡️ تأمين',
                                  const Color(0xFF3B82F6),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _detailSectionTitle('📈 نسبة الصرف'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'معدل الصرف',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      '$dispRate%',
                      style: TextStyle(
                        color: dispColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: dispRate / 100,
                    backgroundColor: Colors.white.withAlpha(12),
                    valueColor: AlwaysStoppedAnimation(dispColor),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money_rounded,
                      color: Colors.white38,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'إجمالي الصرف: ${(dispValue / 1000).toStringAsFixed(0)} ألف ريال',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (hasInsurance && insuranceTypes.isNotEmpty) ...[
                  _detailSectionTitle('🛡️ التأمين الصحي المقبول'),
                  const SizedBox(height: 10),
                  ...insuranceTypes.map(
                    (ins) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withAlpha(10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withAlpha(30),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shield_rounded,
                            color: Color(0xFF60A5FA),
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            ins,
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF10B981),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else if (!hasInsurance) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withAlpha(30)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'لا تقبل التأمين الصحي حالياً',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _detailSectionTitle('💊 مخزون الأدوية'),
                const SizedBox(height: 10),
                ...medCategories.entries.map(
                  (entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: Color(0xFF6EE7B7),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: entry.value
                            .map(
                              (med) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withAlpha(10),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withAlpha(35),
                                  ),
                                ),
                                child: Text(
                                  med,
                                  style: const TextStyle(
                                    color: Color(0xFF6EE7B7),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
                if (shortage.isNotEmpty) ...[
                  _detailSectionTitle('⚠️ نقص في المخزون'),
                  const SizedBox(height: 10),
                  ...shortage.map(
                    (s) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orangeAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            s,
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'نفد',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                _detailSectionTitle('⏰ أوقات العمل'),
                const SizedBox(height: 10),
                _infoRow2(Icons.wb_sunny_rounded, 'السبت - الخميس', '8ص - 11م'),
                _infoRow2(Icons.nights_stay_rounded, 'الجمعة', '2م - 11م'),
                const SizedBox(height: 24),
                _detailSectionTitle('⚡ إجراءات'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _actionBtn(
                        Icons.phone_rounded,
                        'اتصال',
                        const Color(0xFF10B981),
                        () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn(
                        Icons.medication_rounded,
                        'بحث دواء',
                        const Color(0xFF8B5CF6),
                        () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionBtn(
                        Icons.map_rounded,
                        'الموقع',
                        const Color(0xFFF59E0B),
                        () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Detail Helpers ────────────────────────
  Widget _detailBadge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withAlpha(60)),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );

  Widget _detailSectionTitle(String text) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 6),
      Container(height: 1, color: Colors.white.withAlpha(15)),
    ],
  );

  Widget _detailProgressBar(String label, int val, int total, Color color) {
    final rate = total > 0 ? (val / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const Spacer(),
            Text(
              '$val / $total',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${(rate * 100).toStringAsFixed(0)}%)',
              style: TextStyle(color: color.withAlpha(180), fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: rate,
            backgroundColor: Colors.white.withAlpha(12),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _statCell(String emoji, String value, String label, Color color) =>
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withAlpha(120),
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _infoRow2(IconData icon, String label, String value) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(5),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _actionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      onTap();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _facilityChip(String emoji, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(8),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withAlpha(15)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    ),
  );

  void _showFilterSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_city_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'تصفية حسب المنطقة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _govs.map((g) {
                  final sel = _govFilter == g;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _govFilter = g);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFF10B981).withAlpha(35)
                            : Colors.white.withAlpha(8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel
                              ? const Color(0xFF10B981)
                              : Colors.white.withAlpha(15),
                        ),
                      ),
                      child: Text(
                        g,
                        style: TextStyle(
                          color: sel ? const Color(0xFF10B981) : Colors.white70,
                          fontSize: 13,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
