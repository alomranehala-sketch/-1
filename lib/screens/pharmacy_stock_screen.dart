import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Pharmacy Stock Checker — فحص توفر الأدوية في الصيدليات
/// Check any pharmacy for medicine availability (public + private) in real-time
class PharmacyStockScreen extends StatefulWidget {
  const PharmacyStockScreen({super.key});
  @override
  State<PharmacyStockScreen> createState() => _PharmacyStockScreenState();
}

class _PharmacyStockScreenState extends State<PharmacyStockScreen> {
  final _searchCtrl = TextEditingController();
  bool _searching = false;
  bool _showResults = false;

  final _results = [
    _PharmacyResult(
      'صيدلية الشفاء',
      'عمّان — شارع الجامعة',
      true,
      'متوفر',
      2.5,
      '3.50 د.أ',
      true,
      4.5,
    ),
    _PharmacyResult(
      'صيدلية المستشفى الجامعي',
      'عمّان — الجبيهة',
      true,
      'متوفر',
      4.0,
      'مجاني (تأمين)',
      false,
      4.2,
    ),
    _PharmacyResult(
      'صيدلية فارمسي ون',
      'عمّان — عبدون',
      true,
      'آخر علبتين',
      6.5,
      '4.00 د.أ',
      true,
      4.7,
    ),
    _PharmacyResult(
      'صيدلية البشير',
      'عمّان — البشير',
      false,
      'نفذ',
      8.0,
      '-',
      false,
      3.9,
    ),
    _PharmacyResult(
      'صيدلية الحياة',
      'عمّان — ماركا',
      true,
      'متوفر',
      10.0,
      '3.25 د.أ',
      true,
      4.3,
    ),
  ];

  final _popularMeds = [
    'ميتفورمين',
    'أسبرين',
    'بنادول',
    'أموكسيسيلين',
    'أملوديبين',
    'لوسارتان',
    'أومبيرازول',
    'فيتامين D',
  ];

  void _search() {
    if (_searchCtrl.text.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _searching = true;
      _showResults = false;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _searching = false;
          _showResults = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'توفر الأدوية 💊',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildSearchSection()),
            if (_searching)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
            if (_showResults)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildPharmacyCard(_results[i]),
                  childCount: _results.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ابحث عن دواء',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'شوف أي صيدلية عندها الدواء متوفر — عام + خاص',
            style: TextStyle(color: AppColors.textLight, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withAlpha(40)),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'اكتب اسم الدواء...',
                hintStyle: TextStyle(
                  color: AppColors.textLight.withAlpha(150),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.accent,
                  ),
                  onPressed: () {},
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'أدوية شائعة:',
            style: TextStyle(color: AppColors.textMedium, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _popularMeds
                .map(
                  (m) => GestureDetector(
                    onTap: () {
                      _searchCtrl.text = m;
                      _search();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.border.withAlpha(40),
                        ),
                      ),
                      child: Text(
                        m,
                        style: const TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.search_rounded, size: 20),
              label: const Text(
                'ابحث في جميع الصيدليات',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyCard(_PharmacyResult r) {
    final availColor = r.available
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: r.available
              ? AppColors.border.withAlpha(30)
              : AppColors.error.withAlpha(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: availColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_pharmacy_rounded,
                  color: availColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r.address,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: availColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  r.status,
                  style: TextStyle(
                    color: availColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.attach_money_rounded,
                color: AppColors.textLight,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                r.price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.directions_car_rounded,
                color: AppColors.textLight,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${r.distanceKm} كم',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.star_rounded,
                color: const Color(0xFFF59E0B),
                size: 14,
              ),
              const SizedBox(width: 2),
              Text(
                '${r.rating}',
                style: const TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
            ],
          ),
          if (r.available) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (r.hasDelivery)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.delivery_dining_rounded, size: 16),
                      label: const Text(
                        'توصيل',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                if (r.hasDelivery) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_bag_rounded, size: 16),
                    label: const Text(
                      'احجز الدواء',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PharmacyResult {
  final String name, address, status, price;
  final bool available, hasDelivery;
  final double distanceKm, rating;
  const _PharmacyResult(
    this.name,
    this.address,
    this.available,
    this.status,
    this.distanceKm,
    this.price,
    this.hasDelivery,
    this.rating,
  );
}
