import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import 'hospital_detail_screen.dart';
import 'chat_screen.dart';

class MapTab extends StatefulWidget {
  final String? focusHospitalName;
  const MapTab({super.key, this.focusHospitalName});
  @override
  State<MapTab> createState() => MapTabState();
}

class MapTabState extends State<MapTab> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  Position? _userPosition;
  bool _loadingLocation = true;
  String? _locationError;

  int _selectedIndex = -1;

  final _searchController = TextEditingController();
  bool _searchFocused = false;
  String _searchQuery = '';

  late AnimationController _cardAnimController;
  late Animation<double> _cardSlide;

  StreamSubscription<Position>? _positionStream;

  static const LatLng _ammanCenter = LatLng(31.9539, 35.9106);

  final List<HospitalData> _hospitals = [
    HospitalData(
      name: 'مستشفى الأردن',
      location: const LatLng(31.9580, 35.8650),
      address: 'عمّان — الشميساني',
      phone: '06 560 7777',
      rating: 4.8,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'قلب', 'عظام', 'أطفال'],
      waitTime: 12,
    ),
    HospitalData(
      name: 'مستشفى الجامعة الأردنية',
      location: const LatLng(32.0194, 35.8744),
      address: 'عمّان — الجبيهة',
      phone: '06 535 5000',
      rating: 4.7,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'جراحة', 'نسائية', 'باطنية'],
      waitTime: 25,
    ),
    HospitalData(
      name: 'مدينة الحسين الطبية',
      location: const LatLng(31.9773, 35.8639),
      address: 'عمّان — الجبيهة',
      phone: '06 580 4804',
      rating: 4.6,
      availability: HospitalAvailability.busy,
      specialties: ['طوارئ', 'أورام', 'أعصاب', 'مسالك'],
      waitTime: 45,
    ),
    HospitalData(
      name: 'مستشفى البشير',
      location: const LatLng(31.9500, 35.9350),
      address: 'عمّان — أشرفية',
      phone: '06 477 1511',
      rating: 4.2,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'حروق', 'عيون', 'أنف وأذن'],
      waitTime: 30,
    ),
    HospitalData(
      name: 'مستشفى الأمير حمزة',
      location: const LatLng(31.9980, 35.8700),
      address: 'عمّان — ماركا الشمالية',
      phone: '06 503 9444',
      rating: 4.5,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'جلدية'],
      waitTime: 15,
    ),
    HospitalData(
      name: 'المركز العربي الطبي',
      location: const LatLng(31.9620, 35.8570),
      address: 'عمّان — جبل عمّان',
      phone: '06 592 1199',
      rating: 4.7,
      availability: HospitalAvailability.open,
      specialties: ['قلب', 'أوعية', 'جراحة تجميل'],
      waitTime: 8,
    ),
    HospitalData(
      name: 'مستشفى الخالدي',
      location: const LatLng(31.9530, 35.8900),
      address: 'عمّان — الشميساني',
      phone: '06 464 4281',
      rating: 4.5,
      availability: HospitalAvailability.busy,
      specialties: ['طوارئ', 'عظام', 'نسائية', 'أطفال'],
      waitTime: 35,
    ),
    HospitalData(
      name: 'مستشفى الإسراء',
      location: const LatLng(31.9420, 35.8700),
      address: 'عمّان — طريق المطار',
      phone: '06 500 0222',
      rating: 4.3,
      availability: HospitalAvailability.open,
      specialties: ['باطنية', 'جراحة عامة', 'أطفال'],
      waitTime: 20,
    ),
    HospitalData(
      name: 'مستشفى ابن الهيثم',
      location: const LatLng(31.9630, 35.9050),
      address: 'عمّان — جبل الحسين',
      phone: '06 568 8888',
      rating: 4.4,
      availability: HospitalAvailability.open,
      specialties: ['عيون', 'ليزك', 'شبكية'],
      waitTime: 10,
    ),
    HospitalData(
      name: 'مستشفى الاستقلال',
      location: const LatLng(31.9700, 35.9400),
      address: 'عمّان — أبو نصير',
      phone: '06 400 4040',
      rating: 4.2,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'أشعة', 'مختبر'],
      waitTime: 20,
    ),
    HospitalData(
      name: 'مستشفى الاستشاري',
      location: const LatLng(31.9450, 35.8800),
      address: 'عمّان — جبل عمّان',
      phone: '06 464 6464',
      rating: 4.6,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'قلب', 'جراحة', 'مسالك'],
      waitTime: 15,
    ),
    HospitalData(
      name: 'مستشفى التخصصي',
      location: const LatLng(31.9710, 35.8600),
      address: 'عمّان — الشميساني',
      phone: '06 568 1111',
      rating: 4.5,
      availability: HospitalAvailability.open,
      specialties: ['أورام', 'باطنية', 'تخدير', 'عناية مركزة'],
      waitTime: 18,
    ),
    HospitalData(
      name: 'مستشفى الإسلامي',
      location: const LatLng(31.9620, 35.9180),
      address: 'عمّان — عبدون',
      phone: '06 592 5111',
      rating: 4.4,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'قلب', 'عظام', 'أطفال'],
      waitTime: 22,
    ),
    HospitalData(
      name: 'مستشفى لوزميلا',
      location: const LatLng(31.9555, 35.9320),
      address: 'عمّان — جبل اللويبدة',
      phone: '06 462 0291',
      rating: 4.3,
      availability: HospitalAvailability.open,
      specialties: ['نسائية', 'توليد', 'أطفال'],
      waitTime: 12,
    ),
    HospitalData(
      name: 'مركز الحسين للسرطان',
      location: const LatLng(31.9680, 35.8550),
      address: 'عمّان — الجبيهة',
      phone: '06 530 0460',
      rating: 4.9,
      availability: HospitalAvailability.busy,
      specialties: ['أورام', 'علاج كيميائي', 'إشعاعي', 'زراعة نخاع'],
      waitTime: 40,
    ),
    HospitalData(
      name: 'مستشفى فرح',
      location: const LatLng(31.9370, 35.8600),
      address: 'عمّان — ضاحية الرشيد',
      phone: '06 501 0101',
      rating: 4.4,
      availability: HospitalAvailability.open,
      specialties: ['جراحة', 'باطنية', 'مختبر', 'أشعة'],
      waitTime: 14,
    ),
    HospitalData(
      name: 'مستشفى الأمير رشيد',
      location: const LatLng(31.9830, 35.9280),
      address: 'عمّان — بيادر وادي السير',
      phone: '06 581 3813',
      rating: 4.1,
      availability: HospitalAvailability.open,
      specialties: ['طب نفسي', 'أعصاب', 'تأهيل'],
      waitTime: 20,
    ),
    HospitalData(
      name: 'مستشفى الملكة علياء العسكري',
      location: const LatLng(31.9740, 35.8550),
      address: 'عمّان — ماركا',
      phone: '06 580 0800',
      rating: 4.3,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'جراحة', 'عظام', 'عناية مركزة'],
      waitTime: 25,
    ),
    HospitalData(
      name: 'مستشفى الأمل',
      location: const LatLng(31.9490, 35.8530),
      address: 'عمّان — ماركا الجنوبية',
      phone: '06 489 7777',
      rating: 4.0,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'جراحة'],
      waitTime: 18,
    ),
    HospitalData(
      name: 'المستشفى التركي',
      location: const LatLng(31.9290, 35.8980),
      address: 'عمّان — الجيزة',
      phone: '06 515 0015',
      rating: 4.3,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'جراحة', 'باطنية', 'أطفال'],
      waitTime: 15,
    ),
    HospitalData(
      name: 'مستشفى الملك عبدالله المؤسس',
      location: const LatLng(32.5413, 35.8510),
      address: 'إربد — الرمثا',
      phone: '02 709 3600',
      rating: 4.5,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'قلب', 'أورام', 'أعصاب'],
      waitTime: 22,
    ),
    HospitalData(
      name: 'مستشفى الأميرة بسمة',
      location: const LatLng(32.5555, 35.8500),
      address: 'إربد',
      phone: '02 724 5644',
      rating: 4.3,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'نسائية', 'أطفال', 'باطنية'],
      waitTime: 25,
    ),
    HospitalData(
      name: 'مستشفى الراهبات الوردية — إربد',
      location: const LatLng(32.5520, 35.8580),
      address: 'إربد — وسط البلد',
      phone: '02 727 2611',
      rating: 4.4,
      availability: HospitalAvailability.open,
      specialties: ['جراحة', 'نسائية', 'أطفال'],
      waitTime: 15,
    ),
    HospitalData(
      name: 'مستشفى ابن النفيس',
      location: const LatLng(32.5480, 35.8620),
      address: 'إربد',
      phone: '02 725 3121',
      rating: 4.2,
      availability: HospitalAvailability.open,
      specialties: ['باطنية', 'قلب', 'أشعة'],
      waitTime: 18,
    ),
    HospitalData(
      name: 'مستشفى الأمير فيصل',
      location: const LatLng(32.0700, 36.0940),
      address: 'الزرقاء',
      phone: '05 390 0220',
      rating: 4.2,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'جراحة', 'عظام'],
      waitTime: 30,
    ),
    HospitalData(
      name: 'مستشفى الزرقاء الحكومي الجديد',
      location: const LatLng(32.0750, 36.0800),
      address: 'الزرقاء — المدينة الجديدة',
      phone: '05 398 9898',
      rating: 4.0,
      availability: HospitalAvailability.busy,
      specialties: ['طوارئ', 'عيون', 'أنف وأذن', 'جلدية'],
      waitTime: 40,
    ),
    HospitalData(
      name: 'مستشفى الأمير هاشم',
      location: const LatLng(29.5270, 35.0060),
      address: 'العقبة',
      phone: '03 201 4111',
      rating: 4.3,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'جراحة', 'باطنية', 'أطفال'],
      waitTime: 15,
    ),
    HospitalData(
      name: 'مستشفى العقبة الدولي',
      location: const LatLng(29.5320, 35.0100),
      address: 'العقبة — المنطقة الاقتصادية',
      phone: '03 209 1111',
      rating: 4.1,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'قلب', 'عظام'],
      waitTime: 20,
    ),
    HospitalData(
      name: 'مستشفى الكرك الحكومي',
      location: const LatLng(31.1850, 35.7050),
      address: 'الكرك',
      phone: '03 235 2531',
      rating: 4.0,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'جراحة'],
      waitTime: 25,
    ),
    HospitalData(
      name: 'مستشفى السلط الحكومي الجديد',
      location: const LatLng(32.0400, 35.7300),
      address: 'السلط',
      phone: '05 355 9955',
      rating: 4.1,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'نسائية', 'أطفال'],
      waitTime: 20,
    ),
    HospitalData(
      name: 'مستشفى النديم',
      location: const LatLng(31.7180, 35.7930),
      address: 'مادبا',
      phone: '05 325 4711',
      rating: 4.0,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'جراحة', 'باطنية'],
      waitTime: 18,
    ),
    HospitalData(
      name: 'مستشفى جرش الحكومي',
      location: const LatLng(32.2750, 35.8970),
      address: 'جرش',
      phone: '02 634 0844',
      rating: 3.9,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'أطفال'],
      waitTime: 22,
    ),
    HospitalData(
      name: 'مستشفى الإيمان الحكومي',
      location: const LatLng(32.3330, 35.7510),
      address: 'عجلون',
      phone: '02 642 0031',
      rating: 3.8,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'جراحة'],
      waitTime: 25,
    ),
    HospitalData(
      name: 'مستشفى المفرق الحكومي',
      location: const LatLng(32.3430, 36.2080),
      address: 'المفرق',
      phone: '02 623 1841',
      rating: 3.8,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'جراحة', 'أطفال'],
      waitTime: 28,
    ),
    HospitalData(
      name: 'مستشفى الأميرة هيا',
      location: const LatLng(30.1950, 35.7340),
      address: 'معان',
      phone: '03 213 3313',
      rating: 3.7,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'جراحة'],
      waitTime: 20,
    ),
    HospitalData(
      name: 'مستشفى الطفيلة الحكومي',
      location: const LatLng(30.8370, 35.6040),
      address: 'الطفيلة',
      phone: '03 224 1071',
      rating: 3.7,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'نسائية'],
      waitTime: 20,
    ),
    // ═══ مستشفيات إضافية ═══
    HospitalData(
      name: 'مستشفى الأمير حسين بن عبدالله',
      location: const LatLng(31.9870, 35.8310),
      address: 'عمّان — السلط',
      phone: '05 355 4004',
      rating: 4.2,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'جراحة'],
      waitTime: 20,
    ),
    HospitalData(
      name: 'المستشفى الإيطالي',
      location: const LatLng(31.7200, 35.7950),
      address: 'الكرك',
      phone: '03 232 5323',
      rating: 4.1,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'جراحة', 'نسائية'],
      waitTime: 18,
    ),
    HospitalData(
      name: 'مستشفى الأميرة رحمة',
      location: const LatLng(32.5600, 35.8700),
      address: 'إربد',
      phone: '02 724 7247',
      rating: 4.0,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'أطفال', 'نسائية'],
      waitTime: 22,
    ),
    HospitalData(
      name: 'مستشفى الملك طلال',
      location: const LatLng(32.3510, 35.7500),
      address: 'المفرق',
      phone: '02 623 3655',
      rating: 3.9,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'عظام'],
      waitTime: 25,
    ),
    HospitalData(
      name: 'مستشفى الأمير زيد العسكري',
      location: const LatLng(31.9560, 35.9480),
      address: 'عمّان — الطفيلة',
      phone: '03 224 2666',
      rating: 4.0,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'جراحة', 'عظام'],
      waitTime: 15,
    ),
    HospitalData(
      name: 'مستشفى حمزة',
      location: const LatLng(32.0590, 36.0870),
      address: 'الزرقاء',
      phone: '05 398 6666',
      rating: 4.1,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'أطفال', 'نسائية'],
      waitTime: 20,
    ),
    HospitalData(
      name: 'مستشفى معاذ بن جبل',
      location: const LatLng(32.6200, 35.8300),
      address: 'إربد — الرمثا',
      phone: '02 720 1901',
      rating: 3.8,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية'],
      waitTime: 25,
    ),
    HospitalData(
      name: 'مستشفى الأمير علي العسكري',
      location: const LatLng(31.1820, 35.7100),
      address: 'الكرك',
      phone: '03 235 1616',
      rating: 4.0,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'جراحة', 'باطنية', 'عظام'],
      waitTime: 22,
    ),
    HospitalData(
      name: 'مستشفى الأميرة سلمى',
      location: const LatLng(30.2000, 35.7400),
      address: 'معان',
      phone: '03 213 7777',
      rating: 3.7,
      availability: HospitalAvailability.open,
      specialties: ['نسائية', 'أطفال', 'توليد'],
      waitTime: 18,
    ),
    HospitalData(
      name: 'المركز الطبي العربي',
      location: const LatLng(31.9560, 35.9100),
      address: 'عمّان — وسط البلد',
      phone: '06 464 6015',
      rating: 4.3,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'قلب', 'جراحة', 'عيون'],
      waitTime: 15,
    ),
    HospitalData(
      name: 'مستشفى الحياة',
      location: const LatLng(31.9430, 35.8750),
      address: 'عمّان — طبربور',
      phone: '06 505 5055',
      rating: 4.2,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'مختبر', 'أشعة'],
      waitTime: 12,
    ),
    HospitalData(
      name: 'مستشفى العبدلي',
      location: const LatLng(31.9590, 35.9070),
      address: 'عمّان — العبدلي',
      phone: '06 560 2002',
      rating: 4.5,
      availability: HospitalAvailability.open,
      specialties: ['جراحة تجميل', 'جلدية', 'ليزر', 'أسنان'],
      waitTime: 10,
    ),
    HospitalData(
      name: 'مستشفى غور الصافي',
      location: const LatLng(31.0360, 35.4600),
      address: 'غور الصافي',
      phone: '03 237 1111',
      rating: 3.6,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية'],
      waitTime: 30,
    ),
    HospitalData(
      name: 'مستشفى الأميرة إيمان',
      location: const LatLng(32.3300, 35.8100),
      address: 'عجلون',
      phone: '02 642 2222',
      rating: 3.8,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'نسائية', 'أطفال'],
      waitTime: 22,
    ),
    HospitalData(
      name: 'مستشفى الرمثا الحكومي',
      location: const LatLng(32.6180, 36.0100),
      address: 'الرمثا',
      phone: '02 710 1270',
      rating: 3.9,
      availability: HospitalAvailability.open,
      specialties: ['طوارئ', 'باطنية', 'جراحة', 'أطفال'],
      waitTime: 20,
    ),
  ];

  List<HospitalData> get _sortedHospitals {
    if (_userPosition == null) return _filteredHospitals;
    final list = List<HospitalData>.from(_filteredHospitals);
    list.sort(
      (a, b) => _distanceKm(a.location).compareTo(_distanceKm(b.location)),
    );
    return list;
  }

  List<HospitalData> get _filteredHospitals {
    if (_searchQuery.isEmpty) return _hospitals;
    return _hospitals
        .where(
          (h) =>
              h.name.contains(_searchQuery) ||
              h.address.contains(_searchQuery) ||
              h.specialties.any((s) => s.contains(_searchQuery)),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cardSlide = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOutCubic),
    );
    _getUserLocation();
    if (widget.focusHospitalName != null) {
      final idx = _hospitals.indexWhere(
        (h) => h.name == widget.focusHospitalName,
      );
      if (idx >= 0) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _selectHospital(idx),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _positionStream?.cancel();
    _cardAnimController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _loadingLocation = false;
            _locationError = 'يرجى تفعيل خدمات الموقع';
          });
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          _userPosition = position;
          _loadingLocation = false;
        });
      }
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 50,
            ),
          ).listen((pos) {
            if (mounted) {
              setState(() => _userPosition = pos);
            }
          });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
          _locationError = 'تعذر تحديد موقعك';
        });
      }
    }
  }

  double _distanceKm(LatLng target) {
    if (_userPosition == null) return 0;
    return Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          target.latitude,
          target.longitude,
        ) /
        1000;
  }

  int _estimateMins(double km) => (km / 30 * 60).round().clamp(1, 999);

  void _selectHospital(int index) {
    HapticFeedback.selectionClick();
    final h = _hospitals[index];
    setState(() {
      _selectedIndex = index;
      _searchFocused = false;
    });
    FocusManager.instance.primaryFocus?.unfocus();
    _cardAnimController.forward(from: 0);
    _mapController.move(h.location, 15);
  }

  void _deselectHospital() {
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = -1);
    _cardAnimController.reverse();
    if (_userPosition != null) {
      _mapController.move(
        LatLng(_userPosition!.latitude, _userPosition!.longitude),
        13,
      );
    }
  }

  void focusOnHospital(String name) {
    final idx = _hospitals.indexWhere((h) => h.name == name);
    if (idx >= 0) _selectHospital(idx);
  }

  Future<void> _startNavigation(LatLng dest) async {
    HapticFeedback.heavyImpact();
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${dest.latitude},${dest.longitude}&travelmode=driving';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callHospital(String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openHospitalDetail(HospitalData h) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, _) =>
            HospitalDetailScreen(hospital: h),
        transitionsBuilder: (context, anim, _, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                ),
            child: FadeTransition(opacity: anim, child: child),
          );
        },
      ),
    );
  }

  void _openChat(HospitalData h) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(hospitalName: h.name, hospitalPhone: h.phone),
      ),
    );
  }

  HospitalData? getNearestHospital() {
    if (_userPosition == null) return _hospitals.firstOrNull;
    final sorted = _sortedHospitals;
    return sorted.isNotEmpty ? sorted.first : null;
  }

  String _availabilityText(HospitalAvailability a) {
    switch (a) {
      case HospitalAvailability.open:
        return 'مفتوح';
      case HospitalAvailability.busy:
        return 'مزدحم';
      case HospitalAvailability.closed:
        return 'مغلق';
    }
  }

  Color _availabilityColor(HospitalAvailability a) {
    switch (a) {
      case HospitalAvailability.open:
        return AppColors.success;
      case HospitalAvailability.busy:
        return AppColors.warning;
      case HospitalAvailability.closed:
        return AppColors.error;
    }
  }

  IconData _availabilityIcon(HospitalAvailability a) {
    switch (a) {
      case HospitalAvailability.open:
        return Icons.check_circle_rounded;
      case HospitalAvailability.busy:
        return Icons.watch_later_rounded;
      case HospitalAvailability.closed:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userPosition != null
                    ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
                    : _ammanCenter,
                initialZoom: 13,
                onTap: (_, _) {
                  if (_selectedIndex >= 0) _deselectHospital();
                  if (_searchFocused) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() => _searchFocused = false);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.teryaq.health',
                ),
                if (_userPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          _userPosition!.latitude,
                          _userPosition!.longitude,
                        ),
                        width: 30,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withAlpha(100),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: _hospitals.asMap().entries.map((e) {
                    final i = e.key;
                    final h = e.value;
                    final isSelected = i == _selectedIndex;
                    return Marker(
                      point: h.location,
                      width: isSelected ? 48 : 40,
                      height: isSelected ? 48 : 40,
                      child: GestureDetector(
                        onTap: () => _selectHospital(i),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isSelected
                                  ? [
                                      const Color(0xFF10B981),
                                      const Color(0xFF059669),
                                    ]
                                  : h.availability == HospitalAvailability.busy
                                  ? [
                                      const Color(0xFFF59E0B),
                                      const Color(0xFFD97706),
                                    ]
                                  : h.availability ==
                                        HospitalAvailability.closed
                                  ? [
                                      const Color(0xFF6B7280),
                                      const Color(0xFF4B5563),
                                    ]
                                  : [
                                      const Color(0xFFEF4444),
                                      const Color(0xFFDC2626),
                                    ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isSelected
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFEF4444))
                                        .withAlpha(80),
                                blurRadius: isSelected ? 16 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.local_hospital_rounded,
                            color: Colors.white,
                            size: isSelected ? 22 : 18,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            Positioned(
              top: topPad + 10,
              left: 16,
              right: 16,
              child: _buildSearchBar(),
            ),
            Positioned(
              top: topPad + 70,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildGpsBadge(),
                  const SizedBox(height: 8),
                  _buildCountBadge(),
                ],
              ),
            ),
            Positioned(
              bottom: _selectedIndex >= 0 ? 300 : 160,
              right: 16,
              child: _buildMapControls(),
            ),
            if (_selectedIndex >= 0)
              _buildSelectedCard(bottomPad)
            else
              _buildHospitalDrawer(bottomPad),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_searchFocused ? 16 : 28),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  _searchFocused
                      ? Icons.search_rounded
                      : Icons.local_hospital_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    onTap: () => setState(() => _searchFocused = true),
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن مستشفى أو تخصص...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textLight,
                    ),
                  ),
              ],
            ),
          ),
          if (_searchFocused && _searchQuery.isNotEmpty) ...[
            const Divider(height: 1),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredHospitals.length,
                itemBuilder: (_, i) {
                  final h = _filteredHospitals[i];
                  final dist = _userPosition != null
                      ? _distanceKm(h.location)
                      : null;
                  final origIdx = _hospitals.indexOf(h);
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.local_hospital_rounded,
                      size: 18,
                      color: _availabilityColor(h.availability),
                    ),
                    title: Text(
                      h.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${h.address}${dist != null ? " • ${dist.toStringAsFixed(1)} كم" : ""}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _availabilityColor(h.availability).withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _availabilityText(h.availability),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _availabilityColor(h.availability),
                        ),
                      ),
                    ),
                    onTap: () {
                      _selectHospital(origIdx);
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _searchFocused = false;
                      });
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGpsBadge() {
    if (_loadingLocation) {
      return _badge(
        child: const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }
    if (_locationError != null) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _loadingLocation = true;
            _locationError = null;
          });
          _getUserLocation();
        },
        child: _badge(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.gps_off_rounded,
                size: 14,
                color: AppColors.warning,
              ),
              const SizedBox(width: 4),
              Text(
                _locationError!,
                style: const TextStyle(fontSize: 10, color: AppColors.warning),
              ),
            ],
          ),
        ),
      );
    }
    return _badge(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'GPS نشط',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge() => _badge(
    color: AppColors.primary,
    child: Text(
      '🏥 ${_filteredHospitals.length} مستشفى',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 10,
      ),
    ),
  );

  Widget _badge({required Widget child, Color? color}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: AppShadows.card,
    ),
    child: child,
  );

  Widget _buildMapControls() {
    return Column(
      children: [
        _mapBtn(Icons.my_location_rounded, () {
          if (_userPosition != null) {
            _mapController.move(
              LatLng(_userPosition!.latitude, _userPosition!.longitude),
              15,
            );
          }
        }),
        const SizedBox(height: 8),
        _mapBtn(Icons.add_rounded, () {
          final z = _mapController.camera.zoom;
          _mapController.move(_mapController.camera.center, z + 1);
        }),
        const SizedBox(height: 8),
        _mapBtn(Icons.remove_rounded, () {
          final z = _mapController.camera.zoom;
          _mapController.move(_mapController.camera.center, z - 1);
        }),
      ],
    );
  }

  Widget _mapBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      onTap();
    },
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border.withAlpha(30)),
      ),
      child: Icon(icon, color: AppColors.textDark, size: 20),
    ),
  );

  Widget _buildHospitalDrawer(double bottomPad) {
    final hospitals = _sortedHospitals;
    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.10,
      maxChildSize: 0.55,
      snap: true,
      snapSizes: const [0.18, 0.40, 0.55],
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: AppShadows.elevated,
        ),
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.zero,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'المستشفيات القريبة',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'الأقرب أولاً',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 88,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: min(hospitals.length, 6),
                itemBuilder: (_, i) => _buildHospitalChip(hospitals[i], i),
              ),
            ),
            const Divider(height: 20),
            ...hospitals.asMap().entries.map(
              (e) => _buildHospitalListTile(e.value, e.key),
            ),
            SizedBox(height: bottomPad + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalChip(HospitalData h, int displayIndex) {
    final dist = _userPosition != null ? _distanceKm(h.location) : null;
    final origIdx = _hospitals.indexOf(h);
    return GestureDetector(
      onTap: () => _selectHospital(origIdx),
      child: Container(
        width: 170,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withAlpha(60)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    h.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _availabilityColor(h.availability),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  '${h.rating}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                  ),
                ),
                if (dist != null) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.directions_car_rounded,
                    size: 11,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${dist.toStringAsFixed(1)} كم',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  _availabilityIcon(h.availability),
                  size: 10,
                  color: _availabilityColor(h.availability),
                ),
                const SizedBox(width: 3),
                Text(
                  _availabilityText(h.availability),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _availabilityColor(h.availability),
                  ),
                ),
                if (h.availability != HospitalAvailability.closed) ...[
                  const SizedBox(width: 6),
                  Text(
                    '⏱ ${h.waitTime} د',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalListTile(HospitalData h, int displayIndex) {
    final dist = _userPosition != null ? _distanceKm(h.location) : null;
    final time = dist != null ? _estimateMins(dist) : null;
    final origIdx = _hospitals.indexOf(h);
    return InkWell(
      onTap: () => _selectHospital(origIdx),
      onLongPress: () => _openHospitalDetail(h),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _availabilityColor(h.availability).withAlpha(12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.local_hospital_rounded,
                color: _availabilityColor(h.availability),
                size: 22,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    h.address,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: h.specialties
                        .take(3)
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(10),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${h.rating}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (dist != null)
                  Text(
                    '${dist.toStringAsFixed(1)} كم',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                if (time != null)
                  Text(
                    '$time د بالسيارة',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textLight,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _availabilityColor(h.availability).withAlpha(12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _availabilityIcon(h.availability),
                        size: 10,
                        color: _availabilityColor(h.availability),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _availabilityText(h.availability),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _availabilityColor(h.availability),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedCard(double bottomPad) {
    final h = _hospitals[_selectedIndex];
    final dist = _userPosition != null ? _distanceKm(h.location) : null;
    final time = dist != null ? _estimateMins(dist) : null;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _cardSlide,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, 300 * _cardSlide.value),
          child: child,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 14, 16, bottomPad + 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(12),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      color: AppColors.primary,
                      size: 26,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                h.address,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textLight,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _availabilityColor(
                                  h.availability,
                                ).withAlpha(15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: _availabilityColor(h.availability),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _availabilityText(h.availability),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: _availabilityColor(h.availability),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _deselectHospital,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem(
                      Icons.star_rounded,
                      '${h.rating}',
                      'التقييم',
                      Colors.amber,
                    ),
                    _divider(),
                    _statItem(
                      Icons.directions_car_rounded,
                      dist != null ? '${dist.toStringAsFixed(1)} كم' : '—',
                      'المسافة',
                      AppColors.info,
                    ),
                    _divider(),
                    _statItem(
                      Icons.access_time_rounded,
                      time != null ? '$time د' : '—',
                      'وقت الوصول',
                      AppColors.primary,
                    ),
                    _divider(),
                    _statItem(
                      Icons.watch_later_rounded,
                      h.availability != HospitalAvailability.closed
                          ? '${h.waitTime} د'
                          : '—',
                      'الانتظار',
                      _availabilityColor(h.availability),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 26,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: h.specialties
                      .map(
                        (s) => Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(10),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withAlpha(20),
                            ),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => _openHospitalDetail(h),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(50),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'تفاصيل وحجز',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _squareAction(
                    Icons.chat_bubble_rounded,
                    const Color(0xFF10B981),
                    () => _openChat(h),
                  ),
                  const SizedBox(width: 8),
                  _squareAction(
                    Icons.phone_rounded,
                    AppColors.success,
                    () => _callHospital(h.phone),
                  ),
                  const SizedBox(width: 8),
                  _squareAction(
                    Icons.navigation_rounded,
                    AppColors.info,
                    () => _startNavigation(h.location),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color color) =>
      Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.textLight),
          ),
        ],
      );

  Widget _divider() =>
      Container(width: 1, height: 30, color: AppColors.border.withAlpha(60));

  Widget _squareAction(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withAlpha(12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(30)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      );
}

enum HospitalAvailability { open, busy, closed }

class HospitalData {
  final String name;
  final LatLng location;
  final String address;
  final String phone;
  final double rating;
  final HospitalAvailability availability;
  final List<String> specialties;
  final int waitTime;
  const HospitalData({
    required this.name,
    required this.location,
    required this.address,
    required this.phone,
    required this.rating,
    required this.availability,
    required this.specialties,
    required this.waitTime,
  });
}
