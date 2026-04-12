import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/enhanced_home_tab.dart' as home;
import 'screens/more_tab.dart';
import 'screens/map_tab.dart';
import 'screens/chat_list_screen.dart';
import 'screens/ai_assistant_screen.dart';
import 'services/locale_service.dart';
import 'services/grok_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final GlobalKey<MapTabState> _mapKey = GlobalKey<MapTabState>();
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  // Global voice agent
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechReady = false;
  bool _globalListening = false;
  bool _globalSpeaking = false;
  String _globalRecognized = '';
  String _globalReply = '';
  bool _globalProcessing = false;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const home.EnhancedHomeTab(), // 0
      MapTab(key: _mapKey), // 1
      const ChatListScreen(asTab: true), // 2
      const MoreTab(), // 3
    ];
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _fabController.forward();
    _initGlobalVoice();
  }

  Future<void> _initGlobalVoice() async {
    try {
      _speechReady = await _speech.initialize();
      await _tts.setLanguage('ar');
      await _tts.setSpeechRate(0.5);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _globalSpeaking = false);
      });
      _tts.setCancelHandler(() {
        if (mounted) setState(() => _globalSpeaking = false);
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _fabController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  void switchToMap({String? hospitalName}) {
    setState(() => _currentIndex = 1);
    if (hospitalName != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _mapKey.currentState?.focusOnHospital(hospitalName);
      });
    }
  }

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _onTabTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  void _openAIAssistant() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, _) => const AIAssistantScreen(),
        transitionsBuilder: (context, anim, _, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                ),
            child: FadeTransition(opacity: anim, child: child),
          );
        },
      ),
    );
  }

  void _openGlobalVoiceAgent() {
    HapticFeedback.heavyImpact();
    setState(() {
      _globalRecognized = '';
      _globalReply = '';
      _globalProcessing = false;
      _globalListening = false;
      _globalSpeaking = false;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GlobalVoiceSheet(parent: this),
    );
  }

  Future<void> _startGlobalListening(StateSetter setSheetState) async {
    if (!_speechReady) return;
    HapticFeedback.mediumImpact();
    setState(() => _globalListening = true);
    setSheetState(() {});
    await _speech.listen(
      onResult: (result) {
        setState(() => _globalRecognized = result.recognizedWords);
        setSheetState(() {});
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _processGlobalQuery(result.recognizedWords, setSheetState);
        }
      },
      localeId: 'ar_JO',
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  Future<void> _stopGlobalListening(StateSetter setSheetState) async {
    await _speech.stop();
    setState(() => _globalListening = false);
    setSheetState(() {});
  }

  Future<void> _processGlobalQuery(
    String text,
    StateSetter setSheetState,
  ) async {
    setState(() {
      _globalListening = false;
      _globalProcessing = true;
    });
    setSheetState(() {});
    try {
      final result = await GrokService.chat([
        {'role': 'user', 'content': text},
      ]);
      if (!mounted) return;
      final reply = result['reply'] as String? ?? 'حدث خطأ.';
      setState(() {
        _globalReply = reply;
        _globalProcessing = false;
      });
      setSheetState(() {});
      // Speak the reply
      final clean = reply
          .replaceAll(RegExp(r'[\u{1F000}-\u{1FFFF}]', unicode: true), '')
          .replaceAll(RegExp(r'[*#_~`>|]'), '')
          .trim();
      if (clean.isNotEmpty) {
        setState(() => _globalSpeaking = true);
        setSheetState(() {});
        await _tts.speak(clean);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _globalReply = '⚠️ تعذر الاتصال';
        _globalProcessing = false;
      });
      setSheetState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF0F172A),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: IndexedStack(index: _currentIndex, children: _screens),
          floatingActionButton: _buildFAB(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return ScaleTransition(
      scale: _fabScale,
      child: Container(
        margin: const EdgeInsets.only(top: 0),
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7C3AED), Color(0xFF6366F1), Color(0xFF3B82F6)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.white.withAlpha(40), width: 2),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openAIAssistant,
            onLongPress: _openGlobalVoiceAgent,
            customBorder: const CircleBorder(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🤖', style: TextStyle(fontSize: 20)),
                Text(
                  LocaleService().tr('teryaq'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
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

  // ═══════════════════════════════════════════════════════════
  //  Modern Bottom Navigation (4 tabs + center FAB)
  // ═══════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border(
          top: BorderSide(color: Colors.white.withAlpha(8), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, 'الرئيسية'),
              _navItem(1, Icons.map_rounded, Icons.map_outlined, 'الخريطة'),
              const SizedBox(width: 64), // FAB space
              _navItem(
                2,
                Icons.chat_rounded,
                Icons.chat_bubble_outline_rounded,
                'الرسائل',
                badge: 3,
              ),
              _navItem(
                3,
                Icons.grid_view_rounded,
                Icons.grid_view_rounded,
                'المزيد',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int idx,
    IconData active,
    IconData inactive,
    String label, {
    int badge = 0,
  }) {
    final sel = _currentIndex == idx;
    final color = sel ? const Color(0xFF818CF8) : Colors.white.withAlpha(90);
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTap(idx),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(sel ? active : inactive, color: color, size: 22),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1E293B),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Global Voice Agent Sheet
// ═══════════════════════════════════════════════════════════
class _GlobalVoiceSheet extends StatefulWidget {
  final AppShellState parent;
  const _GlobalVoiceSheet({required this.parent});
  @override
  State<_GlobalVoiceSheet> createState() => _GlobalVoiceSheetState();
}

class _GlobalVoiceSheetState extends State<_GlobalVoiceSheet> {
  @override
  Widget build(BuildContext context) {
    final p = widget.parent;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 80, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withAlpha(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6C3CE1),
                    Color(0xFF5B6CF0),
                    Color(0xFF4FADE0),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
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
                          'وكيل ترياق الصوتي 🎤',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'اسأل أي سؤال صحي بصوتك',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      p._speech.stop();
                      p._tts.stop();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Recognized text
                  if (p._globalRecognized.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C3CE1).withAlpha(15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF6C3CE1).withAlpha(30),
                        ),
                      ),
                      child: Text(
                        p._globalRecognized,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  // Processing
                  if (p._globalProcessing)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              color: Color(0xFF818CF8),
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'ترياق يفكّر...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Reply
                  if (p._globalReply.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A42),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withAlpha(8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: SingleChildScrollView(
                              child: Text(
                                p._globalReply,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(220),
                                  fontSize: 13,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                          if (p._globalSpeaking) ...[
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                await p._tts.stop();
                                p.setState(() => p._globalSpeaking = false);
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.stop_rounded,
                                      color: Color(0xFFEF4444),
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'إيقاف الصوت',
                                      style: TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Mic button
                  GestureDetector(
                    onTap: () {
                      if (p._globalListening) {
                        p._stopGlobalListening(setState);
                      } else {
                        p._tts.stop();
                        p.setState(() {
                          p._globalSpeaking = false;
                          p._globalReply = '';
                          p._globalRecognized = '';
                        });
                        p._startGlobalListening(setState);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: p._globalListening
                              ? [
                                  const Color(0xFFEF4444),
                                  const Color(0xFFDC2626),
                                ]
                              : [
                                  const Color(0xFF6C3CE1),
                                  const Color(0xFF5B6CF0),
                                ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (p._globalListening
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF6C3CE1))
                                    .withAlpha(60),
                            blurRadius: 24,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        p._globalListening
                            ? Icons.stop_rounded
                            : Icons.mic_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    p._globalListening
                        ? 'جاري الاستماع...'
                        : (p._globalReply.isEmpty
                              ? 'اضغط للتحدث'
                              : 'اضغط لسؤال جديد'),
                    style: TextStyle(
                      color: Colors.white.withAlpha(120),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Open full chat link
                  GestureDetector(
                    onTap: () {
                      p._speech.stop();
                      p._tts.stop();
                      Navigator.pop(context);
                      p._openAIAssistant();
                    },
                    child: Text(
                      'فتح المحادثة الكاملة ←',
                      style: TextStyle(
                        color: const Color(0xFF818CF8).withAlpha(200),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
}
