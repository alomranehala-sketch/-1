import 'package:flutter/material.dart';
import '../theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
                  bottom: BorderSide(
                    color: AppColors.border.withAlpha(40),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Text(
                    'الإشعارات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم مسح جميع الإشعارات'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text(
                      'مسح الكل',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDateHeader('اليوم'),
                  _notificationTile(
                    Icons.calendar_month_rounded,
                    AppColors.primary,
                    'تذكير بموعدك',
                    'لديك موعد غداً مع د. محمد العبادي الساعة 10:30 صباحاً',
                    'منذ ساعة',
                    true,
                  ),
                  _notificationTile(
                    Icons.medication_rounded,
                    AppColors.warning,
                    'وقت الدواء',
                    'حان وقت تناول ميتفورمين 500mg بعد الفطور',
                    'منذ 3 ساعات',
                    true,
                  ),
                  _notificationTile(
                    Icons.science_rounded,
                    AppColors.info,
                    'نتائج الفحوصات',
                    'نتائج فحص الدم CBC جاهزة. اضغط لعرضها',
                    'منذ 5 ساعات',
                    false,
                  ),
                  _buildDateHeader('أمس'),
                  _notificationTile(
                    Icons.check_circle_rounded,
                    AppColors.success,
                    'تم تأكيد الموعد',
                    'تم تأكيد موعدك في مستشفى الأردن',
                    'أمس 2:34 م',
                    false,
                  ),
                  _notificationTile(
                    Icons.local_offer_rounded,
                    const Color(0xFF7E57C2),
                    'عرض خاص',
                    'خصم 20% على فحص فيتامين D هذا الأسبوع',
                    'أمس 10:00 ص',
                    false,
                  ),
                  _buildDateHeader('هذا الأسبوع'),
                  _notificationTile(
                    Icons.tips_and_updates_rounded,
                    AppColors.info,
                    'نصيحة صحية',
                    'شرب 8 أكواب ماء يومياً يساعد في تحسين مستوى السكر',
                    'الأحد 9:00 ص',
                    false,
                  ),
                  _notificationTile(
                    Icons.security_rounded,
                    AppColors.textMedium,
                    'تسجيل دخول جديد',
                    'تم تسجيل دخول من جهاز جديد — iPhone 15',
                    'السبت 6:30 م',
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  Widget _notificationTile(
    IconData icon,
    Color color,
    String title,
    String body,
    String time,
    bool unread,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unread ? AppColors.primary.withAlpha(10) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: unread ? AppColors.primary.withAlpha(20) : AppColors.border,
        ),
        boxShadow: unread ? [] : AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
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
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: unread
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 10, color: AppColors.textLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
