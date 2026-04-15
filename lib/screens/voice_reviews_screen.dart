import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Voice Reviews + Before/After Photos — تقييمات صوتية ومقارنة صور قبل وبعد
class VoiceReviewsScreen extends StatefulWidget {
  const VoiceReviewsScreen({super.key});
  @override
  State<VoiceReviewsScreen> createState() => _VoiceReviewsScreenState();
}

class _VoiceReviewsScreenState extends State<VoiceReviewsScreen> {
  int _selectedTab = 0;
  bool _recording = false;

  final _reviews = [
    _Review(
      'أحمد',
      'مستشفى الجامعة',
      'عملية ناجحة والطاقم ممتاز',
      4.5,
      45,
      true,
      false,
    ),
    _Review(
      'فاطمة',
      'مستشفى البشير',
      'عناية ممتازة بالأطفال',
      5.0,
      23,
      true,
      true,
    ),
    _Review(
      'محمد',
      'المدينة الطبية',
      'قسم القلب احترافي جداً',
      4.0,
      67,
      false,
      true,
    ),
    _Review('سارة', 'الأردن - خاص', 'كوادر طبية متميزة', 4.5, 12, true, false),
    _Review('عمر', 'الإسلامي', 'طوارئ سريعين ومتعاونين', 3.5, 34, true, true),
  ];

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
                'تقييمات وتجارب المرضى',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.filter_list_rounded,
                    color: AppColors.textLight,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('فلترة التقييمات — قريباً 🔜'),
                        backgroundColor: Color(0xFF3B82F6),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(child: _buildStats()),
            SliverToBoxAdapter(child: _buildTabs()),
            SliverToBoxAdapter(child: _buildAddReview()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _buildReviewCard(_reviews[i]),
                childCount: _reviews.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'صوت المريض 🎙️',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'شارك تجربتك — ساعد غيرك',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.record_voice_over_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statBadge('12,450', 'تقييم'),
              const SizedBox(width: 8),
              _statBadge('4,320', 'صوتي'),
              const SizedBox(width: 8),
              _statBadge('890', 'قبل/بعد'),
              const SizedBox(width: 8),
              _statBadge('4.2', 'معدل'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String val, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['الكل', 'صوتي 🎙️', 'قبل/بعد 📸', 'مستشفيات', 'أطباء'];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final active = e.key == _selectedTab;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active
                        ? AppColors.primary
                        : AppColors.border.withAlpha(40),
                  ),
                ),
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

  Widget _buildAddReview() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
      ),
      child: Column(
        children: [
          const Text(
            'أضف تقييمك',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _recording = !_recording);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _recording
                          ? AppColors.error.withAlpha(20)
                          : AppColors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _recording ? AppColors.error : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _recording
                              ? Icons.stop_circle_rounded
                              : Icons.mic_rounded,
                          color: _recording
                              ? AppColors.error
                              : AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _recording ? 'إيقاف التسجيل' : 'تسجيل صوتي 🎙️',
                          style: TextStyle(
                            color: _recording
                                ? AppColors.error
                                : AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent, width: 1.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.compare_rounded,
                          color: AppColors.accent,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'قبل / بعد 📸',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_recording) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.fiber_manual_record_rounded,
                    color: AppColors.error,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'جاري التسجيل... 0:12',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.graphic_eq_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewCard(_Review r) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(25)),
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
                  r.name[0],
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      r.hospital,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  final full = i < r.rating.floor();
                  final half = !full && i < r.rating;
                  return Icon(
                    full
                        ? Icons.star_rounded
                        : (half
                              ? Icons.star_half_rounded
                              : Icons.star_border_rounded),
                    color: const Color(0xFFF59E0B),
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            r.text,
            style: const TextStyle(
              color: AppColors.textMedium,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (r.hasVoice)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_filled_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '🎙️ صوتي',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (r.hasVoice) const SizedBox(width: 6),
              if (r.hasPhotos)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.compare_rounded,
                        color: AppColors.accent,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '📸 قبل/بعد',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              Icon(
                Icons.thumb_up_alt_rounded,
                color: AppColors.textLight,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${r.likes}',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Review {
  final String name, hospital, text;
  final double rating;
  final int likes;
  final bool hasVoice, hasPhotos;
  const _Review(
    this.name,
    this.hospital,
    this.text,
    this.rating,
    this.likes,
    this.hasVoice,
    this.hasPhotos,
  );
}
