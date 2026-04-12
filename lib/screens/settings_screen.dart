import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'العربية';
  String _theme = 'فاتح';
  bool _biometric = true;
  bool _notifications = true;
  bool _locationServices = true;
  bool _dataSharing = false;

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
                    'الإعدادات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Appearance ─────────
                  _sectionTitle('المظهر'),
                  _selectTile(
                    'اللغة',
                    Icons.language_rounded,
                    _language,
                    ['العربية', 'English'],
                    (v) => setState(() => _language = v),
                  ),
                  _selectTile(
                    'السمة',
                    Icons.palette_rounded,
                    _theme,
                    ['فاتح', 'داكن', 'تلقائي'],
                    (v) => setState(() => _theme = v),
                  ),
                  const SizedBox(height: 20),

                  // ── Security ──────────
                  _sectionTitle('الأمان'),
                  _toggleTile(
                    'تسجيل بالبصمة',
                    Icons.fingerprint_rounded,
                    _biometric,
                    (v) => setState(() => _biometric = v),
                  ),
                  _actionTile('تغيير كلمة المرور', Icons.lock_rounded, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('سيتم إرسال رابط إعادة التعيين'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }),
                  _actionTile('التحقق بخطوتين', Icons.security_rounded, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('سيتم تفعيل التحقق بخطوتين قريباً'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // ── Notifications ─────
                  _sectionTitle('الإشعارات'),
                  _toggleTile(
                    'إشعارات التطبيق',
                    Icons.notifications_rounded,
                    _notifications,
                    (v) => setState(() => _notifications = v),
                  ),
                  _toggleTile(
                    'خدمات الموقع',
                    Icons.location_on_rounded,
                    _locationServices,
                    (v) => setState(() => _locationServices = v),
                  ),
                  const SizedBox(height: 20),

                  // ── Privacy ───────────
                  _sectionTitle('الخصوصية'),
                  _toggleTile(
                    'مشاركة البيانات الصحية',
                    Icons.share_rounded,
                    _dataSharing,
                    (v) => setState(() => _dataSharing = v),
                  ),
                  _actionTile('سياسة الخصوصية', Icons.description_rounded, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('سياسة الخصوصية — نحترم خصوصيتك'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }),
                  _actionTile('شروط الاستخدام', Icons.article_rounded, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('شروط الاستخدام — الإصدار 1.0'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // ── About ─────────────
                  _sectionTitle('حول التطبيق'),
                  _infoTile('الإصدار', 'v1.0.0'),
                  _infoTile('آخر تحديث', '2025/01/15'),
                  const SizedBox(height: 20),

                  // ── Danger Zone ────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(5),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.error.withAlpha(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'منطقة الخطر',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _dangerAction('حذف جميع البيانات المحلية', () {
                          _showConfirmDialog(
                            'حذف البيانات',
                            'سيتم حذف جميع البيانات المحفوظة محلياً. هل أنت متأكد؟',
                          );
                        }),
                        const SizedBox(height: 8),
                        _dangerAction('حذف الحساب', () {
                          _showConfirmDialog(
                            'حذف الحساب',
                            'سيتم حذف حسابك نهائياً ولا يمكن استرجاعه. هل أنت متأكد؟',
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _toggleTile(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMedium),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _selectTile(
    String label,
    IconData icon,
    String current,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...options.map(
                    (o) => ListTile(
                      title: Text(
                        o,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      trailing: current == o
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        onChanged(o);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMedium),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Text(
              current,
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_left_rounded,
              size: 18,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMedium),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_left_rounded,
              size: 18,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _dangerAction(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: AppColors.textMedium),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تنفيذ العملية'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'تأكيد',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
