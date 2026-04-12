import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'firebase_options.dart';
import 'services/api_service.dart';
import 'services/locale_service.dart';
import 'services/theme_service.dart';
import 'services/offline_service.dart';
import 'login_screen.dart';
import 'app_shell.dart';
import 'screens/hms_shell.dart';
import 'screens/moh_shell.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  await ApiService.restoreToken();
  await LocaleService().init();
  await ThemeService().init();
  // Trigger offline data sync in background (Feature 3)
  if (ApiService.token != null) {
    OfflineService.syncAll(); // fire-and-forget
  }
  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  runApp(TeryaqApp());
}

class TeryaqApp extends StatefulWidget {
  const TeryaqApp({super.key});
  @override
  State<TeryaqApp> createState() => _TeryaqAppState();
}

class _TeryaqAppState extends State<TeryaqApp> {
  final _locale = LocaleService();
  final _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _locale.addListener(() {
      if (mounted) setState(() {});
    });
    _themeService.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = _themeService.primary;
    return Directionality(
      textDirection: _locale.direction,
      child: MaterialApp(
        title: 'ترياق — Teryaq Smart Health',
        debugShowCheckedModeBanner: false,
        locale: _locale.locale,
        builder: (context, child) {
          if (kIsWeb && MediaQuery.of(context).size.width > 500) {
            return _PhoneFrame(child: child!);
          }
          return child!;
        },
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: primary,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          fontFamily: 'Tajawal',
          colorScheme: ColorScheme.fromSeed(
            seedColor: primary,
            brightness: Brightness.dark,
            surface: const Color(0xFF1E293B),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF1E293B),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: Colors.white.withAlpha(15),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {'/login': (context) => const LoginScreen()},
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Web Entry — Skip video on web, go directly to app or login
// ═══════════════════════════════════════════════════════════════
class _WebEntry extends StatefulWidget {
  const _WebEntry();
  @override
  State<_WebEntry> createState() => _WebEntryState();
}

class _WebEntryState extends State<_WebEntry> {
  bool _decided = false;
  Widget? _target;

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    // Small delay to ensure framework is fully initialized
    await Future.delayed(const Duration(milliseconds: 100));

    // Clear stale sessions (no role saved = old format)
    final prefs = await SharedPreferences.getInstance();
    final hasRole = prefs.getString('user_role');
    if (hasRole == null) {
      await prefs.remove('auth_token');
    }

    Widget target;
    try {
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        // Read saved role to route correctly
        final role = prefs.getString('user_role') ?? 'citizen';
        final name = prefs.getString('user_name') ?? '';
        switch (role) {
          case 'doctor':
          case 'nurse':
          case 'reception':
            target = HmsShell(role: role, userName: name);
            break;
          case 'moh':
            target = MohShell(userName: name);
            break;
          default:
            target = const AppShell();
        }
      } else {
        target = const LoginScreen();
      }
    } catch (_) {
      target = const LoginScreen();
    }
    if (mounted) {
      setState(() {
        _decided = true;
        _target = target;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_decided && _target != null) return _target!;
    return const Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Splash Screen — Intro Video
// ═══════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    // Skip video on web — video_player often fails on web builds
    if (kIsWeb) {
      if (mounted) _navigateNext();
      return;
    }
    final vc = VideoPlayerController.asset('assets/intro_video.mp4');
    _videoController = vc;
    try {
      await vc.initialize();
      vc.setLooping(false);
      vc.addListener(_onVideoProgress);
      if (mounted) {
        setState(() => _videoInitialized = true);
        vc.play();
      }
    } catch (_) {
      // If video fails to load, navigate immediately
      if (mounted) _navigateNext();
    }
  }

  void _onVideoProgress() {
    if (_navigating) return;
    final vc = _videoController;
    if (vc == null) return;
    final pos = vc.value.position;
    final dur = vc.value.duration;
    if (dur.inMilliseconds > 0 && pos >= dur) {
      _navigating = true;
      _navigateNext();
    }
  }

  Future<void> _navigateNext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 600),
              pageBuilder: (_, _, _) => const AppShell(),
              transitionsBuilder: (_, anim, _, child) => FadeTransition(
                opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                child: child,
              ),
            ),
          );
        }
        return;
      }
    } catch (_) {}
    if (mounted) _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  void _skipVideo() {
    if (!_navigating) {
      _navigating = true;
      _videoController?.pause();
      _navigateNext();
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoProgress);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _skipVideo,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video
              if (_videoInitialized && _videoController != null)
                Center(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                )
              else
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              // Skip button
              if (_videoInitialized)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  child: SafeArea(
                    child: TextButton(
                      onPressed: _skipVideo,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black45,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'تخطي',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
}

// ═══════════════════════════════════════════════════════════════
//  Phone Frame — Web Desktop Wrapper
// ═══════════════════════════════════════════════════════════════
class _PhoneFrame extends StatelessWidget {
  final Widget child;
  const _PhoneFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    const maxW = 393.0;
    const maxH = 852.0;
    const aspect = maxW / maxH;

    var ph = min(maxH, sh - 48.0);
    var pw = ph * aspect;
    if (pw > sw - 48) {
      pw = sw - 48;
      ph = pw / aspect;
    }

    final bezelR = pw * 0.122;
    final innerR = pw * 0.112;

    return Container(
      color: const Color(0xFF06060E),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient glow
          Container(
            width: pw + 300,
            height: ph + 200,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6366F1).withAlpha(8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Secondary glow
          Positioned(
            top: sh * 0.2,
            right: sw * 0.15,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF06B6D4).withAlpha(5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Phone body (bezel)
          Container(
            width: pw + 14,
            height: ph + 14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(bezelR + 4),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A28),
                  Color(0xFF0E0E18),
                  Color(0xFF141420),
                ],
              ),
              border: Border.all(color: const Color(0xFF252535), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(180),
                  blurRadius: 80,
                  offset: const Offset(0, 30),
                ),
                BoxShadow(
                  color: const Color(0xFF6366F1).withAlpha(10),
                  blurRadius: 120,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(innerR),
                child: SizedBox(
                  width: pw,
                  height: ph,
                  child: MediaQuery(
                    data: mq.copyWith(
                      size: Size(pw, ph),
                      padding: EdgeInsets.only(
                        top: ph * 0.058,
                        bottom: ph * 0.03,
                      ),
                      viewPadding: EdgeInsets.only(
                        top: ph * 0.058,
                        bottom: ph * 0.03,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(child: child),
                        // Dynamic Island
                        Positioned(
                          top: ph * 0.012,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: Align(
                              child: Container(
                                width: pw * 0.32,
                                height: ph * 0.038,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(
                                    ph * 0.019,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Status bar
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: ph * 0.058,
                          child: IgnorePointer(
                            child: _statusBarContent(pw, ph),
                          ),
                        ),
                        // Home indicator
                        Positioned(
                          bottom: ph * 0.008,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: Align(
                              child: Container(
                                width: pw * 0.35,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(38),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Side buttons
          SizedBox(
            width: pw + 22,
            height: ph + 14,
            child: Stack(
              children: [
                // Power button (right)
                Positioned(
                  right: 0,
                  top: ph * 0.22,
                  child: Container(
                    width: 3,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF222233),
                          Color(0xFF333344),
                          Color(0xFF222233),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Volume up (left)
                Positioned(
                  left: 0,
                  top: ph * 0.17,
                  child: Container(
                    width: 3,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF222233),
                          Color(0xFF333344),
                          Color(0xFF222233),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Volume down (left)
                Positioned(
                  left: 0,
                  top: ph * 0.24,
                  child: Container(
                    width: 3,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF222233),
                          Color(0xFF333344),
                          Color(0xFF222233),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Mute switch (left)
                Positioned(
                  left: 0,
                  top: ph * 0.12,
                  child: Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A3A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBarContent(double pw, double ph) {
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.fromLTRB(pw * 0.08, ph * 0.016, pw * 0.06, 0),
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
            decoration: TextDecoration.none,
          ),
          child: Row(
            children: [
              Text(time),
              const Spacer(),
              const Icon(
                Icons.signal_cellular_4_bar,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.wifi, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              const Icon(Icons.battery_full, color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
