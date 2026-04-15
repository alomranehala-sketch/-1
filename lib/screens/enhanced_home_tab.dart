import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart';
import '../services/theme_service.dart';
import 'ai_assistant_screen.dart';
import 'appointment_reminder_screen.dart';
import 'blood_donation_screen.dart';
import 'chronic_care_screen.dart';
import 'devices_screen.dart';
import 'family_sharing_screen.dart';
import 'health_tips_screen.dart';
import 'home_services_screen.dart';
import 'lab_results_screen.dart';
import 'medical_record_tab.dart';
import 'medications_screen.dart';
import 'medication_delivery_screen.dart';
import 'notifications_screen.dart';
import 'search_screen.dart';
import 'wallet_tab.dart';
import 'chat_list_screen.dart';
import 'health_passport_screen.dart';
import 'smart_booking_screen.dart';
import 'ai_triage_screen.dart';
import 'live_queue_screen.dart';
import 'digital_referral_screen.dart';
import 'telemedicine_screen.dart';
import 'insurance_calculator_screen.dart';
import 'pharmacy_stock_screen.dart';
import 'hospital_resources_screen.dart';
import 'ai_health_coach_screen.dart';
import 'symptom_analyzer_screen.dart';
import 'voice_reviews_screen.dart';
import 'national_dashboard_screen.dart';
import 'school_health_screen.dart';
import 'emergency_heatmap_screen.dart';
import 'drug_interaction_screen.dart';
import 'health_gamification_screen.dart';
import 'monthly_health_report_screen.dart';
import 'digital_twin_screen.dart';

class EnhancedHomeTab extends StatefulWidget {
  const EnhancedHomeTab({super.key});
  @override
  State<EnhancedHomeTab> createState() => _EnhancedHomeTabState();
}

class _EnhancedHomeTabState extends State<EnhancedHomeTab>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _fadeCtrl;
  String _userName = '';
  String _userInitial = 'م';
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _medications = [];

  // Voice recognition
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _loadData();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _isListening = false);
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
  }

  void _startVoiceSearch() {
    HapticFeedback.mediumImpact();
    if (!_speechAvailable) {
      // Fallback: open search screen
      _go(const SearchScreen());
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _VoiceSearchSheet(
        speech: _speech,
        onResult: (text) {
          Navigator.pop(context);
          if (text.isNotEmpty) {
            _go(const SearchScreen());
          }
        },
      ),
    );
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getProfile(),
        ApiService.getAppointments(),
        ApiService.getNotifications(),
        ApiService.getMedications(),
      ]);
      if (!mounted) return;
      final profile = results[0] as Map<String, dynamic>;
      setState(() {
        _userName = (profile['name'] as String?) ?? '';
        _userInitial = _userName.isNotEmpty ? _userName[0] : 'م';
        _appointments = (results[1] as List).cast();
        _notifications = (results[2] as List).cast();
        _medications = (results[3] as List).cast();
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final unread = _notifications.where((n) => n['read'] != true).length;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFF818CF8),
            backgroundColor: const Color(0xFF1E293B),
            child: FadeTransition(
              opacity: _fadeCtrl,
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(),
                children: [
                  _heroHeader(top, unread),
                  _searchBar(),
                  _healthVitalsSection(),
                  _aiAdvisorCard(),
                  _dailyHealthTip(),
                  _quickServicesSection(),
                  _bloodDonationBanner(),
                  _appointmentSection(),
                  _medicationsCompact(),
                  _healthProgressTracker(),
                  _exploreSection(),
                  _emergencySection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══ HERO HEADER ═══════════════════════════════════════════
  Widget _heroHeader(double topPad, int unread) {
    final hour = DateTime.now().hour;
    final greet = hour < 6
        ? 'ليلة سعيدة'
        : hour < 12
        ? 'صباح الخير'
        : hour < 17
        ? 'مساء النور'
        : 'مساء الخير';
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _go(const NotificationsScreen()),
                child: Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withAlpha(8)),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ),
                    if (unread > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              // ─── Theme color switcher ───
              GestureDetector(
                onTap: _showThemePicker,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ThemeService().primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ThemeService().primary.withAlpha(40),
                    ),
                  ),
                  child: Icon(
                    Icons.palette_rounded,
                    color: ThemeService().primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      ThemeService().primary,
                      ThemeService().primaryLight,
                    ],
                  ),
                  border: Border.all(
                    color: ThemeService().primaryLight.withAlpha(60),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _userInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$greet 👋',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _userName.isEmpty
                  ? 'أهلاً بك'
                  : 'أهلاً ${_userName.split(' ').first}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'عمّان، الأردن',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '· 26°C',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '· ${_formattedDate()}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══ SEARCH BAR ════════════════════════════════════════════
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GestureDetector(
        onTap: () => _go(const SearchScreen()),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withAlpha(8)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(
                Icons.search_rounded,
                color: Color(0xFF64748B),
                size: 20,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'ابحث عن طبيب، خدمة، أو دواء...',
                  style: TextStyle(color: Color(0xFF475569), fontSize: 13),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _startVoiceSearch();
                },
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    color: _isListening
                        ? const Color(0xFFEF4444).withAlpha(20)
                        : const Color(0xFF6366F1).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_rounded,
                    color: _isListening
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF818CF8),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }

  // ═══ AI HEALTH ADVISOR ═════════════════════════════════════
  Widget _aiAdvisorCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () => _go(const AIAssistantScreen()),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF6366F1).withAlpha(40)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withAlpha(10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 6),
                        SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'مستشار الذكاء الاصطناعي',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (context, child) {
                      return Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(
                                0xFF6366F1,
                              ).withAlpha(80 + (_pulseCtrl.value * 40).round()),
                              const Color(
                                0xFF818CF8,
                              ).withAlpha(60 + (_pulseCtrl.value * 30).round()),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFFBBF24),
                          size: 20,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'AI Health Advisor',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
              const SizedBox(height: 10),
              Text(
                _appointments.isNotEmpty
                    ? 'لديك موعد قريب — لا تنسَ الفحوصات المطلوبة. صحتك ممتازة، واصل الحفاظ على نمط حياتك الصحي 💪'
                    : 'بناءً على بياناتك الصحية — ننصحك بفحص دوري. الجو حلو اليوم 🌤️ موعد مثالي، ازدحام أقل.',
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══ QUICK SERVICES ════════════════════════════════════════
  Widget _quickServicesSection() {
    final svcs = [
      _Q(
        'جواز الصحة',
        Icons.qr_code_scanner_rounded,
        const Color(0xFF06B6D4),
        () => _go(const HealthPassportScreen()),
      ),
      _Q(
        'حجز ذكي',
        Icons.calendar_month_rounded,
        const Color(0xFF10B981),
        () => _go(const SmartBookingScreen()),
      ),
      _Q(
        'فرز AI',
        Icons.psychology_rounded,
        const Color(0xFFEF4444),
        () => _go(const AiTriageScreen()),
      ),
      _Q(
        'دور مباشر',
        Icons.timer_rounded,
        const Color(0xFFF59E0B),
        () => _go(const LiveQueueScreen()),
      ),
      _Q(
        'سجلي الطبي',
        Icons.folder_shared_rounded,
        const Color(0xFF6366F1),
        () => _go(const MedicalRecordTab()),
      ),
      _Q(
        'التحاليل',
        Icons.biotech_rounded,
        const Color(0xFF3B82F6),
        () => _go(const LabResultsScreen()),
      ),
      _Q(
        'الأدوية',
        Icons.medication_rounded,
        const Color(0xFF10B981),
        () => _go(const MedicationsScreen()),
      ),
      _Q(
        'المحفظة',
        Icons.account_balance_wallet_rounded,
        const Color(0xFFF59E0B),
        () => _go(const WalletTab()),
      ),
      _Q(
        'توصيل الدواء',
        Icons.delivery_dining_rounded,
        const Color(0xFFEF4444),
        () => _go(const MedicationDeliveryScreen()),
      ),
      _Q(
        'تليميديسين',
        Icons.videocam_rounded,
        const Color(0xFF8B5CF6),
        () => _go(const TelemedicineScreen()),
      ),
      _Q(
        'تبرع بالدم',
        Icons.bloodtype_rounded,
        const Color(0xFFEF4444),
        () => _go(const BloodDonationScreen()),
      ),
      _Q(
        'خريطة الطوارئ',
        Icons.local_fire_department_rounded,
        const Color(0xFFFF6B35),
        () => _go(const EmergencyHeatmapScreen()),
      ),
      _Q(
        'تعارض أدوية',
        Icons.shield_rounded,
        const Color(0xFFE11D48),
        () => _go(const DrugInteractionScreen()),
      ),
      _Q(
        'نقاطي الصحية',
        Icons.emoji_events_rounded,
        const Color(0xFF7C3AED),
        () => _go(const HealthGamificationScreen()),
      ),
      _Q(
        'تقرير شهري',
        Icons.analytics_rounded,
        const Color(0xFF059669),
        () => _go(const MonthlyHealthReportScreen()),
      ),
      _Q(
        'التوأم الرقمي',
        Icons.view_in_ar_rounded,
        const Color(0xFF0EA5E9),
        () => _go(const DigitalTwinScreen()),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _secTitle('الخدمات السريعة'),
              GestureDetector(
                onTap: () => _go(const SearchScreen()),
                child: const Text(
                  'عرض الكل →',
                  style: TextStyle(
                    color: Color(0xFF818CF8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: svcs
                .take(8)
                .map(
                  (s) => GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      s.onTap();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: s.c.withAlpha(20)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [s.c.withAlpha(20), s.c.withAlpha(10)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: s.c.withAlpha(25)),
                            ),
                            child: Icon(s.ic, color: s.c, size: 22),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.t,
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ═══ APPOINTMENTS ══════════════════════════════════════════
  Widget _appointmentSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _secTitle('الموعد القادم'),
          const SizedBox(height: 10),
          if (_appointments.isEmpty)
            _emptyCard(
              Icons.event_available_rounded,
              'لا مواعيد حالياً',
              'احجز موعدك الآن',
              const Color(0xFF6366F1),
            )
          else
            _appointmentCard(_appointments.first),
        ],
      ),
    );
  }

  Widget _appointmentCard(Map<String, dynamic> a) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(6)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  (a['date'] ?? 'غداً').toString(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  (a['time'] ?? '10:30').toString().split(' ').first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (a['doctor'] ?? 'د. أحمد').toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (a['specialty'] ?? 'طب عام').toString(),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _miniBtn(Icons.videocam_rounded, const Color(0xFF10B981)),
          const SizedBox(width: 6),
          _miniBtn(Icons.chat_rounded, const Color(0xFF3B82F6)),
        ],
      ),
    );
  }

  Widget _miniBtn(IconData ic, Color c) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: c.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withAlpha(25)),
      ),
      child: Icon(ic, color: c, size: 16),
    );
  }

  // ═══ COMPACT MEDICATIONS CARD ═══════════════════════════
  Widget _medicationsCompact() {
    final count = _medications.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () => _go(const MedicationsScreen()),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF10B981).withAlpha(25)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'أدويتي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      count > 0
                          ? '$count أدوية مسجلة'
                          : 'لا أدوية مسجلة — أضف أدويتك',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF64748B),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══ EXPLORE GRID ══════════════════════════════════════════
  Widget _exploreSection() {
    final items = [
      _Q(
        'تحويل رقمي',
        Icons.swap_horiz_rounded,
        const Color(0xFF6366F1),
        () => _go(const DigitalReferralScreen()),
      ),
      _Q(
        'حاسبة التأمين',
        Icons.calculate_rounded,
        const Color(0xFF3B82F6),
        () => _go(const InsuranceCalculatorScreen()),
      ),
      _Q(
        'مخزون الصيدليات',
        Icons.local_pharmacy_rounded,
        const Color(0xFF10B981),
        () => _go(const PharmacyStockScreen()),
      ),
      _Q(
        'موارد المستشفيات',
        Icons.dashboard_rounded,
        const Color(0xFFEF4444),
        () => _go(const HospitalResourcesScreen()),
      ),
      _Q(
        'مدرب صحي AI',
        Icons.health_and_safety_rounded,
        const Color(0xFF8B5CF6),
        () => _go(const AiHealthCoachScreen()),
      ),
      _Q(
        'تحليل صور AI',
        Icons.image_search_rounded,
        const Color(0xFFF59E0B),
        () => _go(const SymptomAnalyzerScreen()),
      ),
      _Q(
        'تقييمات المرضى',
        Icons.record_voice_over_rounded,
        const Color(0xFF06B6D4),
        () => _go(const VoiceReviewsScreen()),
      ),
      _Q(
        'صحة المدارس',
        Icons.school_rounded,
        const Color(0xFF10B981),
        () => _go(const SchoolHealthScreen()),
      ),
      _Q(
        'لوحة الأردن',
        Icons.analytics_rounded,
        const Color(0xFF3B82F6),
        () => _go(const NationalDashboardScreen()),
      ),
      _Q(
        'الأمراض المزمنة',
        Icons.monitor_heart_rounded,
        const Color(0xFFEF4444),
        () => _go(const ChronicCareScreen()),
      ),
      _Q(
        'نصائح صحية',
        Icons.lightbulb_rounded,
        const Color(0xFF10B981),
        () => _go(const HealthTipsScreen()),
      ),
      _Q(
        'تذكيرات',
        Icons.alarm_rounded,
        const Color(0xFF3B82F6),
        () => _go(const AppointmentReminderScreen()),
      ),
      _Q(
        'أجهزة ذكية',
        Icons.watch_rounded,
        const Color(0xFF8B5CF6),
        () => _go(const DevicesScreen()),
      ),
      _Q(
        'ربط العائلة',
        Icons.family_restroom_rounded,
        const Color(0xFFEC4899),
        () => _go(const FamilySharingScreen()),
      ),
      _Q(
        'خدمات منزلية',
        Icons.home_rounded,
        const Color(0xFF14B8A6),
        () => _go(const HomeServicesScreen()),
      ),
      _Q(
        'المحادثات',
        Icons.chat_bubble_rounded,
        const Color(0xFF6366F1),
        () => _go(const ChatListScreen()),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _secTitle('استكشف المزيد'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: items
                .map(
                  (s) => GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      s.onTap();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: s.c.withAlpha(20)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: s.c.withAlpha(15),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(s.ic, color: s.c, size: 20),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.t,
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ═══ EMERGENCY ═════════════════════════════════════════════
  Widget _emergencySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.heavyImpact();
          try {
            (context.findAncestorStateOfType<State>() as dynamic).switchToMap();
          } catch (_) {}
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withAlpha(20),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طوارئ — أقرب مستشفى',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'اضغط للتنقل فوراً',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.navigation_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══ HELPERS ═══════════════════════════════════════════════
  Widget _secTitle(String t) => Text(
    t,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w800,
    ),
  );

  Widget _emptyCard(IconData ic, String title, String sub, Color c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(6)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(ic, color: c, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sub,
                  style: TextStyle(
                    color: c,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.add_circle_outline_rounded, color: c, size: 22),
        ],
      ),
    );
  }

  void _showThemePicker() {
    HapticFeedback.mediumImpact();
    final ts = ThemeService();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'اختر لون التطبيق',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppThemeColor.values.map((t) {
                  final p = ThemeService.palettes[t]!;
                  final sel = ts.currentTheme == t;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ts.setTheme(t);
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 96,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel
                            ? p.primary.withAlpha(25)
                            : Colors.white.withAlpha(6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: sel ? p.primary : Colors.white.withAlpha(10),
                          width: sel ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: p.gradient,
                              shape: BoxShape.circle,
                              border: sel
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                            child: sel
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.labelAr,
                            style: TextStyle(
                              color: sel ? p.primary : const Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  // ═══ BLOOD DONATION BANNER ══════════════════════════════════
  Widget _bloodDonationBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _go(const BloodDonationScreen());
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7F1D1D), Color(0xFF991B1B)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEF4444).withAlpha(30)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withAlpha(15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🩸', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'التبرع بالدم ينقذ حياة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '5 طلبات عاجلة — تبرع الآن',
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'تبرع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══ DATE HELPER ════════════════════════════════════════════
  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    const days = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]}';
  }

  // ═══ HEALTH VITALS CARDS ══════════════════════════════════
  Widget _healthVitalsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _secTitle('حالتك الصحية'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _vitalCard(
                  '❤️',
                  'نبض القلب',
                  '72',
                  'bpm',
                  const Color(0xFFEF4444),
                  const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _vitalCard(
                  '🚶',
                  'الخطوات',
                  '6,240',
                  'خطوة',
                  const Color(0xFF10B981),
                  const Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _vitalCard(
                  '😴',
                  'النوم',
                  '7.5',
                  'ساعة',
                  const Color(0xFF8B5CF6),
                  const Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _vitalCard(
                  '💧',
                  'الماء',
                  '5',
                  'أكواب',
                  const Color(0xFF06B6D4),
                  const Color(0xFF0891B2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vitalCard(
    String emoji,
    String label,
    String value,
    String unit,
    Color c1,
    Color c2,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c1.withAlpha(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'طبيعي',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: c1,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ═══ DAILY HEALTH TIP ═════════════════════════════════════
  Widget _dailyHealthTip() {
    final tips = [
      {
        'tip': 'اشرب 8 أكواب ماء يومياً للحفاظ على نشاطك وترطيب جسمك 💧',
        'cat': 'ترطيب',
      },
      {
        'tip': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب بنسبة 35% 🏃',
        'cat': 'رياضة',
      },
      {
        'tip': 'النوم 7-8 ساعات يعزز المناعة ويحسن التركيز والذاكرة 😴',
        'cat': 'نوم',
      },
      {'tip': 'تناول 5 حصص فواكه وخضروات يومياً لصحة أفضل 🥗', 'cat': 'تغذية'},
      {'tip': 'فحص ضغط الدم بانتظام يحميك من مضاعفات خطيرة 🩺', 'cat': 'وقاية'},
      {
        'tip': 'التأمل 10 دقائق يومياً يقلل التوتر والقلق بشكل ملحوظ 🧘',
        'cat': 'صحة نفسية',
      },
      {
        'tip': 'غسل اليدين بالصابون 20 ثانية يقي من 80% من الأمراض المعدية 🧼',
        'cat': 'نظافة',
      },
    ];
    final todayTip = tips[DateTime.now().day % tips.length];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A2F), Color(0xFF1E293B)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF10B981).withAlpha(30)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'نصيحة اليوم',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withAlpha(15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          todayTip['cat']!,
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    todayTip['tip']!,
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 12,
                      height: 1.6,
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

  // ═══ HEALTH PROGRESS TRACKER ══════════════════════════════
  Widget _healthProgressTracker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _secTitle('أهدافك الصحية'),
              Text(
                'هذا الأسبوع',
                style: TextStyle(color: const Color(0xFF64748B), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(6)),
            ),
            child: Column(
              children: [
                _progressRow(
                  'الخطوات اليومية',
                  0.62,
                  '6,240 / 10,000',
                  const Color(0xFF10B981),
                  Icons.directions_walk_rounded,
                ),
                const SizedBox(height: 14),
                _progressRow(
                  'شرب الماء',
                  0.63,
                  '5 / 8 أكواب',
                  const Color(0xFF06B6D4),
                  Icons.water_drop_rounded,
                ),
                const SizedBox(height: 14),
                _progressRow(
                  'ساعات النوم',
                  0.94,
                  '7.5 / 8 ساعات',
                  const Color(0xFF8B5CF6),
                  Icons.bedtime_rounded,
                ),
                const SizedBox(height: 14),
                _progressRow(
                  'التمارين',
                  0.40,
                  '2 / 5 أيام',
                  const Color(0xFFF59E0B),
                  Icons.fitness_center_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressRow(
    String label,
    double progress,
    String detail,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    detail,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withAlpha(20),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _go(Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (ctx, a1, a2) => screen,
        transitionsBuilder: (ctx, anim, a2, child) {
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _Q {
  final String t;
  final IconData ic;
  final Color c;
  final VoidCallback onTap;
  const _Q(this.t, this.ic, this.c, this.onTap);
}

class _VoiceSearchSheet extends StatefulWidget {
  final stt.SpeechToText speech;
  final ValueChanged<String> onResult;
  const _VoiceSearchSheet({required this.speech, required this.onResult});
  @override
  State<_VoiceSearchSheet> createState() => _VoiceSearchSheetState();
}

class _VoiceSearchSheetState extends State<_VoiceSearchSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  String _text = '';
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _startListening();
  }

  Future<void> _startListening() async {
    setState(() => _listening = true);
    await widget.speech.listen(
      onResult: (result) {
        setState(() => _text = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          widget.onResult(result.recognizedWords);
        }
      },
      localeId: 'ar_JO',
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    widget.speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, _) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(
                          0xFF6366F1,
                        ).withAlpha(80 + (_pulseCtrl.value * 60).round()),
                        const Color(
                          0xFF818CF8,
                        ).withAlpha(60 + (_pulseCtrl.value * 40).round()),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              _listening ? 'جاري الاستماع...' : 'اضغط للتحدث',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _text.isEmpty ? 'قل اسم طبيب أو خدمة أو مستشفى' : _text,
              style: TextStyle(
                color: _text.isEmpty
                    ? const Color(0xFF64748B)
                    : const Color(0xFF10B981),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}
