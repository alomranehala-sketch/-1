import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../app_shell.dart';
import 'gov_hospitals_screen.dart';
import 'private_hospitals_screen.dart';
import 'clinics_directory_screen.dart';
import 'pharmacies_hub_screen.dart';
import 'medical_services_hub_screen.dart';

/// Service Gateway — بوابة الخدمات الصحية
/// Main selection layer after citizen login — 5 primary health system options
class ServiceGatewayScreen extends StatefulWidget {
  final String userName;
  final String nationalId;
  const ServiceGatewayScreen({
    super.key,
    required this.userName,
    required this.nationalId,
  });
  @override
  State<ServiceGatewayScreen> createState() => _ServiceGatewayScreenState();
}

class _ServiceGatewayScreenState extends State<ServiceGatewayScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerCtrl;
  late AnimationController _bgCtrl;
  late Animation<double> _bgAnim;

  final _services = const <_GatewayService>[
    _GatewayService(
      'مستشفيات حكومية',
      'المستشفيات الحكومية — حكيم',
      Icons.local_hospital_rounded,
      Color(0xFF3B82F6),
      Color(0xFF1D4ED8),
      'مستشفى البشير، الجامعة، الأمير حمزة...',
    ),
    _GatewayService(
      'مستشفيات خاصة',
      'المستشفيات الخاصة المرخصة',
      Icons.business_rounded,
      Color(0xFF8B5CF6),
      Color(0xFF6D28D9),
      'الأردن، الاستقلال، الخالدي، الإسراء...',
    ),
    _GatewayService(
      'عيادات',
      'جميع التخصصات الطبية',
      Icons.medical_services_rounded,
      Color(0xFF10B981),
      Color(0xFF059669),
      'طب عام، جراحة، أسنان، قلب، جلدية...',
    ),
    _GatewayService(
      'صيدليات',
      'الصيدليات وطلب الأدوية',
      Icons.local_pharmacy_rounded,
      Color(0xFFF59E0B),
      Color(0xFFD97706),
      'بحث أدوية، صيدليات قريبة، توصيل...',
    ),
    _GatewayService(
      'خدمات طبية',
      'خدمات إضافية ومنزلية',
      Icons.health_and_safety_rounded,
      Color(0xFFEF4444),
      Color(0xFFDC2626),
      'تمريض منزلي، مختبرات، أشعة، نقل...',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _bgAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  void _onServiceTap(int index) {
    HapticFeedback.mediumImpact();
    Widget destination;
    switch (index) {
      case 0:
        destination = const GovHospitalsScreen();
        break;
      case 1:
        destination = const PrivateHospitalsScreen();
        break;
      case 2:
        destination = const ClinicsDirectoryScreen();
        break;
      case 3:
        destination = const PharmaciesHubScreen();
        break;
      case 4:
        destination = const MedicalServicesHubScreen();
        break;
      default:
        return;
    }
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, a, _) => destination,
        transitionsBuilder: (_, anim, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                  ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _goToFullApp() {
    HapticFeedback.mediumImpact();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AppShell()));
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // ── Animated BG ──
              AnimatedBuilder(
                animation: _bgAnim,
                builder: (_, _) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(
                          const Color(0xFF0F172A),
                          const Color(0xFF1E1B4B),
                          _bgAnim.value * 0.3,
                        )!,
                        const Color(0xFF0F172A),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Decorative circles ──
              Positioned(
                top: -60,
                left: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withAlpha(18),
                        AppColors.primary.withAlpha(0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                right: -60,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withAlpha(12),
                        AppColors.accent.withAlpha(0),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Content ──
              SafeArea(
                child: Column(
                  children: [
                    // ── Header ──
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        topPad > 0 ? 8 : 16,
                        20,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: AppColors.gradientPrimary,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(40),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.healing_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'أهلاً ${widget.userName} 👋',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'البوابة الصحية الموحدة — الأردن',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Sanad + Hakeem badges
                              _integrationBadge('سند', const Color(0xFF10B981)),
                              const SizedBox(width: 6),
                              _integrationBadge(
                                'حكيم',
                                const Color(0xFF3B82F6),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ── Search bar ──
                          GestureDetector(
                            onTap: _goToFullApp,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.border.withAlpha(50),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.textLight,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'ابحث عن مستشفى، عيادة، صيدلية، أو خدمة...',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textLight,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Section Title ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: AppColors.gradientPrimary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'اختر الخدمة الصحية',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Service Cards ──
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          bottomPad + 100,
                        ),
                        itemCount: _services.length,
                        itemBuilder: (_, i) {
                          final delay = i * 0.15;
                          return AnimatedBuilder(
                            animation: _staggerCtrl,
                            builder: (_, _) {
                              final t = ((_staggerCtrl.value - delay) / 0.25)
                                  .clamp(0.0, 1.0);
                              final curve = Curves.easeOutCubic.transform(t);
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - curve)),
                                child: Opacity(
                                  opacity: curve,
                                  child: _buildServiceCard(i, _services[i]),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom "Enter Full App" button ──
              Positioned(
                bottom: bottomPad + 16,
                left: 20,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: GestureDetector(
                      onTap: _goToFullApp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(50),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.dashboard_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'الدخول للتطبيق الكامل',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _integrationBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildServiceCard(int index, _GatewayService svc) {
    return GestureDetector(
      onTap: () => _onServiceTap(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: svc.color.withAlpha(25)),
          boxShadow: [
            BoxShadow(
              color: svc.color.withAlpha(10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [svc.color, svc.colorDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: svc.color.withAlpha(40),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(svc.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          svc.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          svc.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: svc.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          svc.desc,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textLight,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Arrow
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: svc.color.withAlpha(12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: svc.color,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GatewayService {
  final String title, subtitle, desc;
  final IconData icon;
  final Color color, colorDark;
  const _GatewayService(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.colorDark,
    this.desc,
  );
}
