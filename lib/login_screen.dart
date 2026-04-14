import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/hms_shell.dart';
import 'screens/moh_shell.dart';
import 'screens/service_gateway_screen.dart';
import 'services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passportController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showIdLogin = false;
  bool _showOtpLogin = false;
  bool _showResidentLogin = false;
  bool _otpSent = false;
  bool _showSuccess = false;
  String _generatedOtp = '';
  String _role = 'citizen';
  String _userName = '';

  // Biometric state
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _showBiometricPrompt = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bgController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _bgAnim;

  // ─── Design Tokens ──────────────────────────────────────
  static const _tealDark = Color(0xFF3730A3); // Indigo-800
  static const _tealPrimary = Color(0xFF4F46E5); // Indigo-600
  static const _tealLight = Color(0xFF6366F1); // Indigo-500
  static const _tealAccent = Color(0xFF818CF8); // Indigo-400
  static const _blueDark = Color(0xFF1E1B4B); // Indigo-950
  static const _blueLight = Color(0xFF06B6D4); // Cyan-500
  static const _surface = Color(0xFFF8FAFC);
  static const _cardBg = Color(0xFFFFFFFF);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF475569);
  static const _success = Color(0xFF10B981);
  static const _inputBorder = Color(0xFFE0E7FF); // Indigo-100
  static const _inputFill = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _bgAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _fadeController.forward();
    _slideController.forward();
    _initBiometrics();
  }

  Future<void> _initBiometrics() async {
    if (kIsWeb) return; // Biometrics not available on web
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('biometric_enabled') ?? false;

      if (mounted) {
        setState(() {
          _biometricAvailable = canCheck && isSupported;
          _biometricEnabled = enabled;
        });

        // Auto-trigger biometric login if enabled
        if (_biometricAvailable && _biometricEnabled) {
          _authenticateWithBiometric();
        }
      }
    } catch (_) {
      // Biometric not available
    }
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'سجّل دخولك باستخدام البصمة أو الوجه',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated && mounted) {
        HapticFeedback.heavyImpact();
        setState(() => _showSuccess = true);
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;
        _navigateToHome();
      }
    } on PlatformException {
      // Auth failed or cancelled
    }
  }

  Future<void> _promptEnableBiometric() async {
    if (!_biometricAvailable || _biometricEnabled) return;

    setState(() => _showBiometricPrompt = true);
  }

  Future<void> _saveBiometricPreference(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enable);
    setState(() {
      _biometricEnabled = enable;
      _showBiometricPrompt = false;
    });

    if (enable) {
      HapticFeedback.mediumImpact();
    }
    _navigateToHome();
  }

  Future<void> _saveSession(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', _role);
      await prefs.setString('user_name', _userName);
      ApiService.setToken(token);
    } catch (_) {}
  }

  void _navigateToHome() {
    if (!mounted) return;
    try {
      Widget destination;
      switch (_role) {
        case 'doctor':
        case 'nurse':
        case 'reception':
          destination = HmsShell(role: _role, userName: _userName);
          break;
        case 'moh':
          destination = MohShell(userName: _userName);
          break;
        default:
          destination = ServiceGatewayScreen(
            userName: _userName,
            nationalId: _idController.text.trim(),
          );
      }
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, anim, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
              child: child,
            );
          },
        ),
        (_) => false,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Fallback: direct replacement
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => ServiceGatewayScreen(
              userName: _userName,
              nationalId: _idController.text.trim(),
            ),
          ),
          (_) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _passportController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Direct validation — no _formKey needed (AnimatedSwitcher breaks GlobalKey)
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل رقم الهوية', textDirection: TextDirection.rtl),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل كلمة المرور', textDirection: TextDirection.rtl),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Role-based hardcoded login from national ID password
    String? role;
    String userName = '';
    const token = 'local-session-token';

    switch (password) {
      case '1234':
        role = 'citizen';
        userName = 'محمد أحمد';
        break;
      case '12345':
        role = 'doctor';
        userName = 'د. سارة الخطيب';
        break;
      case '123456':
        role = 'moh';
        userName = 'مسؤول وزارة الصحة';
        break;
      case '1234567':
        role = 'nurse';
        userName = 'نور حسين';
        break;
      case '123456789':
        role = 'reception';
        userName = 'مسؤول النظام';
        break;
      default:
        role = null;
    }

    if (role == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'كلمة المرور غير صحيحة',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    _role = role;
    _userName = userName;
    ApiService.setToken(token);
    await _saveSession(token);

    setState(() {
      _isLoading = false;
      _showSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    // Prompt to enable biometric if available and not yet enabled
    if (_biometricAvailable && !_biometricEnabled) {
      _promptEnableBiometric();
    } else {
      _navigateToHome();
    }
  }

  // ── OTP Phone Login ───────────────────────────────────
  Future<void> _handleOtpRequest() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رقم هاتف صحيح (9 أرقام على الأقل)'),
          backgroundColor: Color(0xFF4F46E5),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    final otp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000)
        .toString();
    _generatedOtp = otp;
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _otpSent = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرسال رمز التحقق لـ $phone\n(للتجربة: $otp)'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 7),
      ),
    );
  }

  Future<void> _handleOtpVerify() async {
    if (_otpController.text.trim() != _generatedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رمز التحقق غير صحيح، يرجى المحاولة مجدداً'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    const token = 'otp-verified-session-token';
    ApiService.setToken(token);
    _role = 'citizen';
    _userName = 'مستخدم ترياق';
    await _saveSession(token);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _showSuccess = true;
    });
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    if (_biometricAvailable && !_biometricEnabled) {
      _promptEnableBiometric();
    } else {
      _navigateToHome();
    }
  }

  // ── Resident Login (passport/iqama, no national ID) ──
  Future<void> _handleResidentLogin() async {
    final doc = _passportController.text.trim();
    if (doc.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رقم الجواز أو الإقامة صحيحاً'),
          backgroundColor: Color(0xFF4F46E5),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    const token = 'resident-access-token';
    ApiService.setToken(token);
    _role = 'citizen';
    _userName = 'مقيم / زائر';
    await _saveSession(token);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _showSuccess = true;
    });
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    _navigateToHome();
  }

  Future<void> _handleIdLogin() async {
    if (_idController.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'يرجى إدخال رقم هوية صحيح',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: _tealPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    const token = 'id-login-session-token';
    _role = 'citizen';
    _userName = 'مواطن — ${_idController.text.trim()}';

    ApiService.setToken(token);
    await _saveSession(token);

    setState(() {
      _isLoading = false;
      _showSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    // Prompt to enable biometric if available and not yet enabled
    if (_biometricAvailable && !_biometricEnabled) {
      _promptEnableBiometric();
    } else {
      _navigateToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: _tealDark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          body: Stack(
            children: [
              // ─── Animated Gradient Background ──────────────
              AnimatedBuilder(
                animation: _bgAnim,
                builder: (context, _) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(
                          const Color(0xFF312E81),
                          const Color(0xFF3730A3),
                          _bgAnim.value,
                        )!,
                        Color.lerp(
                          const Color(0xFF1E1B4B),
                          const Color(0xFF312E81),
                          _bgAnim.value,
                        )!,
                        Color.lerp(
                          const Color(0xFF0C4A6E),
                          const Color(0xFF164E63),
                          _bgAnim.value,
                        )!,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // ─── Decorative Circles (3D depth) ─────────────
              Positioned(
                top: -80,
                right: -60,
                child: AnimatedBuilder(
                  animation: _bgAnim,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      8 * math.sin(_bgAnim.value * math.pi),
                      6 * math.cos(_bgAnim.value * math.pi),
                    ),
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _tealAccent.withAlpha(30),
                            _tealAccent.withAlpha(5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: AnimatedBuilder(
                  animation: _bgAnim,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      -6 * math.cos(_bgAnim.value * math.pi),
                      8 * math.sin(_bgAnim.value * math.pi),
                    ),
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _blueLight.withAlpha(25),
                            _blueLight.withAlpha(3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Subtle Grid Pattern ───────────────────────
              CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _MedicalGridPainter(),
              ),

              // ─── Main Content ──────────────────────────────
              SafeArea(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          12,
                          24,
                          bottomPad + 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCompactHeader(),
                            const SizedBox(height: 20),
                            _buildLoginCard(),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Success Overlay ───────────────────────────
              if (_showSuccess) _buildSuccessOverlay(),

              // ─── Biometric Enable Prompt ───────────────────
              if (_showBiometricPrompt) _buildBiometricPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Compact Header ─────────────────────────────────────
  Widget _buildCompactHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(30), width: 1),
          ),
          child: const Icon(
            Icons.healing_rounded,
            color: _tealAccent,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ترياق',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            Text(
              'Smart Health — الأردن',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(140),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Login Card ─────────────────────────────────────────
  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(35),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Subtle top accent line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 3,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_tealAccent, _tealPrimary, _blueLight],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _showOtpLogin
                    ? _buildOtpForm()
                    : _showResidentLogin
                    ? _buildResidentForm()
                    : _showIdLogin
                    ? _buildIdForm()
                    : _buildEmailForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── National ID + Password Form ─────────────────────────
  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Compact role hint — expandable
          _buildRoleHints(),
          const SizedBox(height: 16),

          // National ID Field
          _buildLabel('رقم الهوية الوطنية'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _idController,
            hint: '9 8 7 6 5 4 3 2 1 0',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'أدخل رقم الهوية';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Password Field
          _buildLabel('كلمة المرور'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _passwordController,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            textDirection: TextDirection.ltr,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _textSecondary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Login Button
          _buildPrimaryButton(
            label: 'تسجيل الدخول',
            icon: Icons.login_rounded,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 14),

          // Divider
          _buildDivider(),
          const SizedBox(height: 14),

          // Alt login buttons in a row
          Row(
            children: [
              Expanded(
                child: _buildCompactAltButton(
                  label: 'رمز SMS',
                  icon: Icons.sms_rounded,
                  onPressed: () => setState(() => _showOtpLogin = true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCompactAltButton(
                  label: 'مقيم / زائر',
                  icon: Icons.travel_explore_rounded,
                  onPressed: () => setState(() => _showResidentLogin = true),
                ),
              ),
            ],
          ),

          // Biometric Quick Login
          if (_biometricAvailable && _biometricEnabled) ...[
            const SizedBox(height: 12),
            _buildBiometricButton(),
          ],
        ],
      ),
    );
  }

  bool _roleHintsExpanded = false;

  Widget _buildRoleHints() {
    return GestureDetector(
      onTap: () => setState(() => _roleHintsExpanded = !_roleHintsExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _tealAccent.withAlpha(8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _tealAccent.withAlpha(25)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: _tealAccent,
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'كلمات المرور التجريبية',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _tealPrimary,
                    ),
                  ),
                ),
                Icon(
                  _roleHintsExpanded ? Icons.expand_less : Icons.expand_more,
                  color: _tealPrimary,
                  size: 20,
                ),
              ],
            ),
            if (_roleHintsExpanded) ...[
              const SizedBox(height: 6),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                },
                children: [
                  _roleHintRow('👤 مريض', '1234'),
                  _roleHintRow('🩺 دكتور', '12345'),
                  _roleHintRow('🏛️ وزارة الصحة', '123456'),
                  _roleHintRow('💉 تمريض', '1234567'),
                  _roleHintRow('🖥️ استقبال', '123456789'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactAltButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _inputBorder, width: 1.2),
        color: _surface,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: _tealAccent.withAlpha(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _blueLight, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _roleHintRow(String role, String pass) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            role,
            style: const TextStyle(fontSize: 11, color: _textSecondary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            pass,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _tealPrimary,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  // ─── National ID Form ───────────────────────────────────
  Widget _buildIdForm() {
    return Column(
      key: const ValueKey('id-form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back to email
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => setState(() => _showIdLogin = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _inputFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: _tealPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'العودة للبريد',
                    style: TextStyle(
                      fontSize: 13,
                      color: _tealPrimary.withAlpha(200),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ID Badge
        Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_blueLight, _blueDark],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _blueDark.withAlpha(50),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.credit_card_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'الدخول برقم الهوية الوطنية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildLabel('رقم الهوية الوطنية'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _idController,
          hint: '9 8 7 6 5 4 3 2 1 0',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        const SizedBox(height: 20),

        _buildPrimaryButton(
          label: 'تسجيل الدخول',
          icon: Icons.login_rounded,
          onPressed: _handleIdLogin,
        ),
      ],
    );
  }

  // ─── OTP SMS Form ──────────────────────────────────────
  Widget _buildOtpForm() {
    return Column(
      key: const ValueKey('otp-form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => setState(() {
              _showOtpLogin = false;
              _otpSent = false;
              _generatedOtp = '';
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _inputFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: _tealPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'العودة',
                    style: TextStyle(
                      fontSize: 13,
                      color: _tealPrimary.withAlpha(200),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF059669).withAlpha(50),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.sms_rounded, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'الدخول برمز SMS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!_otpSent) ...[
          _buildLabel('رقم الهاتف'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _phoneController,
            hint: '07X XXX XXXX',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 20),
          _buildPrimaryButton(
            label: 'إرسال رمز التحقق',
            icon: Icons.send_rounded,
            onPressed: _handleOtpRequest,
          ),
        ] else ...[
          _buildLabel('رمز التحقق'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _otpController,
            hint: '------',
            icon: Icons.lock_clock_outlined,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
          const SizedBox(height: 20),
          _buildPrimaryButton(
            label: 'تحقق وادخل',
            icon: Icons.verified_rounded,
            onPressed: _handleOtpVerify,
          ),
          const SizedBox(height: 12),
          _buildSecondaryButton(
            label: 'إعادة إرسال الرمز',
            icon: Icons.refresh_rounded,
            onPressed: () => setState(() {
              _otpSent = false;
              _generatedOtp = '';
              _otpController.clear();
            }),
          ),
        ],
      ],
    );
  }

  // ─── Resident / Non-National-ID Form ──────────────────
  Widget _buildResidentForm() {
    return Column(
      key: const ValueKey('resident-form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => setState(() => _showResidentLogin = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _inputFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: _tealPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'العودة',
                    style: TextStyle(
                      fontSize: 13,
                      color: _tealPrimary.withAlpha(200),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6D28D9).withAlpha(50),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'دخول المقيمين والزوار',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLabel('رقم الجواز أو الإقامة'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _passportController,
          hint: 'AB1234567',
          icon: Icons.document_scanner_outlined,
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 20),
        _buildPrimaryButton(
          label: 'تسجيل الدخول كمقيم',
          icon: Icons.login_rounded,
          onPressed: _handleResidentLogin,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    TextDirection? textDirection,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _tealPrimary.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textDirection: textDirection,
        inputFormatters: inputFormatters,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          color: _textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: _textSecondary.withAlpha(120),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 12, left: 8),
            child: Icon(icon, color: _tealPrimary, size: 22),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: _inputFill,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _inputBorder, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _inputBorder, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _tealAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [_tealPrimary, _tealLight, _tealAccent],
        ),
        boxShadow: [
          BoxShadow(
            color: _tealPrimary.withAlpha(55),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withAlpha(40),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _inputBorder, width: 1.5),
        color: _surface,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          splashColor: _tealAccent.withAlpha(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _blueLight.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _blueLight, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, _inputBorder.withAlpha(120)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'أو',
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary.withAlpha(160),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_inputBorder.withAlpha(120), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Biometric Login Button ──────────────────────────
  Widget _buildBiometricButton() {
    return GestureDetector(
      onTap: _authenticateWithBiometric,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _tealAccent.withAlpha(12),
          border: Border.all(color: _tealAccent.withAlpha(40), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _tealAccent.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                color: _tealAccent,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'تسجيل بالبصمة / الوجه',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _tealPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Biometric Enable Prompt ────────────────────────────
  Widget _buildBiometricPrompt() {
    return AnimatedOpacity(
      opacity: _showBiometricPrompt ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.black.withAlpha(140),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (_, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 36),
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _tealAccent.withAlpha(30),
                    blurRadius: 50,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_tealAccent, _tealPrimary],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: _tealAccent.withAlpha(50),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تفعيل الدخول بالبصمة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'هل تريد تسجيل الدخول في المرات القادمة\nباستخدام بصمة الإصبع أو الوجه؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondary.withAlpha(180),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Enable button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [_tealPrimary, _tealAccent],
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _saveBiometricPreference(true),
                          borderRadius: BorderRadius.circular(14),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fingerprint_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'نعم، فعّل البصمة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Skip button
                  TextButton(
                    onPressed: () => _saveBiometricPreference(false),
                    child: Text(
                      'ليس الآن',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary.withAlpha(160),
                      ),
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

  // ─── Success Overlay ────────────────────────────────────
  Widget _buildSuccessOverlay() {
    return AnimatedOpacity(
      opacity: _showSuccess ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        color: Colors.black.withAlpha(120),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (_, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _tealAccent.withAlpha(40),
                    blurRadius: 60,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_success, _tealAccent],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: _success.withAlpha(60),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تم التحقق',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'مرحباً، ${_userName.isNotEmpty ? _userName : 'بك'} 👋',
                    style: const TextStyle(
                      fontSize: 17,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'جاري تحميل بياناتك الصحية...',
                    style: TextStyle(
                      fontSize: 13,
                      color: _textSecondary.withAlpha(140),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(_tealAccent),
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

// ─── Background Medical Grid ────────────────────────────────
class _MedicalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(8)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw subtle medical crosses at intersections
    final crossPaint = Paint()
      ..color = Colors.white.withAlpha(12)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double x = spacing * 3; x < size.width; x += spacing * 4) {
      for (double y = spacing * 3; y < size.height; y += spacing * 5) {
        _drawCross(canvas, Offset(x, y), 5, crossPaint);
      }
    }
  }

  void _drawCross(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
