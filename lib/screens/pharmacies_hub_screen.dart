import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import 'pharmacy_stock_screen.dart';

/// Pharmacies Hub — مركز الصيدليات
/// Nearby pharmacies, medication availability, delivery, refills
class PharmaciesHubScreen extends StatefulWidget {
  const PharmaciesHubScreen({super.key});
  @override
  State<PharmaciesHubScreen> createState() => _PharmaciesHubScreenState();
}

class _PharmaciesHubScreenState extends State<PharmaciesHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _query = '';
  final _searchCtrl = TextEditingController();

  final _pharmacies = const <_Pharmacy>[
    _Pharmacy(
      'صيدلية الشفاء',
      'عمّان — شارع الجامعة',
      4.5,
      1.2,
      true,
      '24 ساعة',
      true,
      true,
    ),
    _Pharmacy(
      'صيدلية فارمسي ون',
      'عمّان — عبدون',
      4.7,
      2.5,
      true,
      '8 ص - 12 م',
      true,
      true,
    ),
    _Pharmacy(
      'صيدلية الحكمة',
      'عمّان — الشميساني',
      4.6,
      3.0,
      true,
      '8 ص - 11 م',
      true,
      false,
    ),
    _Pharmacy(
      'صيدلية البشير',
      'عمّان — وسط البلد',
      4.2,
      5.0,
      true,
      '24 ساعة',
      false,
      false,
    ),
    _Pharmacy(
      'صيدلية الحياة',
      'عمّان — خلدا',
      4.4,
      3.5,
      true,
      '8 ص - 10 م',
      true,
      true,
    ),
    _Pharmacy(
      'صيدلية الدواء',
      'إربد — شارع الجامعة',
      4.3,
      48.0,
      true,
      '8 ص - 10 م',
      false,
      false,
    ),
    _Pharmacy(
      'صيدلية النور',
      'الزرقاء — وسط البلد',
      4.1,
      25.0,
      true,
      '8 ص - 9 م',
      false,
      false,
    ),
    _Pharmacy(
      'صيدلية المؤمن',
      'عمّان — الجبيهة',
      4.5,
      4.0,
      false,
      'مغلق الآن',
      true,
      true,
    ),
    _Pharmacy(
      'صيدلية السلام',
      'عمّان — الدوار السابع',
      4.6,
      2.0,
      true,
      '24 ساعة',
      true,
      true,
    ),
    _Pharmacy(
      'صيدلية الأمل',
      'عمّان — طبربور',
      4.0,
      7.0,
      true,
      '8 ص - 10 م',
      false,
      false,
    ),
  ];

  final _refills = const <_Refill>[
    _Refill(
      'Metformin 500mg',
      'ميتفورمين',
      'أقراص — 30 حبة',
      '2025-07-15',
      true,
    ),
    _Refill(
      'Amlodipine 5mg',
      'أملوديبين',
      'أقراص — 30 حبة',
      '2025-07-20',
      true,
    ),
    _Refill(
      'Omeprazole 20mg',
      'أوميبرازول',
      'كبسول — 14 حبة',
      '2025-08-01',
      false,
    ),
    _Refill(
      'Atorvastatin 10mg',
      'أتورفاستاتين',
      'أقراص — 30 حبة',
      '2025-08-10',
      false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
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
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(8, topPad + 8, 16, 0),
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
                          'مركز الصيدليات 💊',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PharmacyStockScreen(),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_rounded,
                                size: 14,
                                color: Color(0xFF10B981),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'فحص توفر دواء',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  TabBar(
                    controller: _tabCtrl,
                    indicatorColor: AppColors.accent,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColors.accent,
                    unselectedLabelColor: AppColors.textLight,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Tajawal',
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Tajawal',
                    ),
                    tabs: const [
                      Tab(text: 'الصيدليات'),
                      Tab(text: 'إعادة الصرف'),
                      Tab(text: 'التوصيل'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildPharmaciesTab(),
                  _buildRefillTab(),
                  _buildDeliveryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 1: Nearby Pharmacies ──
  Widget _buildPharmaciesTab() {
    final filtered = _pharmacies.where((p) {
      if (_query.isEmpty) return true;
      return p.name.contains(_query) || p.address.contains(_query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
              hintText: 'ابحث عن صيدلية...',
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
        const SizedBox(height: 12),
        // Filter chips
        Row(
          children: [
            _filterTag('مفتوح الآن', const Color(0xFF10B981)),
            const SizedBox(width: 6),
            _filterTag('24 ساعة', const Color(0xFFF59E0B)),
            const SizedBox(width: 6),
            _filterTag('يوصّل', const Color(0xFF3B82F6)),
          ],
        ),
        const SizedBox(height: 12),
        ...filtered.map((p) => _buildPharmacyCard(p)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _filterTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPharmacyCard(_Pharmacy p) {
    return Container(
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_pharmacy_rounded,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: p.isOpen
                                ? const Color(0xFF10B981).withAlpha(15)
                                : const Color(0xFFEF4444).withAlpha(15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            p.isOpen ? 'مفتوح' : 'مغلق',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: p.isOpen
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.address,
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
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 14,
                color: Color(0xFFF59E0B),
              ),
              Text(
                ' ${p.rating}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.location_on_rounded,
                size: 14,
                color: Color(0xFF3B82F6),
              ),
              Text(
                ' ${p.distKm} كم',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: Color(0xFF8B5CF6),
              ),
              Flexible(
                child: Text(
                  ' ${p.hours}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ),
              const Spacer(),
              if (p.hasDelivery)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withAlpha(15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'توصيل 🚗',
                    style: TextStyle(fontSize: 9, color: Color(0xFF3B82F6)),
                  ),
                ),
            ],
          ),
          if (p.hasInsurance) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withAlpha(10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 12,
                    color: Color(0xFF6366F1),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'يقبل التأمين الصحي',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Tab 2: Refill Requests ──
  Widget _buildRefillTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'إعادة صرف الأدوية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'اطلب إعادة صرف أدويتك المزمنة بضغطة واحدة',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withAlpha(200),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _heroBadge('مرتبط بحكيم'),
                  const SizedBox(width: 6),
                  _heroBadge('وصفة إلكترونية'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'أدويتك المزمنة',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        ..._refills.map((r) => _buildRefillCard(r)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _heroBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRefillCard(_Refill r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: Color(0xFF6366F1),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.nameAr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  r.nameEn,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${r.form} — ينتهي: ${r.expiry}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ تم طلب إعادة صرف ${r.nameAr}'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: r.canRefill
                  ? const Color(0xFF6366F1)
                  : AppColors.surface,
              foregroundColor: r.canRefill ? Colors.white : AppColors.textLight,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              r.canRefill ? 'إعادة صرف' : 'مبكر',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Delivery ──
  Widget _buildDeliveryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF0EA5E9)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.delivery_dining_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'توصيل الأدوية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'اطلب أدويتك واحصل عليها حتى باب بيتك',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withAlpha(200),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Steps
        _buildDeliveryStep(
          1,
          'ارفع وصفتك',
          'صوّر الوصفة أو اختر من حكيم',
          Icons.camera_alt_rounded,
          const Color(0xFF6366F1),
        ),
        _buildDeliveryStep(
          2,
          'اختر الصيدلية',
          'قارن الأسعار والتوفر',
          Icons.compare_arrows_rounded,
          const Color(0xFF10B981),
        ),
        _buildDeliveryStep(
          3,
          'التوصيل لبابك',
          'خلال 45 دقيقة — عمّان',
          Icons.delivery_dining_rounded,
          const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 20),

        // Upload prescription button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📷 افتح الكاميرا لتصوير الوصفة...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.upload_file_rounded, size: 20),
            label: const Text(
              'ارفع وصفة طبية',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PharmacyStockScreen()),
            ),
            icon: const Icon(Icons.search_rounded, size: 18),
            label: const Text(
              'ابحث عن دواء وأطلبه',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3B82F6),
              side: const BorderSide(color: Color(0xFF3B82F6)),
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

  Widget _buildDeliveryStep(
    int num,
    String title,
    String desc,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(25)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$num',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: color, size: 24),
        ],
      ),
    );
  }
}

class _Pharmacy {
  final String name, address;
  final double rating, distKm;
  final bool isOpen;
  final String hours;
  final bool hasInsurance, hasDelivery;
  const _Pharmacy(
    this.name,
    this.address,
    this.rating,
    this.distKm,
    this.isOpen,
    this.hours,
    this.hasInsurance,
    this.hasDelivery,
  );
}

class _Refill {
  final String nameEn, nameAr, form, expiry;
  final bool canRefill;
  const _Refill(
    this.nameEn,
    this.nameAr,
    this.form,
    this.expiry,
    this.canRefill,
  );
}
