const fs = require('fs');

// Rewrite more_tab.dart completely with correct structure
const moreTabContent = `import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/locale_service.dart';
import '../login_screen.dart';
import 'profile_screen.dart';
import 'family_sharing_screen.dart';
import 'notifications_screen.dart';
import 'payment_screen.dart';
import 'settings_screen.dart';
import 'medications_screen.dart';
import 'lab_results_screen.dart';
import 'home_services_screen.dart';
import 'devices_screen.dart';
import 'chronic_care_screen.dart';
import 'medical_record_tab.dart';
import 'wallet_tab.dart';
import 'health_tips_screen.dart';
import 'medication_delivery_screen.dart';
import 'appointment_reminder_screen.dart';

class MoreTab extends StatefulWidget {
  const MoreTab({super.key});

  @override
  State<MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<MoreTab> {
  Map<String, dynamic> _profile = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getProfile();
    if (mounted) setState(() => _profile = profile);
  }

  String get _name => (_profile['name'] as String?) ?? 'مستخدم';
  String get _initial => _name.isNotEmpty ? _name[0] : 'م';
  String get _email => (_profile['email'] as String?) ?? '';

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 16),
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
              Text(
                LocaleService().tr('more'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(context),
                const SizedBox(height: 20),
                _buildMenuSection(context, LocaleService().tr('account'), [
                  _MenuItem(
                    Icons.folder_shared_rounded,
                    LocaleService().tr('medical_record'),
                    null,
                    () => _push(context, const Directionality(textDirection: TextDirection.rtl, child: Scaffold(body: MedicalRecordTab()))),
                  ),
                  _MenuItem(
                    Icons.credit_card_rounded,
                    LocaleService().tr('health_wallet'),
                    null,
                    () => _push(context, const Directionality(textDirection: TextDirection.rtl, child: Scaffold(body: WalletTab()))),
                  ),
                  _MenuItem(
                    Icons.person_outlined,
                    LocaleService().tr('profile'),
                    null,
                    () => _push(context, const ProfileScreen()),
                  ),
                  _MenuItem(
                    Icons.family_restroom_rounded,
                    LocaleService().tr('family_sharing'),
                    LocaleService().tr('new_tag'),
                    () => _push(context, const FamilySharingScreen()),
                  ),
                  _MenuItem(
                    Icons.notifications_outlined,
                    LocaleService().tr('notifications'),
                    '3',
                    () => _push(context, const NotificationsScreen()),
                  ),
                ]),
                const SizedBox(height: 12),
                _buildMenuSection(context, 'الرعاية الشخصية', [
                  _MenuItem(
                    Icons.local_pharmacy_rounded,
                    'توصيل الأدوية',
                    'جديد',
                    () => _push(context, const MedicationDeliveryScreen()),
                  ),
                  _MenuItem(
                    Icons.tips_and_updates_rounded,
                    'نصائح صحية يومية',
                    'جديد',
                    () => _push(context, const HealthTipsScreen()),
                  ),
                  _MenuItem(
                    Icons.alarm_rounded,
                    'تنبيهات المواعيد والأدوية',
                    null,
                    () => _push(context, const AppointmentReminderScreen()),
                  ),
                ]),
                const SizedBox(height: 12),
                _buildMenuSection(context, LocaleService().tr('health'), [
                  _MenuItem(
                    Icons.medication_rounded,
                    LocaleService().tr('my_meds'),
                    null,
                    () => _push(context, const MedicationsScreen()),
                  ),
                  _MenuItem(
                    Icons.science_rounded,
                    LocaleService().tr('lab_results_more'),
                    null,
                    () => _push(context, const LabResultsScreen()),
                  ),
                  _MenuItem(
                    Icons.health_and_safety_rounded,
                    LocaleService().tr('home_services'),
                    LocaleService().tr('new_tag'),
                    () => _push(context, const HomeServicesScreen()),
                  ),
                  _MenuItem(
                    Icons.route_rounded,
                    LocaleService().tr('care_programs'),
                    null,
                    () => _push(context, const ChronicCareScreen()),
                  ),
                ]),
                const SizedBox(height: 12),
                _buildMenuSection(context, LocaleService().tr('payments'), [
                  _MenuItem(
                    Icons.payment_rounded,
                    LocaleService().tr('payment_history'),
                    null,
                    () => _push(context, const PaymentScreen()),
                  ),
                ]),
                const SizedBox(height: 12),
                _buildMenuSection(context, LocaleService().tr('devices'), [
                  _MenuItem(
                    Icons.watch_rounded,
                    LocaleService().tr('wearables'),
                    null,
                    () => _push(context, const DevicesScreen()),
                  ),
                ]),
                const SizedBox(height: 12),
                _buildMenuSection(context, LocaleService().tr('settings'), [
                  _MenuItem(
                    Icons.language_rounded,
                    'اللغة / Language',
                    LocaleService().isArabic ? 'العربية' : 'English',
                    () async {
                      await LocaleService().toggle();
                      if (mounted) setState(() {});
                    },
                  ),
                  _MenuItem(
                    Icons.dark_mode_outlined,
                    LocaleService().tr('theme_mode'),
                    LocaleService().tr('theme_value'),
                    () => _push(context, const SettingsScreen()),
                  ),
                  _MenuItem(
                    Icons.fingerprint_rounded,
                    LocaleService().tr('security'),
                    null,
                    () => _push(context, const SettingsScreen()),
                  ),
                  _MenuItem(
                    Icons.help_outline_rounded,
                    LocaleService().tr('help'),
                    null,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(LocaleService().tr('contact_us')),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    Icons.info_outline_rounded,
                    LocaleService().tr('about'),
                    'v1.0.0',
                    () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'ترياق Smart Health',
                        applicationVersion: 'v1.0.0',
                        applicationLegalese: '© 2025 Teryaq Smart Health',
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 20),
                // Logout
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.card,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              LocaleService().tr('logout'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            content: Text(LocaleService().tr('logout_confirm')),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(LocaleService().tr('cancel')),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  try {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.remove('auth_token');
                                  } catch (_) {}
                                  if (!context.mounted) return;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  LocaleService().tr('exit'),
                                  style: const TextStyle(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              LocaleService().tr('logout'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C3CE1), Color(0xFF5B6CF0)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _initial.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _email,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark.withAlpha(160),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<_MenuItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark.withAlpha(200),
              letterSpacing: 0.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.card,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: AppColors.border.withAlpha(40),
              indent: 18,
              endIndent: 18,
            ),
            itemBuilder: (_, i) {
              final item = items[i];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: i == 0
                      ? BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.lg),
                          topRight: Radius.circular(AppRadius.lg),
                        )
                      : i == items.length - 1
                          ? BorderRadius.only(
                              bottomLeft: Radius.circular(AppRadius.lg),
                              bottomRight: Radius.circular(AppRadius.lg),
                            )
                          : BorderRadius.zero,
                  onTap: item.onTap != null
                      ? () {
                          HapticFeedback.selectionClick();
                          item.onTap?.call();
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          color: AppColors.textDark,
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  item.badge!.isEmpty ? AppColors.primary : AppColors.error,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.badge!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.textDark.withAlpha(160),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _push(BuildContext context, Widget screen) {
    HapticFeedback.mediumImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? badge;
  final VoidCallback? onTap;

  _MenuItem(this.icon, this.title, this.badge, this.onTap);
}
`;

fs.writeFileSync(__dirname + '/lib/screens/more_tab.dart', moreTabContent, 'utf8');
console.log('✓ more_tab.dart fixed (' + fs.statSync(__dirname + '/lib/screens/more_tab.dart').size + ' bytes)');
