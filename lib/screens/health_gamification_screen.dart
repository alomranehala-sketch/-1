import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

/// Health Gamification — نظام النقاط الصحية
class HealthGamificationScreen extends StatefulWidget {
  const HealthGamificationScreen({super.key});
  @override
  State<HealthGamificationScreen> createState() =>
      _HealthGamificationScreenState();
}

class _HealthGamificationScreenState extends State<HealthGamificationScreen> {
  int _totalPoints = 0;
  int _level = 1;
  int _streak = 0;
  final Map<String, bool> _dailyTasks = {};
  final Map<String, bool> _weeklyTasks = {};

  final _dailyTaskDefs = [
    {'id': 'water', 'title': 'شرب 8 أكواب ماء', 'icon': '💧', 'points': 10},
    {'id': 'walk', 'title': 'مشي 30 دقيقة', 'icon': '🚶', 'points': 15},
    {'id': 'meds', 'title': 'أخذ الأدوية بوقتها', 'icon': '💊', 'points': 20},
    {'id': 'sleep', 'title': 'نوم 7+ ساعات', 'icon': '😴', 'points': 15},
    {'id': 'fruits', 'title': 'أكل 3 حصص فواكه', 'icon': '🍎', 'points': 10},
    {'id': 'nosmoke', 'title': 'يوم بدون تدخين', 'icon': '🚭', 'points': 25},
  ];

  final _weeklyTaskDefs = [
    {
      'id': 'exercise',
      'title': 'تمرين رياضي 3 مرات',
      'icon': '🏋️',
      'points': 50,
    },
    {'id': 'checkup', 'title': 'فحص ضغط الدم', 'icon': '🩺', 'points': 30},
    {
      'id': 'mental',
      'title': 'جلسة تأمل / استرخاء',
      'icon': '🧘',
      'points': 20,
    },
    {'id': 'social', 'title': 'تواصل اجتماعي صحي', 'icon': '👥', 'points': 15},
  ];

  final _rewards = [
    {'title': 'خصم 10% فحص شامل', 'points': 200, 'icon': '🏥'},
    {'title': 'استشارة مجانية عن بعد', 'points': 350, 'icon': '📱'},
    {'title': 'خصم 15% صيدلية', 'points': 150, 'icon': '💊'},
    {'title': 'فحص مختبر مجاني', 'points': 500, 'icon': '🧪'},
    {'title': 'جلسة علاج طبيعي', 'points': 400, 'icon': '💆'},
    {'title': 'خصم 20% تأمين صحي', 'points': 1000, 'icon': '🛡️'},
  ];

  final _badges = [
    {'title': 'المبتدئ', 'desc': 'أول يوم صحي', 'icon': '🌱', 'earned': true},
    {
      'title': 'المنتظم',
      'desc': '7 أيام متتالية',
      'icon': '🔥',
      'earned': true,
    },
    {'title': 'البطل', 'desc': '30 يوم متتالية', 'icon': '🏆', 'earned': false},
    {
      'title': 'الملتزم',
      'desc': 'أخذ الأدوية 30 يوم',
      'icon': '💪',
      'earned': false,
    },
    {'title': 'الرياضي', 'desc': '50 تمرين', 'icon': '⚡', 'earned': false},
    {
      'title': 'المتفوق',
      'desc': 'وصول مستوى 10',
      'icon': '👑',
      'earned': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalPoints = prefs.getInt('health_points') ?? 245;
      _level = prefs.getInt('health_level') ?? 3;
      _streak = prefs.getInt('health_streak') ?? 12;
      for (var t in _dailyTaskDefs) {
        _dailyTasks[t['id'] as String] =
            prefs.getBool('daily_${t['id']}') ?? false;
      }
      for (var t in _weeklyTaskDefs) {
        _weeklyTasks[t['id'] as String] =
            prefs.getBool('weekly_${t['id']}') ?? false;
      }
    });
  }

  Future<void> _toggleDaily(String id, int points) async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    final current = _dailyTasks[id] ?? false;
    final newVal = !current;
    setState(() {
      _dailyTasks[id] = newVal;
      _totalPoints += newVal ? points : -points;
    });
    await prefs.setBool('daily_$id', newVal);
    await prefs.setInt('health_points', _totalPoints);
  }

  Future<void> _toggleWeekly(String id, int points) async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    final current = _weeklyTasks[id] ?? false;
    final newVal = !current;
    setState(() {
      _weeklyTasks[id] = newVal;
      _totalPoints += newVal ? points : -points;
    });
    await prefs.setBool('weekly_$id', newVal);
    await prefs.setInt('health_points', _totalPoints);
  }

  int get _dailyCompleted => _dailyTasks.values.where((v) => v).length;
  int get _levelProgress => _totalPoints % 100;
  int get _nextLevel => (_level) * 100;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with points
            Container(
              padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'نقاطي الصحية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              '$_streak يوم',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Points display
                  Text(
                    '$_totalPoints',
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'نقطة صحية',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  // Level bar
                  Row(
                    children: [
                      Text(
                        'Lv.$_level',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _levelProgress / _nextLevel,
                            backgroundColor: Colors.white.withAlpha(30),
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Lv.${_level + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_levelProgress/$_nextLevel للمستوى التالي',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily progress
                  Row(
                    children: [
                      const Text('📋', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      const Text(
                        'مهام اليوم',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$_dailyCompleted/${_dailyTaskDefs.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._dailyTaskDefs.map(
                    (t) => _taskItem(
                      t['icon'] as String,
                      t['title'] as String,
                      t['points'] as int,
                      _dailyTasks[t['id']] ?? false,
                      () => _toggleDaily(t['id'] as String, t['points'] as int),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Weekly tasks
                  const Row(
                    children: [
                      Text('🎯', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        'تحديات الأسبوع',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._weeklyTaskDefs.map(
                    (t) => _taskItem(
                      t['icon'] as String,
                      t['title'] as String,
                      t['points'] as int,
                      _weeklyTasks[t['id']] ?? false,
                      () =>
                          _toggleWeekly(t['id'] as String, t['points'] as int),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Badges
                  const Row(
                    children: [
                      Text('🏅', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        'الشارات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                    children: _badges.map((b) => _badgeCard(b)).toList(),
                  ),

                  const SizedBox(height: 20),
                  // Rewards
                  const Row(
                    children: [
                      Text('🎁', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        'استبدال النقاط',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._rewards.map((r) => _rewardCard(r)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskItem(
    String icon,
    String title,
    int points,
    bool done,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: done
              ? AppColors.success.withAlpha(10)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: done
                ? AppColors.success.withAlpha(30)
                : Colors.white.withAlpha(8),
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: done ? AppColors.success : Colors.white,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+$points',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              done ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: done ? AppColors.success : Colors.white24,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeCard(Map<String, dynamic> b) {
    final earned = b['earned'] as bool;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: earned
            ? const Color(0xFFF59E0B).withAlpha(10)
            : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: earned
              ? const Color(0xFFF59E0B).withAlpha(40)
              : Colors.white.withAlpha(8),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            b['icon'] as String,
            style: TextStyle(
              fontSize: 28,
              color: earned ? null : const Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            b['title'] as String,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: earned ? Colors.white : Colors.white38,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            b['desc'] as String,
            style: TextStyle(
              fontSize: 8,
              color: earned ? Colors.white54 : Colors.white24,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _rewardCard(Map<String, dynamic> r) {
    final points = r['points'] as int;
    final canRedeem = _totalPoints >= points;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: canRedeem
              ? AppColors.primary.withAlpha(30)
              : Colors.white.withAlpha(8),
        ),
      ),
      child: Row(
        children: [
          Text(r['icon'] as String, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r['title'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$points نقطة',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withAlpha(100),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: canRedeem
                ? () {
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم استبدال ${r['title']} بنجاح! 🎉'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: canRedeem
                    ? AppColors.primary
                    : Colors.white.withAlpha(5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'استبدال',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: canRedeem ? Colors.white : Colors.white24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
