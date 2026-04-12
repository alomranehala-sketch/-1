import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Medical Services Hub — الخدمات الطبية
/// Home nursing, labs, radiology, ambulance, medical transport
class MedicalServicesHubScreen extends StatefulWidget {
  const MedicalServicesHubScreen({super.key});
  @override
  State<MedicalServicesHubScreen> createState() =>
      _MedicalServicesHubScreenState();
}

class _MedicalServicesHubScreenState extends State<MedicalServicesHubScreen> {
  int _selectedCategory = -1;

  final _categories = const <_ServiceCategory>[
    _ServiceCategory(
      'تمريض منزلي',
      Icons.home_rounded,
      Color(0xFF10B981),
      'ممرض/ة لمنزلك',
      'رعاية مرضى — حقن — ضمادات — قياسات',
    ),
    _ServiceCategory(
      'تحاليل مخبرية',
      Icons.science_rounded,
      Color(0xFF3B82F6),
      'سحب عينات من البيت',
      'دم — بول — هرمونات — كورونا',
    ),
    _ServiceCategory(
      'أشعة منزلية',
      Icons.filter_hdr_rounded,
      Color(0xFF8B5CF6),
      'أشعة + سونار لمنزلك',
      'أشعة سينية — سونار — إيكو',
    ),
    _ServiceCategory(
      'إسعاف',
      Icons.local_hospital_rounded,
      Color(0xFFEF4444),
      'إسعاف طوارئ فوري',
      'نقل مرضى — حالات حرجة — إنعاش',
    ),
    _ServiceCategory(
      'نقل طبي',
      Icons.airport_shuttle_rounded,
      Color(0xFFF59E0B),
      'نقل بين مستشفيات',
      'نقل مرضى — كرسي متحرك — سرير',
    ),
    _ServiceCategory(
      'علاج طبيعي منزلي',
      Icons.sports_gymnastics_rounded,
      Color(0xFF0284C7),
      'جلسات في منزلك',
      'تأهيل — إصابات — ما بعد الجراحة',
    ),
    _ServiceCategory(
      'رعاية مسنين',
      Icons.elderly_rounded,
      Color(0xFFEC4899),
      'رعاية كبار السن',
      'ممرض مقيم — متابعة — أدوية',
    ),
    _ServiceCategory(
      'استشارة طبية عن بعد',
      Icons.videocam_rounded,
      Color(0xFF6366F1),
      'مكالمة فيديو مع طبيب',
      'استشارة — وصفة إلكترونية — متابعة',
    ),
  ];

  final Map<int, List<_ServiceProvider>> _providers = {
    0: [
      // تمريض منزلي
      _ServiceProvider(
        'خدمات الرحمة للتمريض',
        4.8,
        '15 د.أ / زيارة',
        'عمّان',
        true,
        'متاح خلال ساعة',
        'ممرضين مسجلين — 24/7',
      ),
      _ServiceProvider(
        'تمريض الأمل',
        4.6,
        '12 د.أ / زيارة',
        'عمّان — إربد',
        true,
        'متاح اليوم',
        'حقن — ضمادات — قياسات',
      ),
      _ServiceProvider(
        'الشفاء للرعاية المنزلية',
        4.7,
        '20 د.أ / زيارة',
        'عمّان',
        true,
        'متاح',
        'ممرض/ة مع خبرة 5+ سنوات',
      ),
    ],
    1: [
      // تحاليل مخبرية
      _ServiceProvider(
        'مختبرات البرج',
        4.9,
        '10 د.أ — سحب من البيت',
        'عمّان — الأردن',
        true,
        'متاح اليوم',
        'نتائج خلال 24 ساعة — معتمد',
      ),
      _ServiceProvider(
        'مختبرات المستقبل',
        4.7,
        '8 د.أ — سحب من البيت',
        'عمّان',
        true,
        'متاح',
        'تحاليل شاملة — PCR',
      ),
      _ServiceProvider(
        'مختبر الحياة',
        4.5,
        '7 د.أ — سحب من البيت',
        'إربد',
        true,
        'متاح غداً',
        'تحاليل دم + بول + هرمونات',
      ),
    ],
    2: [
      // أشعة منزلية
      _ServiceProvider(
        'مركز الأردن للأشعة المتنقلة',
        4.8,
        '25 د.أ',
        'عمّان',
        true,
        'متاح',
        'أشعة سينية + سونار بالمنزل',
      ),
      _ServiceProvider(
        'أشعة الحكمة المتنقلة',
        4.6,
        '30 د.أ',
        'عمّان',
        false,
        'متاح غداً',
        'إيكو قلب + سونار بطن',
      ),
    ],
    3: [
      // إسعاف
      _ServiceProvider(
        'الدفاع المدني',
        5.0,
        'مجاني',
        'كل الأردن',
        true,
        'فوري — 911',
        'حالات الطوارئ — الرقم الموحد 911',
      ),
      _ServiceProvider(
        'إسعاف خاص — الرحمة',
        4.7,
        '25 د.أ',
        'عمّان',
        true,
        'متاح 24/7',
        'نقل مرضى — إسعاف مجهز بالكامل',
      ),
    ],
    4: [
      // نقل طبي
      _ServiceProvider(
        'نقل الأمل الطبي',
        4.5,
        '15 د.أ',
        'عمّان',
        true,
        'متاح',
        'نقل بين مستشفيات — كرسي متحرك',
      ),
      _ServiceProvider(
        'خدمات الإسراء للنقل',
        4.4,
        '20 د.أ',
        'عمّان — إربد',
        true,
        'متاح',
        'سرير — أوكسجين — مرافق',
      ),
    ],
    5: [
      // علاج طبيعي
      _ServiceProvider(
        'مركز الحركة — منزلي',
        4.8,
        '20 د.أ / جلسة',
        'عمّان',
        true,
        'متاح',
        'أخصائي علاج طبيعي — إصابات رياضية',
      ),
      _ServiceProvider(
        'فيزيو كير',
        4.6,
        '18 د.أ / جلسة',
        'عمّان — الزرقاء',
        true,
        'متاح',
        'تأهيل بعد العمليات — عمود فقري',
      ),
    ],
    6: [
      // رعاية مسنين
      _ServiceProvider(
        'دار الحنان للرعاية',
        4.7,
        '200 د.أ / شهر',
        'عمّان',
        true,
        'متاح',
        'ممرض مقيم — متابعة يومية',
      ),
      _ServiceProvider(
        'رعاية الأمل',
        4.5,
        '150 د.أ / شهر',
        'عمّان',
        true,
        'متاح',
        'رعاية كبار السن — أدوية — تغذية',
      ),
    ],
    7: [
      // استشارة عن بعد
      _ServiceProvider(
        'طبيب أونلاين',
        4.8,
        '10 د.أ',
        'أونلاين',
        true,
        'متاح الآن',
        'مكالمة فيديو — وصفة إلكترونية',
      ),
      _ServiceProvider(
        'مستشارك الطبي',
        4.6,
        '8 د.أ',
        'أونلاين',
        true,
        'متاح الآن',
        'دردشة + فيديو — متابعة مجانية',
      ),
    ],
  };

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
                      if (_selectedCategory >= 0) {
                        setState(() => _selectedCategory = -1);
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
                      _selectedCategory < 0
                          ? 'الخدمات الطبية 🏠'
                          : _categories[_selectedCategory].name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _selectedCategory < 0
                  ? _buildCategoriesView()
                  : _buildProvidersView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Emergency banner
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            setState(() => _selectedCategory = 3);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withAlpha(30),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emergency_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'طوارئ — إسعاف فوري',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'اتصل 911 للحالات الحرجة',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white54,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Connected badges
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _badge(
              'مرتبط بحكيم',
              Icons.verified_rounded,
              const Color(0xFF10B981),
            ),
            const SizedBox(width: 10),
            _badge(
              'مرتبط بسند',
              Icons.account_balance_rounded,
              const Color(0xFF3B82F6),
            ),
            const SizedBox(width: 10),
            _badge(
              'GPS مباشر',
              Icons.gps_fixed_rounded,
              const Color(0xFFF59E0B),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Categories grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _categories.length,
          itemBuilder: (_, i) {
            final cat = _categories[i];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = i);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cat.color.withAlpha(25)),
                  boxShadow: [
                    BoxShadow(
                      color: cat.color.withAlpha(8),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cat.color.withAlpha(15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      cat.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cat.subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
                      ),
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

  Widget _badge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvidersView() {
    final providers = _providers[_selectedCategory] ?? [];
    final cat = _categories[_selectedCategory];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Category hero
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cat.color.withAlpha(10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cat.color.withAlpha(25)),
          ),
          child: Row(
            children: [
              Icon(cat.icon, color: cat.color, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: cat.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cat.desc,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${providers.length} مزود خدمة',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 10),
        ...providers.map((p) => _buildProviderCard(p, cat.color)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildProviderCard(_ServiceProvider p, Color catColor) {
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
                  color: catColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.business_rounded, color: catColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
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
                        const SizedBox(width: 8),
                        Text(
                          p.coverage,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                p.price,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: catColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            p.desc,
            style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: p.available
                      ? const Color(0xFF10B981).withAlpha(10)
                      : const Color(0xFFEF4444).withAlpha(10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p.avStatus,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: p.available
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✅ تم طلب ${_categories[_selectedCategory].name} من ${p.name}',
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: catColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'اطلب الآن',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceCategory {
  final String name, subtitle, desc;
  final IconData icon;
  final Color color;
  const _ServiceCategory(
    this.name,
    this.icon,
    this.color,
    this.subtitle,
    this.desc,
  );
}

class _ServiceProvider {
  final String name;
  final double rating;
  final String price, coverage;
  final bool available;
  final String avStatus, desc;
  const _ServiceProvider(
    this.name,
    this.rating,
    this.price,
    this.coverage,
    this.available,
    this.avStatus,
    this.desc,
  );
}
