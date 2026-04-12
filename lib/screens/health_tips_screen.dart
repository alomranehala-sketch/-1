import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../services/api_service.dart';

// ═══════════════════════════════════════════════════════════════
//  TERYAQ SMART HEALTH — Daily Health Tips Screen
//  Personalized health advice based on user's conditions
//  Covers: chronic diseases, medications, labs, seasonal
// ═══════════════════════════════════════════════════════════════

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});
  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategory = 0;
  bool _loading = true;
  Map<String, dynamic> _profile = {};
  // ignore: unused_field
  Map<String, dynamic> _record = {};

  final _categories = const [
    _TipCategory('🌟', 'مخصص لك', Color(0xFF6366F1)),
    _TipCategory('❤️', 'القلب', Color(0xFFEF4444)),
    _TipCategory('🩸', 'السكري', Color(0xFFF59E0B)),
    _TipCategory('🧠', 'الصحة النفسية', Color(0xFF8B5CF6)),
    _TipCategory('🥗', 'التغذية', Color(0xFF10B981)),
    _TipCategory('🏃', 'النشاط', Color(0xFF3B82F6)),
    _TipCategory('💊', 'الأدوية', Color(0xFFEC4899)),
    _TipCategory('🌡️', 'موسمي', Color(0xFF06B6D4)),
  ];

  final _allTips = <_Tip>[
    // Personalized
    _Tip(
      '🩺',
      'راجع ضغطك اليوم',
      'مرضى السكري عندهم ضعف خطر الإصابة بضغط الدم. قيس ضغطك الصباحي قبل تناول أي دواء.',
      'سكري',
      'شخصي',
      const Color(0xFFF59E0B),
      '2 دقيقة',
      true,
    ),
    _Tip(
      '💧',
      'اشرب 8 أكواب مياه',
      'الجسم المرطب يتحكم بالسكر أفضل بنسبة 15%. تجنب المشروبات السكرية وحافظ على ماء جسمك.',
      'سكري',
      'شخصي',
      const Color(0xFF3B82F6),
      '5 دقائق',
      false,
    ),
    _Tip(
      '🦶',
      'افحص قدميك يومياً',
      'تفقد قدميك كل يوم للكشف عن أي احمرار أو تورم أو جرح — من أهم عادات مريض السكري.',
      'سكري',
      'شخصي',
      const Color(0xFF10B981),
      '3 دقائق',
      false,
    ),
    // Heart
    _Tip(
      '❤️',
      'المشي 30 دقيقة يومياً',
      'المشي المنتظم يخفض خطر أمراض القلب بـ 30%. ابدأ بخطوات بسيطة وارفع الوتيرة تدريجياً.',
      'قلب',
      'قلب',
      const Color(0xFFEF4444),
      '30 دقيقة',
      false,
    ),
    _Tip(
      '🧂',
      'قلل الملح في وجباتك',
      'كل ملعقة صغيرة زيادة من الملح ترفع ضغط الدم. استخدم الأعشاب والليمون بدلاً من الملح.',
      'قلب',
      'قلب',
      const Color(0xFFEF4444),
      '10 دقائق',
      false,
    ),
    _Tip(
      '🐟',
      'تناول السمك مرتين أسبوعياً',
      'أوميغا 3 في السمك تحمي شرايينك وتقلل الالتهابات. السردين والتونة والسلمون خيارات ممتازة.',
      'قلب',
      'قلب',
      const Color(0xFFEF4444),
      '20 دقيقة',
      false,
    ),
    // Diabetes
    _Tip(
      '🥗',
      'ابدأ وجبتك بالخضار',
      'تناول الخضار أولاً يبطئ امتصاص السكر ويخفض ارتفاع الجلوكوز بعد الأكل بنسبة 20%.',
      'سكري',
      'سكري',
      const Color(0xFFF59E0B),
      '0 دقيقة',
      false,
    ),
    _Tip(
      '⏱️',
      'الوجبات على مواعيد ثابتة',
      'تناول طعامك بأوقات منتظمة يساعد جسمك على ضبط الإنسولين ويمنع ارتفاع وانخفاض السكر المفاجئ.',
      'سكري',
      'سكري',
      const Color(0xFFF59E0B),
      '5 دقائق',
      false,
    ),
    // Mental Health
    _Tip(
      '😴',
      'نم 7-8 ساعات',
      'قلة النوم ترفع هرمون التوتر وتضعف جهاز المناعة. حافظ على موعد نوم ثابت كل يوم.',
      'صحة نفسية',
      'نفسي',
      const Color(0xFF8B5CF6),
      '8 ساعات',
      false,
    ),
    _Tip(
      '🧘',
      '10 دقائق تأمل صباحي',
      'التأمل يخفض هرمون الكورتيزول ويحسن التركيز. جرب تطبيق تأمل موجّه أو فقط تنفس بعمق.',
      'صحة نفسية',
      'نفسي',
      const Color(0xFF8B5CF6),
      '10 دقائق',
      false,
    ),
    // Nutrition
    _Tip(
      '🍎',
      'فاكهة واحدة في وجبة الإفطار',
      'الفاكهة صباحاً تمنحك طاقة طبيعية وألياف تقاوم الجوع حتى الغداء. تجنب العصائر المحلاة.',
      'تغذية',
      'تغذية',
      const Color(0xFF10B981),
      '5 دقائق',
      false,
    ),
    _Tip(
      '🥜',
      'حفنة مكسرات كوجبة خفيفة',
      'المكسرات غنية بالدهون الصحية والبروتين وتقلل الشعور بالجوع. كمية صغيرة تكفي — 30 جرام.',
      'تغذية',
      'تغذية',
      const Color(0xFF10B981),
      '2 دقيقة',
      false,
    ),
    // Activity
    _Tip(
      '🚶',
      'استبدل المصعد بالسلم',
      'كل 10 دقائق مشي إضافي تحرق 50 سعرة. الطابقين بالسلم = 200 خطوة صحية.',
      'نشاط',
      'نشاط',
      const Color(0xFF3B82F6),
      '5 دقائق',
      false,
    ),
    _Tip(
      '💪',
      'تمارين تقوية 3 مرات أسبوعياً',
      'بناء العضلات يحسن حساسية الإنسولين ويقلل دهون البطن. مقاومة الجسم بدون أثقال كافية للبداية.',
      'نشاط',
      'نشاط',
      const Color(0xFF3B82F6),
      '20 دقيقة',
      false,
    ),
    // Medications
    _Tip(
      '⏰',
      'خذ دوائك في نفس الوقت',
      'الدقة في مواعيد الأدوية تحافظ على مستوى ثابت في الدم. ضع منبهاً يومياً.',
      'أدوية',
      'أدوية',
      const Color(0xFFEC4899),
      '1 دقيقة',
      false,
    ),
    _Tip(
      '📋',
      'لا تتوقف عن الدواء بدون رأي الطبيب',
      'قطع الدواء فجأة (خاصة ضغط الدم والسكر والقلب) قد يسبب مضاعفات خطيرة. راجع طبيبك دوماً.',
      'أدوية',
      'أدوية',
      const Color(0xFFEC4899),
      '5 دقائق',
      false,
    ),
    // Seasonal
    _Tip(
      '🌸',
      'موسم الحساسية: احتياطاتك',
      'في الربيع: أغلق نوافذ سيارتك، استخدم قطرات العين، وتناول الكلاريتين قبل الخروج.',
      'موسمي',
      'موسمي',
      const Color(0xFF06B6D4),
      '5 دقائق',
      false,
    ),
    _Tip(
      '☀️',
      'احمِ جلدك من أشعة الصيف',
      'الأردن في الصيف يصل لـ 40 درجة. ضع واقي شمس SPF 50+ واشرب مياه بانتظام.',
      'موسمي',
      'موسمي',
      const Color(0xFF06B6D4),
      '3 دقائق',
      false,
    ),
  ];

  List<_Tip> get _filteredTips {
    if (_selectedCategory == 0) return _allTips;
    final cat = _categories[_selectedCategory].label;
    return _allTips.where((t) => t.category == cat).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final results = await Future.wait([
      ApiService.getProfile(),
      ApiService.getHealthRecord(),
    ]);
    if (!mounted) return;
    setState(() {
      _profile = results[0];
      _record = results[1];
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            _buildHeader(topPad),
            _buildCategoryScroll(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _buildTipsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double topPad) {
    final name = (_profile['name'] as String?) ?? 'مستخدم';
    return Container(
      padding: EdgeInsets.fromLTRB(8, topPad + 8, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF10B981)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ),
              const Expanded(
                child: Text(
                  'نصائح صحية يومية',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('🌅', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'مرحباً $name! إليك نصائح مخصصة لصحتك اليوم',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withAlpha(220),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _statChip('${_allTips.length}', 'نصيحة متاحة'),
                const SizedBox(width: 8),
                _statChip(
                  '${_allTips.where((t) => t.isPersonalized).length}',
                  'مخصصة لك',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(200)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryScroll() {
    return Container(
      height: 52,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final selected = i == _selectedCategory;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedCategory = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? cat.color : AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? cat.color : AppColors.border.withAlpha(60),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTipsList() {
    final tips = _filteredTips;
    if (tips.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🤔', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'لا توجد نصائح في هذه الفئة بعد',
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tips.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _TipCard(tip: tips[i]),
    );
  }
}

class _TipCard extends StatelessWidget {
  final _Tip tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tip.isPersonalized
              ? tip.color.withAlpha(80)
              : AppColors.border.withAlpha(60),
          width: tip.isPersonalized ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: tip.color.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tip.color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(tip.icon, style: const TextStyle(fontSize: 22)),
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
                        tip.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    if (tip.isPersonalized)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tip.color.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'لك',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: tip.color,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tip.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMedium,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      tip.duration,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundAlt,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tip.subcategory,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCategory {
  final String icon;
  final String label;
  final Color color;
  const _TipCategory(this.icon, this.label, this.color);
}

class _Tip {
  final String icon;
  final String title;
  final String body;
  final String category;
  final String subcategory;
  final Color color;
  final String duration;
  final bool isPersonalized;
  const _Tip(
    this.icon,
    this.title,
    this.body,
    this.category,
    this.subcategory,
    this.color,
    this.duration,
    this.isPersonalized,
  );
}
