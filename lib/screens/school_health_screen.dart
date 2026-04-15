import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// School Health Mode — صحة المدارس (تطعيمات، فحوصات مرتبطة بالمدارس)
class SchoolHealthScreen extends StatefulWidget {
  const SchoolHealthScreen({super.key});
  @override
  State<SchoolHealthScreen> createState() => _SchoolHealthScreenState();
}

class _SchoolHealthScreenState extends State<SchoolHealthScreen> {
  int _tabIndex = 0;

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
                'صحة الطلاب والمدارس',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildHero()),
            SliverToBoxAdapter(child: _buildTabs()),
            if (_tabIndex == 0) ...[
              SliverToBoxAdapter(child: _buildVaccinations()),
            ],
            if (_tabIndex == 1) ...[
              SliverToBoxAdapter(child: _buildCheckups()),
            ],
            if (_tabIndex == 2) ...[
              SliverToBoxAdapter(child: _buildStudentCards()),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'صحة أطفالك 🎒',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'تتبع تطعيمات المدرسة، الفحوصات الدورية، والبطاقة الصحية المدرسية',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['التطعيمات 💉', 'الفحوصات 🩺', 'بطاقات الطلاب'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final active = e.key == _tabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = e.key),
              child: Container(
                margin: EdgeInsets.only(left: e.key > 0 ? 6 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  e.value,
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.textMedium,
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVaccinations() {
    final kids = [
      _Kid('سارة', 'الصف الأول', [
        _Vac('شلل أطفال', true, '2024/09/15'),
        _Vac('حصبة + نكاف', true, '2024/09/15'),
        _Vac('إنفلونزا موسمية', false, 'مطلوب'),
        _Vac('التهاب كبد B', true, '2024/03/10'),
      ]),
      _Kid('أحمد', 'الصف الرابع', [
        _Vac('شلل أطفال (معززة)', true, '2024/09/20'),
        _Vac('إنفلونزا موسمية', true, '2024/10/05'),
        _Vac('ثلاثي بكتيري', false, 'مطلوب'),
      ]),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: kids
            .map(
              (kid) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withAlpha(30),
                          child: Text(
                            kid.name[0],
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kid.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              kid.grade,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kid.vacs.every((v) => v.done)
                                ? AppColors.success.withAlpha(15)
                                : const Color(0xFFF59E0B).withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            kid.vacs.every((v) => v.done)
                                ? 'مكتمل ✅'
                                : 'ناقص ⚠️',
                            style: TextStyle(
                              color: kid.vacs.every((v) => v.done)
                                  ? AppColors.success
                                  : const Color(0xFFF59E0B),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...kid.vacs.map(
                      (v) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              v.done
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: v.done
                                  ? AppColors.success
                                  : const Color(0xFFF59E0B),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                v.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              v.date,
                              style: TextStyle(
                                color: v.done
                                    ? AppColors.textLight
                                    : const Color(0xFFF59E0B),
                                fontSize: 11,
                                fontWeight: v.done
                                    ? FontWeight.w400
                                    : FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (kid.vacs.any((v) => !v.done))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم حجز موعد التطعيم بنجاح ✅'),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'حجز موعد تطعيم',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCheckups() {
    final checks = [
      _Checkup('فحص نظر', '2024/10/15', true, 'نظر سليم 6/6'),
      _Checkup('فحص سمع', '2024/10/15', true, 'سمع طبيعي'),
      _Checkup('فحص أسنان', '2024/11/01', false, 'مطلوب'),
      _Checkup('فحص نمو', '2024/09/01', true, 'طبيعي — طول 130سم'),
      _Checkup('فحص جنف', 'لم يتم', false, 'مطلوب'),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الفحوصات المدرسية الدورية',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...checks.map(
              (c) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            (c.done
                                    ? AppColors.success
                                    : const Color(0xFFF59E0B))
                                .withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        c.done
                            ? Icons.check_circle_rounded
                            : Icons.schedule_rounded,
                        color: c.done
                            ? AppColors.success
                            : const Color(0xFFF59E0B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            c.result,
                            style: TextStyle(
                              color: c.done
                                  ? AppColors.textLight
                                  : const Color(0xFFF59E0B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      c.date,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _studentCard('سارة', 'الصف الأول — مدرسة الأمل', 'A+', '1023456'),
          const SizedBox(height: 12),
          _studentCard('أحمد', 'الصف الرابع — مدرسة النور', 'O+', '1023457'),
        ],
      ),
    );
  }

  Widget _studentCard(String name, String school, String blood, String id) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '🏥 البطاقة الصحية المدرسية',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '#$id',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withAlpha(30),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      school,
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
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      'فصيلة الدم',
                      style: TextStyle(color: AppColors.textLight, fontSize: 8),
                    ),
                    Text(
                      blood,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip('حساسية: لا يوجد', const Color(0xFF10B981)),
              const SizedBox(width: 6),
              _infoChip('أمراض مزمنة: لا', const Color(0xFF3B82F6)),
              const SizedBox(width: 6),
              _infoChip('نظر: 6/6', const Color(0xFF8B5CF6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Kid {
  final String name, grade;
  final List<_Vac> vacs;
  const _Kid(this.name, this.grade, this.vacs);
}

class _Vac {
  final String name, date;
  final bool done;
  const _Vac(this.name, this.done, this.date);
}

class _Checkup {
  final String name, date, result;
  final bool done;
  const _Checkup(this.name, this.date, this.done, this.result);
}
