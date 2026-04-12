import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Smart Unified Booking — الحجز الذكي الموحد
/// Search any service → shows all options (public+private) with prices, wait times, distance
/// AI suggests best option
class SmartBookingScreen extends StatefulWidget {
  const SmartBookingScreen({super.key});
  @override
  State<SmartBookingScreen> createState() => _SmartBookingScreenState();
}

class _SmartBookingScreenState extends State<SmartBookingScreen>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _selectedSpec = '';
  String _selectedGov = '';
  String _urgency = 'عادي';
  bool _searching = false;
  bool _showResults = false;
  bool _showAiSuggestion = true;
  late AnimationController _shimmerCtrl;

  final _specialties = [
    'طب عام',
    'قلب',
    'عظام',
    'أسنان',
    'عيون',
    'جلدية',
    'أطفال',
    'نسائية',
    'مسالك بولية',
    'أعصاب',
    'باطنية',
    'جراحة',
    'أنف وأذن',
    'تحاليل مخبرية',
    'أشعة',
    'علاج طبيعي',
  ];

  final _governorates = [
    'عمّان',
    'إربد',
    'الزرقاء',
    'العقبة',
    'السلط',
    'المفرق',
    'جرش',
    'عجلون',
    'مادبا',
    'الكرك',
    'الطفيلة',
    'معان',
  ];

  // Demo results
  final List<_BookingResult> _results = [
    _BookingResult(
      'مستشفى الجامعة الأردنية',
      'عام',
      'عمّان',
      4.7,
      'مجاني',
      45,
      15,
      true,
      'أقرب خيار مجاني — انتظار متوسط',
    ),
    _BookingResult(
      'مستشفى الأردن',
      'خاص',
      'عمّان',
      4.9,
      '35 د.أ',
      5,
      12,
      false,
      'أقل انتظار — 5 دقائق فقط',
    ),
    _BookingResult(
      'مستشفى البشير',
      'عام',
      'عمّان',
      4.3,
      'مجاني',
      90,
      25,
      true,
      '',
    ),
    _BookingResult(
      'مستشفى العبدلي',
      'خاص',
      'عمّان',
      4.8,
      '50 د.أ',
      10,
      8,
      false,
      '',
    ),
    _BookingResult(
      'مستشفى الملك المؤسس',
      'عام',
      'عمّان',
      4.5,
      'مجاني',
      60,
      30,
      true,
      '',
    ),
    _BookingResult(
      'مستشفى الإسراء',
      'خاص',
      'عمّان',
      4.6,
      '25 د.أ',
      15,
      20,
      false,
      '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _doSearch() {
    HapticFeedback.mediumImpact();
    setState(() {
      _searching = true;
      _showResults = false;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _searching = false;
          _showResults = true;
        });
      }
    });
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
                'الحجز الذكي الموحد',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildSearchSection()),
            if (_searching) SliverToBoxAdapter(child: _buildLoadingShimmer()),
            if (_showResults && _showAiSuggestion)
              SliverToBoxAdapter(child: _buildAiSuggestion()),
            if (_showResults) SliverToBoxAdapter(child: _buildResultsHeader()),
            if (_showResults)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildResultCard(_results[i], i),
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
            'ابحث عن خدمة صحية',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'نبحث لك في جميع مستشفيات الأردن — عام وخاص',
            style: TextStyle(color: AppColors.textLight, fontSize: 12),
          ),
          const SizedBox(height: 16),
          // Search field
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withAlpha(40)),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'دكتور قلب، تحليل سكر، عملية...',
                hintStyle: TextStyle(
                  color: AppColors.textLight.withAlpha(150),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
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
          // Specialty chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _specialties.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final selected = _selectedSpec == _specialties[i];
                return GestureDetector(
                  onTap: () => setState(
                    () => _selectedSpec = selected ? '' : _specialties[i],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.border.withAlpha(60),
                      ),
                    ),
                    child: Text(
                      _specialties[i],
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textMedium,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Governorate + Urgency
          Row(
            children: [
              Expanded(
                child: _dropdown(
                  'المحافظة',
                  _selectedGov.isEmpty ? null : _selectedGov,
                  _governorates,
                  (v) => setState(() => _selectedGov = v ?? ''),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dropdown('الاستعجال', _urgency, [
                  'عادي',
                  'مستعجل',
                  'طوارئ',
                ], (v) => setState(() => _urgency = v ?? 'عادي')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _doSearch,
              icon: const Icon(Icons.search_rounded, size: 20),
              label: const Text(
                'ابحث في الكل — عام + خاص',
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

  Widget _dropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withAlpha(40)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: const TextStyle(color: AppColors.textLight, fontSize: 12),
          ),
          isExpanded: true,
          dropdownColor: AppColors.surface,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Tajawal',
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          3,
          (i) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _shimmerCtrl,
                builder: (_, _) => LinearProgressIndicator(
                  value: null,
                  backgroundColor: AppColors.border.withAlpha(30),
                  color: AppColors.primary.withAlpha(60),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiSuggestion() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF6366F1)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'اقتراح ترياق الذكي 🤖',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showAiSuggestion = false),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white54,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '💡 "روح على مستشفى الجامعة — مجاني وانتظار 45 دقيقة. أو مستشفى الأردن بـ35 دينار وتنتظر 5 دقائق بس. الأفضل حسب حالتك: الجامعة لأنها حالة عادية."',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _aiActionBtn(
                'احجز الأفضل',
                Icons.check_rounded,
                AppColors.success,
              ),
              const SizedBox(width: 8),
              _aiActionBtn(
                'قارن أكثر',
                Icons.compare_arrows_rounded,
                AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _aiActionBtn(String label, IconData icon, Color color) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withAlpha(30),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Text(
            '${_results.length} نتيجة',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          _filterChip('الأقرب', true),
          const SizedBox(width: 6),
          _filterChip('الأرخص', false),
          const SizedBox(width: 6),
          _filterChip('الأقل انتظاراً', false),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withAlpha(30) : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected
              ? AppColors.primary.withAlpha(60)
              : AppColors.border.withAlpha(40),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.primary : AppColors.textLight,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildResultCard(_BookingResult r, int index) {
    final isPublic = r.type == 'عام';
    final typeColor = isPublic
        ? const Color(0xFF10B981)
        : const Color(0xFF6366F1);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: index == 0
              ? AppColors.primary.withAlpha(60)
              : AppColors.border.withAlpha(30),
          width: index == 0 ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPublic
                      ? Icons.account_balance_rounded
                      : Icons.local_hospital_rounded,
                  color: typeColor,
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
                    Row(
                      children: [
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
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          r.location,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 11,
                          ),
                        ),
                      ],
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
                  color: typeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  r.type,
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _infoChip(
                Icons.attach_money_rounded,
                r.price,
                const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              _infoChip(
                Icons.access_time_rounded,
                '${r.waitMinutes} دقيقة',
                const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              _infoChip(
                Icons.directions_car_rounded,
                '${r.distanceKm} كم',
                const Color(0xFF3B82F6),
              ),
            ],
          ),
          if (r.aiNote.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      r.aiNote,
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showBookingSheet(r);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: index == 0
                    ? AppColors.primary
                    : AppColors.surface,
                foregroundColor: index == 0 ? Colors.white : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: index == 0
                      ? BorderSide.none
                      : const BorderSide(color: AppColors.primary),
                ),
                elevation: 0,
              ),
              child: Text(
                index == 0 ? 'احجز الآن — الخيار الأفضل' : 'احجز',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingSheet(_BookingResult r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تأكيد الحجز في ${r.name}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'السعر: ${r.price} | الانتظار: ${r.waitMinutes} دقيقة',
              style: const TextStyle(color: AppColors.textMedium, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showBookingSuccess();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'تأكيد الحجز',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showBookingSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تم الحجز بنجاح! ✅',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ستصلك رسالة تأكيد على هاتفك',
              style: TextStyle(color: AppColors.textMedium, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingResult {
  final String name, type, location, price, aiNote;
  final double rating;
  final int waitMinutes, distanceKm;
  final bool isPublic;
  const _BookingResult(
    this.name,
    this.type,
    this.location,
    this.rating,
    this.price,
    this.waitMinutes,
    this.distanceKm,
    this.isPublic,
    this.aiNote,
  );
}
