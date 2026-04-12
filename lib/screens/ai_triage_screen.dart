import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../theme.dart';
import '../services/grok_service.dart';
import 'smart_booking_screen.dart';
import 'telemedicine_screen.dart';
import 'live_queue_screen.dart';

/// AI Triage — الفرز الذكي بالذكاء الاصطناعي
/// Speak or type symptoms → AI tells you: ER, scheduled appointment, or telemedicine
class AiTriageScreen extends StatefulWidget {
  const AiTriageScreen({super.key});
  @override
  State<AiTriageScreen> createState() => _AiTriageScreenState();
}

class _AiTriageScreenState extends State<AiTriageScreen>
    with TickerProviderStateMixin {
  final _symptomsCtrl = TextEditingController();
  bool _analyzing = false;
  bool _showResult = false;
  String _triageLevel = '';
  String _triageAdvice = '';
  String _triageAction = '';
  Color _triageColor = AppColors.primary;
  IconData _triageIcon = Icons.health_and_safety;
  int _selectedBodyPart = -1;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _selectedModel = 'grok-3-mini';
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  final List<_ChatMsg> _chatMessages = [];
  late AnimationController _pulseCtrl;
  late AnimationController _resultCtrl;

  final _quickSymptoms = [
    'ألم في الصدر',
    'صداع شديد',
    'ضيق تنفس',
    'حرارة مرتفعة',
    'ألم بطن',
    'دوخة',
    'ألم ظهر',
    'سعال مستمر',
    'غثيان',
    'ألم مفاصل',
    'طفح جلدي',
    'خفقان قلب',
  ];

  final _bodyParts = [
    _BodyPart('الرأس', Icons.face_rounded, const Color(0xFF8B5CF6)),
    _BodyPart('الصدر', Icons.favorite_rounded, const Color(0xFFEF4444)),
    _BodyPart('البطن', Icons.square_rounded, const Color(0xFFF59E0B)),
    _BodyPart(
      'الظهر',
      Icons.accessibility_new_rounded,
      const Color(0xFF3B82F6),
    ),
    _BodyPart('الأطراف', Icons.back_hand_rounded, const Color(0xFF10B981)),
    _BodyPart('الجلد', Icons.spa_rounded, const Color(0xFF06B6D4)),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _resultCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _initSpeech();
    _initTts();
  }

  @override
  void dispose() {
    _tts.stop();
    _pulseCtrl.dispose();
    _resultCtrl.dispose();
    _symptomsCtrl.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize();
    } catch (_) {}
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ar');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.1);
    await _tts.setVolume(1.0);
    // Try to get the best Arabic voice — prefer Jordanian
    final voices = await _tts.getVoices as List<dynamic>?;
    if (voices != null) {
      final arJo = voices.firstWhere(
        (v) =>
            (v['locale'] as String? ?? '').contains('ar') &&
            (v['locale'] as String? ?? '').contains('JO'),
        orElse: () => null,
      );
      final arAny = voices.firstWhere(
        (v) => (v['locale'] as String? ?? '').startsWith('ar'),
        orElse: () => null,
      );
      final best = arJo ?? arAny;
      if (best != null) {
        await _tts.setVoice({
          'name': best['name'] as String,
          'locale': best['locale'] as String,
        });
      }
    }
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  void _startListening() async {
    HapticFeedback.mediumImpact();
    // Stop speaking first if talking
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    }
    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize();
      if (!_speechAvailable) return;
    }
    _showModelSheet();
  }

  void _showModelSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const Text(
                'اختار موديل الذكاء الاصطناعي 🤖',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'اختار الموديل وبعدين احكي أعراضك بالصوت',
                style: TextStyle(color: AppColors.textLight, fontSize: 12),
              ),
              const SizedBox(height: 16),
              _modelOption(
                'grok-3-mini',
                'Grok 3 Mini ⚡',
                'سريع وخفيف — يرد بسرعة عالأسئلة البسيطة',
                Icons.flash_on_rounded,
                const Color(0xFF10B981),
              ),
              const SizedBox(height: 8),
              _modelOption(
                'grok-4-1-fast-non-reasoning',
                'Grok 4.1 Fast 🧠',
                'أقوى وأدق — للتشخيص والحالات المعقدة',
                Icons.psychology_rounded,
                const Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modelOption(
    String id,
    String name,
    String desc,
    IconData icon,
    Color color,
  ) {
    final selected = _selectedModel == id;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedModel = id);
        Navigator.pop(context);
        _beginListening();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(20) : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : AppColors.border.withAlpha(40),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }

  void _beginListening() async {
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _symptomsCtrl.text = result.recognizedWords;
          if (result.finalResult) {
            _isListening = false;
            if (result.recognizedWords.isNotEmpty) {
              _analyzeWithGrok();
            }
          }
        });
      },
      localeId: 'ar',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _speakReply(String text) async {
    final clean = text.replaceAll(
      RegExp(
        r'[^\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF\s\d.,!?؟،٪\-:]',
      ),
      '',
    );
    if (clean.trim().isEmpty) return;
    setState(() => _isSpeaking = true);
    await _tts.speak(clean);
  }

  void _stopSpeaking() async {
    await _tts.stop();
    setState(() => _isSpeaking = false);
  }

  void _analyzeWithGrok() async {
    if (_symptomsCtrl.text.isEmpty) return;
    HapticFeedback.mediumImpact();

    final userText = _symptomsCtrl.text;
    setState(() {
      _analyzing = true;
      _showResult = false;
      _chatMessages.add(_ChatMsg(userText, isUser: true));
    });

    try {
      final triagePrompt =
          '''أنت دكتور فرز ذكي أردني. احكي بالأردني العامي الطبيعي زي ما الناس بتحكي بالأردن.

المريض حكالك أعراضه. مطلوب منك:
1. حدد مستوى الخطورة
2. اعطي نصيحة مختصرة بالأردني
3. قول شو يعمل هلأ

ابدأ ردك بكلمة المستوى بين قوسين:
- [طوارئ] لو الحالة خطيرة — لازم يروح مستشفى هلأ
- [حجز] لو الحالة بتحتاج دكتور خلال كم يوم
- [تليميديسين] لو الحالة بسيطة — ممكن استشارة عن بعد

خلي الكلام قصير ومفيد. لا تستخدم فصحى ولا مصطلحات طبية.
استخدم كلمات: "شو"، "هلأ"، "يزمي"، "إنشالله"، "يعني"، "تمام"

الأعراض: $userText${_selectedBodyPart >= 0 ? '\nمكان الألم: ${_bodyParts[_selectedBodyPart].name}' : ''}''';

      final messages = [
        {'role': 'user', 'content': triagePrompt},
      ];

      final result = await GrokService.chat(messages, model: _selectedModel);
      if (!mounted) return;

      final reply = result['reply'] as String? ?? 'عذراً، حدث خطأ';

      setState(() {
        _chatMessages.add(_ChatMsg(reply));
      });

      // Parse triage level from response
      if (reply.contains('[طوارئ]') ||
          reply.contains('طوارئ فوري') ||
          reply.contains('خطيرة جداً') ||
          reply.contains('عاجل')) {
        _setResult(
          'طوارئ فوري 🚨',
          reply.replaceAll(RegExp(r'\[.*?\]'), '').trim(),
          'روح طوارئ أقرب مستشفى حكومي فوراً',
          const Color(0xFFEF4444),
          Icons.emergency_rounded,
          'er',
        );
      } else if (reply.contains('[حجز]') ||
          reply.contains('عيادة') ||
          reply.contains('موعد')) {
        _setResult(
          'حجز عيادة ⚡',
          reply.replaceAll(RegExp(r'\[.*?\]'), '').trim(),
          'احجز عند دكتور خلال أيام',
          const Color(0xFFF59E0B),
          Icons.calendar_month_rounded,
          'booking',
        );
      } else {
        _setResult(
          'تليميديسين كافي 📱',
          reply.replaceAll(RegExp(r'\[.*?\]'), '').trim(),
          'استشارة فيديو مع دكتور',
          const Color(0xFF10B981),
          Icons.videocam_rounded,
          'telemedicine',
        );
      }

      // Speak the reply in Arabic
      _speakReply(reply.replaceAll(RegExp(r'\[.*?\]'), ''));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _analyzing = false;
        _chatMessages.add(_ChatMsg('⚠️ تعذر التحليل: $e'));
      });
    }
  }

  String _triageType = '';

  void _setResult(
    String level,
    String advice,
    String action,
    Color color,
    IconData icon,
    String type,
  ) {
    setState(() {
      _analyzing = false;
      _showResult = true;
      _triageLevel = level;
      _triageAdvice = advice;
      _triageAction = action;
      _triageColor = color;
      _triageIcon = icon;
      _triageType = type;
    });
    _resultCtrl.forward(from: 0);
  }

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
                'الفرز الذكي — AI Triage',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildHeader()),
            if (_isSpeaking) SliverToBoxAdapter(child: _buildSpeakingBar()),
            SliverToBoxAdapter(child: _buildBodyPartsSection()),
            SliverToBoxAdapter(child: _buildSymptomsInput()),
            SliverToBoxAdapter(child: _buildQuickSymptoms()),
            if (_chatMessages.isNotEmpty)
              SliverToBoxAdapter(child: _buildChatMessages()),
            if (_analyzing) SliverToBoxAdapter(child: _buildAnalyzing()),
            if (_showResult) SliverToBoxAdapter(child: _buildResult()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF0F172A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'وصف أعراضك 🩺',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'احكي أعراضك بالصوت أو اكتبها وبرنامج الذكاء الاصطناعي رح يقولك شو تعمل',
                  style: TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, _) => Transform.scale(
              scale: 0.9 + _pulseCtrl.value * 0.1,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyPartsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أين الألم؟',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _bodyParts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final bp = _bodyParts[i];
                final selected = _selectedBodyPart == i;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedBodyPart = selected ? -1 : i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    decoration: BoxDecoration(
                      color: selected
                          ? bp.color.withAlpha(30)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? bp.color
                            : AppColors.border.withAlpha(40),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          bp.icon,
                          color: selected ? bp.color : AppColors.textLight,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bp.name,
                          style: TextStyle(
                            color: selected ? bp.color : AppColors.textLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsInput() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(40)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _symptomsCtrl,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'اكتب أعراضك هنا... مثال: عندي ألم في صدري من يومين',
              hintStyle: TextStyle(
                color: AppColors.textLight.withAlpha(150),
                fontSize: 13,
              ),
              border: InputBorder.none,
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              // Voice button
              GestureDetector(
                onTap: _startListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isListening
                        ? const Color(0xFFEF4444).withAlpha(30)
                        : AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isListening
                          ? const Color(0xFFEF4444)
                          : AppColors.primary.withAlpha(40),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                        color: _isListening
                            ? const Color(0xFFEF4444)
                            : AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isListening ? 'جاري الاستماع...' : 'تحدث بالصوت',
                            style: TextStyle(
                              color: _isListening
                                  ? const Color(0xFFEF4444)
                                  : AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _selectedModel == 'grok-3-mini'
                                ? 'Grok 3 Mini'
                                : 'Grok 4.1 Fast',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Analyze button
              ElevatedButton.icon(
                onPressed: _analyzeWithGrok,
                icon: const Icon(Icons.psychology_rounded, size: 18),
                label: const Text(
                  'حلل الأعراض',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSymptoms() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: _quickSymptoms
            .map(
              (s) => GestureDetector(
                onTap: () {
                  final current = _symptomsCtrl.text;
                  _symptomsCtrl.text = current.isEmpty ? s : '$current، $s';
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border.withAlpha(40)),
                  ),
                  child: Text(
                    s,
                    style: const TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAnalyzing() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, _) => Transform.scale(
              scale: 0.8 + _pulseCtrl.value * 0.2,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'جاري تحليل الأعراض...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'الذكاء الاصطناعي يقيّم حالتك',
            style: TextStyle(color: AppColors.textLight, fontSize: 12),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            backgroundColor: AppColors.border.withAlpha(30),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return FadeTransition(
      opacity: _resultCtrl,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _triageColor.withAlpha(60), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _triageColor.withAlpha(15),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _triageColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_triageIcon, color: _triageColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نتيجة الفرز',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _triageLevel,
                          style: TextStyle(
                            color: _triageColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _triageAdvice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _triageColor.withAlpha(10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: _triageColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _triageAction,
                            style: TextStyle(
                              color: _triageColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Primary action buttons based on triage result
                  if (_triageType == 'er') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          // Navigate to live queue for ER
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LiveQueueScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.emergency_rounded, size: 20),
                        label: const Text(
                          'روح طوارئ عام — شوف الأقرب',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _erHospitalsList(),
                  ] else if (_triageType == 'booking') ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SmartBookingScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.flash_on_rounded, size: 18),
                            label: const Text(
                              'حجز خاص ⚡',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LiveQueueScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.account_balance_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'دور عام مجاني',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Color(0xFF10B981)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _comparisonCard(),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TelemedicineScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.videocam_rounded, size: 20),
                        label: const Text(
                          'ابدأ استشارة فيديو الآن',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SmartBookingScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                            ),
                            label: const Text(
                              'احجز عيادة',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LiveQueueScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.timer_rounded, size: 16),
                            label: const Text(
                              'دور مباشر',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF59E0B),
                              side: const BorderSide(color: Color(0xFFF59E0B)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '⚠️ هذا تقييم أولي فقط ولا يغني عن استشارة الطبيب',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 10,
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

  Widget _erHospitalsList() {
    final hospitals = [
      {'name': 'مستشفى الجامعة الأردنية', 'wait': '~45 د', 'dist': '3.2 كم'},
      {'name': 'مستشفى البشير', 'wait': '~60 د', 'dist': '5.1 كم'},
      {'name': 'مستشفى الأمير حمزة', 'wait': '~35 د', 'dist': '7.8 كم'},
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withAlpha(8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withAlpha(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏥 أقرب طوارئ حكومية:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...hospitals.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFEF4444),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      h['name']!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Text(
                    '${h['wait']} • ${h['dist']}',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 10,
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

  Widget _comparisonCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withAlpha(30)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.compare_arrows_rounded,
                color: AppColors.textMedium,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'مقارنة سريعة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _compareCol(
                  'عام (حكومي)',
                  'مجاني',
                  'انتظار 5-14 يوم',
                  const Color(0xFF10B981),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppColors.border.withAlpha(40),
              ),
              Expanded(
                child: _compareCol(
                  'خاص',
                  '25-60 د.أ',
                  'خلال 1-3 أيام',
                  const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compareCol(String title, String price, String wait, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            wait,
            style: const TextStyle(color: AppColors.textLight, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakingBar() {
    return GestureDetector(
      onTap: _stopSpeaking,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981).withAlpha(60)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.volume_up_rounded,
              color: Color(0xFF10B981),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'ترياق يتكلم... اضغط لإيقاف 🔊',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.stop_circle_rounded,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.chat_rounded,
                color: AppColors.textMedium,
                size: 16,
              ),
              const SizedBox(width: 6),
              const Text(
                'المحادثة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_chatMessages.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _chatMessages.clear()),
                  child: const Text(
                    'مسح',
                    style: TextStyle(color: AppColors.textLight, fontSize: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ..._chatMessages.map(
            (msg) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: msg.isUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (!msg.isUser) ...[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ? AppColors.primary.withAlpha(20)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: msg.isUser
                              ? AppColors.primary.withAlpha(40)
                              : AppColors.border.withAlpha(30),
                        ),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isUser ? AppColors.primary : Colors.white,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (msg.isUser) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyPart {
  final String name;
  final IconData icon;
  final Color color;
  const _BodyPart(this.name, this.icon, this.color);
}

class _ChatMsg {
  final String text;
  final bool isUser;
  final DateTime time;
  _ChatMsg(this.text, {this.isUser = false}) : time = DateTime.now();
}
