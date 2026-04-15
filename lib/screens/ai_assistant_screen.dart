import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/grok_service.dart';
import '../services/chat_history_service.dart';
import '../services/locale_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});
  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Position? _userPosition;

  // Image attachment
  Uint8List? _pendingImageBytes;
  String? _pendingImageBase64;

  // Chat history
  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  bool _showHistory = false;

  // Animation
  late AnimationController _headerAnim;

  // Voice
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _ttsEnabled = true;
  bool _isSpeaking = false;
  String _selectedVoice = 'ar'; // default Arabic

  List<_QuickAction> get _quickActions => <_QuickAction>[
    _QuickAction(
      Icons.calendar_month_rounded,
      LocaleService().tr('book_apt'),
      const Color(0xFF10B981),
    ),
    _QuickAction(
      Icons.science_rounded,
      LocaleService().tr('view_results'),
      const Color(0xFF7C3AED),
    ),
    _QuickAction(
      Icons.medication_rounded,
      LocaleService().tr('med_reminder'),
      const Color(0xFFF59E0B),
    ),
    _QuickAction(
      Icons.local_hospital_rounded,
      LocaleService().tr('nearest_hospital'),
      const Color(0xFF3B82F6),
    ),
    _QuickAction(Icons.image_rounded, 'ارسم لي صورة', const Color(0xFFEC4899)),
    _QuickAction(
      Icons.emergency_rounded,
      LocaleService().tr('emergency_mode'),
      const Color(0xFFEF4444),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _initChat();
    _getLocation();
    _initSpeech();
    _initTts();
  }

  Future<void> _initChat() async {
    _sessions = await ChatHistoryService.getSessions();
    if (_sessions.isEmpty) {
      _currentSession = await ChatHistoryService.createSession();
      _sessions = await ChatHistoryService.getSessions();
    } else {
      _currentSession = _sessions.first;
    }
    // Load messages from current session
    if (_currentSession!.messages.isEmpty) {
      final welcome = ChatMessage(
        'مرحباً! 👋\nأنا وكيل ترياق الذكي — مساعدك الصحي العامل على مدار الساعة.\n\nيمكنني مساعدتك في:\n📍 إيجاد أقرب مستشفى والتنقل إليه\n📅 حجز المواعيد وإدارتها\n💊 تتبع الأدوية وتذكيرها\n🧪 عرض نتائج الفحوصات\n🚨 خدمات الطوارئ\n🎤 يمكنك التحدث معي صوتياً!',
        false,
      );
      await ChatHistoryService.addMessage(_currentSession!.id, welcome);
      _currentSession = (await ChatHistoryService.getSessions()).first;
    }
    if (mounted) {
      setState(() {
        _messages.clear();
        _messages.addAll(_currentSession!.messages);
      });
    }
  }

  Future<void> _startNewChat() async {
    _currentSession = await ChatHistoryService.createSession();
    final welcome = ChatMessage(
      'مرحباً! 👋\nكيف أقدر أساعدك اليوم؟\n\nاسأل أي شيء: حجز مواعيد، أدوية، فحوصات، طوارئ...',
      false,
    );
    await ChatHistoryService.addMessage(_currentSession!.id, welcome);
    _sessions = await ChatHistoryService.getSessions();
    if (!mounted) return;
    setState(() {
      _messages.clear();
      _messages.addAll(_currentSession!.messages);
      _showHistory = false;
    });
  }

  Future<void> _loadSession(ChatSession session) async {
    _sessions = await ChatHistoryService.getSessions();
    _currentSession = _sessions.firstWhere((s) => s.id == session.id);
    if (mounted) {
      setState(() {
        _messages.clear();
        _messages.addAll(_currentSession!.messages);
        _showHistory = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _deleteSession(String id) async {
    await ChatHistoryService.deleteSession(id);
    _sessions = await ChatHistoryService.getSessions();
    if (_currentSession?.id == id) {
      if (_sessions.isNotEmpty) {
        await _loadSession(_sessions.first);
      } else {
        await _startNewChat();
      }
    } else {
      if (mounted) setState(() {});
    }
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

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ar');
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.1);
      // Try to find the best Arabic voice
      final voices = await _tts.getVoices as List<dynamic>?;
      if (voices != null) {
        // Prefer ar-JO, then ar-SA, then any ar
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
    } catch (_) {}
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleService().tr('speech_unavailable')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF6C3CE1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    // Stop TTS if speaking
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    }
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() => _controller.text = result.recognizedWords);
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            // Auto-detect language and set TTS to match
            final text = result.recognizedWords;
            final hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(text);
            if (hasEnglish) {
              _tts.setLanguage('en_US');
              _selectedVoice = 'en';
            } else {
              _tts.setLanguage('ar');
              _selectedVoice = 'ar';
            }
            _sendMessage(text);
          }
        },
        localeId: _selectedVoice == 'en' ? 'en_US' : 'ar_JO',
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
        ),
      );
    }
  }

  Future<void> _speak(String text) async {
    if (!_ttsEnabled) return;
    try {
      final clean = text
          .replaceAll(RegExp(r'[\u{1F000}-\u{1FFFF}]', unicode: true), '')
          .replaceAll(RegExp(r'[*#_~`>|]'), '')
          .trim();
      if (clean.isNotEmpty) {
        setState(() => _isSpeaking = true);
        await _tts.speak(clean);
      }
    } catch (_) {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  Future<void> _stopSpeaking() async {
    await _tts.stop();
    if (mounted) setState(() => _isSpeaking = false);
  }

  void _showVoiceSelectionSheet() {
    final voices = [
      {'id': 'ar', 'name': 'عربي', 'icon': '🇯🇴', 'locale': 'ar_JO'},
      {'id': 'ar-SA', 'name': 'عربي سعودي', 'icon': '🇸🇦', 'locale': 'ar_SA'},
      {'id': 'en', 'name': 'English', 'icon': '🇺🇸', 'locale': 'en_US'},
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E32),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎤 اختر صوت المساعد',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'اختار اللغة اللي بدك ترياق يحكي فيها',
                style: TextStyle(
                  color: Colors.white.withAlpha(120),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ...voices.map((v) {
                final selected = _selectedVoice == v['id'];
                return GestureDetector(
                  onTap: () async {
                    setState(() => _selectedVoice = v['id'] as String);
                    await _tts.setLanguage(v['locale'] as String);
                    if (!mounted) return;
                    Navigator.pop(context);
                    _toggleListening();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF6C3CE1).withAlpha(30)
                          : const Color(0xFF2A2A42),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF6C3CE1)
                            : Colors.white.withAlpha(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          v['icon'] as String,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            v['name'] as String,
                            style: TextStyle(
                              color: selected
                                  ? const Color(0xFF818CF8)
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF818CF8),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageGenDialog() {
    final promptCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E32),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '✨ إنشاء صورة بالذكاء الاصطناعي',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'وصف الصورة اللي بدك تنشئها',
                style: TextStyle(
                  color: Colors.white.withAlpha(120),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: promptCtrl,
                textDirection: TextDirection.rtl,
                autofocus: true,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'مثال: قطة لطيفة تلعب بكرة...',
                  hintStyle: TextStyle(
                    color: Colors.white.withAlpha(60),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2A2A42),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Quick suggestions
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _genChip('🏥 مستشفى حديث', promptCtrl),
                  _genChip('💊 دواء ملون', promptCtrl),
                  _genChip('🫀 قلب بشري', promptCtrl),
                  _genChip('🧬 DNA', promptCtrl),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (promptCtrl.text.trim().isEmpty) return;
                    Navigator.pop(context);
                    _sendMessage('ارسم ${promptCtrl.text.trim()}');
                  },
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: const Text(
                    'إنشاء الصورة ✨',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C3CE1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  Widget _genChip(String text, TextEditingController ctrl) {
    return GestureDetector(
      onTap: () =>
          ctrl.text = text.replaceAll(RegExp(r'^[^\w\u0600-\u06FF]+'), ''),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A42),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(15)),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 11),
        ),
      ),
    );
  }

  Widget _attachOption(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(100),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: Colors.white.withAlpha(60),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getLocation() async {
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      _userPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {}
  }

  List<Map<String, dynamic>> _cachedHospitals = [];

  Future<List<Map<String, dynamic>>> _getNearbyHospitals() async {
    if (_cachedHospitals.isEmpty) {
      _cachedHospitals = await ApiService.getHospitals();
    }
    final list = <Map<String, dynamic>>[];
    for (final h in _cachedHospitals) {
      final loc = h['location'] as Map<String, dynamic>?;
      double km = 0;
      if (_userPosition != null && loc != null) {
        km =
            Geolocator.distanceBetween(
              _userPosition!.latitude,
              _userPosition!.longitude,
              (loc['lat'] as num).toDouble(),
              (loc['lng'] as num).toDouble(),
            ) /
            1000;
      }
      list.add({
        'name': h['name'] ?? '',
        'dist': km.toStringAsFixed(1),
        'mins': (km / 30 * 60).round().clamp(1, 999).toString(),
        'status': h['isOpen'] == true ? 'مفتوح' : 'مغلق',
      });
    }
    list.sort(
      (a, b) => double.parse(
        a['dist'] as String,
      ).compareTo(double.parse(b['dist'] as String)),
    );
    for (int i = 0; i < list.length; i++) {
      list[i]['idx'] = i + 1;
    }
    return list;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _headerAnim.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _pendingImageBytes = bytes;
        _pendingImageBase64 = base64Encode(bytes);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تعذر اختيار الصورة'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFEF4444),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _clearPendingImage() {
    setState(() {
      _pendingImageBytes = null;
      _pendingImageBase64 = null;
    });
  }

  Future<void> _sendMessage(String text) async {
    final hasImage = _pendingImageBase64 != null;
    if (text.trim().isEmpty && !hasImage) return;
    _controller.clear();

    final imageB64 = _pendingImageBase64;
    _clearPendingImage();

    final userMsg = ChatMessage(
      text.trim().isEmpty && hasImage ? '📷 صورة مرفقة' : text,
      true,
      imageBase64: imageB64,
    );
    if (!mounted) return;
    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    if (_currentSession != null) {
      await ChatHistoryService.addMessage(_currentSession!.id, userMsg);
    }
    _scrollToBottom();

    final lower = text.trim();

    // ── Local handlers (hospital, emergency) ──
    if (lower.contains('أقرب مستشفى') || lower.contains('اقرب مستشفى')) {
      final hospitals = await _getNearbyHospitals();
      final lines = hospitals
          .take(3)
          .map(
            (h) =>
                '${h['idx']}. ${h['name']} — ${h['dist']} كم (${h['mins']} د) [${h['status']}]',
          )
          .join('\n');
      final nearest = hospitals.isNotEmpty
          ? hospitals.first['name'] as String
          : '';
      final reply = ChatMessage(
        '🏥 أقرب المستشفيات لموقعك:\n\n$lines\n\nهل تريد عرض الأقرب على الخريطة والتوجه إليه؟ 👇',
        false,
        action: 'openMap',
        hospitalName: nearest,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(reply);
        _isLoading = false;
      });
      if (_currentSession != null) {
        await ChatHistoryService.addMessage(_currentSession!.id, reply);
      }
      _scrollToBottom();
      return;
    }

    if (lower == 'افتح الخريطة' || lower == 'الخريطة') {
      final reply = ChatMessage(
        '🗺️ للذهاب للخريطة، اضغط زر الرجوع ← ثم اختر تبويب الخريطة من الأسفل.',
        false,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(reply);
        _isLoading = false;
      });
      if (_currentSession != null) {
        await ChatHistoryService.addMessage(_currentSession!.id, reply);
      }
      _scrollToBottom();
      return;
    }

    if (lower.contains('وضع الطوارئ') || lower.contains('طوارئ')) {
      await Future.delayed(const Duration(milliseconds: 500));
      final reply = ChatMessage(
        '🚨 وضع الطوارئ:\n\n• اتصل بالإسعاف: 911\n• افتح المحفظة الطبية لعرض بياناتك للمسعفين\n• أقرب طوارئ: مستشفى الأردن (2.3 كم)\n\nابقِ هادئاً. المساعدة في الطريق.',
        false,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(reply);
        _isLoading = false;
      });
      if (_currentSession != null) {
        await ChatHistoryService.addMessage(_currentSession!.id, reply);
      }
      _scrollToBottom();
      return;
    }

    try {
      // ── Image generation request ──
      if (!hasImage && GrokService.isImageGenerationRequest(lower)) {
        final genResult = await GrokService.generateImage(lower);
        if (!mounted) return;
        if (genResult['success'] == true) {
          final imgB64 = genResult['imageBase64'] as String?;
          final imgUrl = genResult['imageUrl'] as String?;
          final reply = ChatMessage(
            '🎨 تم إنشاء الصورة بنجاح!',
            false,
            imageBase64: imgB64,
            imageUrl: imgUrl,
          );
          setState(() {
            _messages.add(reply);
            _isLoading = false;
          });
          if (_currentSession != null) {
            await ChatHistoryService.addMessage(_currentSession!.id, reply);
          }
        } else {
          final err = ChatMessage(
            '⚠️ ${genResult['error'] ?? 'فشل إنشاء الصورة'}',
            false,
          );
          setState(() {
            _messages.add(err);
            _isLoading = false;
          });
          if (_currentSession != null) {
            await ChatHistoryService.addMessage(_currentSession!.id, err);
          }
        }
        _scrollToBottom();
        return;
      }

      // ── Vision: image attached ──
      if (hasImage && imageB64 != null) {
        final history = _messages
            .where((m) => !m.hasImage)
            .map(
              (m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              },
            )
            .toList();
        final result = await GrokService.chatWithVision(
          history.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
          imageB64,
          text.trim().isEmpty ? 'حلل هذه الصورة' : text,
        );
        if (!mounted) return;
        final replyText = result['reply'] as String? ?? 'تعذر تحليل الصورة.';
        final reply = ChatMessage(replyText, false);
        setState(() {
          _messages.add(reply);
          _isLoading = false;
        });
        if (_currentSession != null) {
          await ChatHistoryService.addMessage(_currentSession!.id, reply);
        }
        _speak(replyText);
        _scrollToBottom();
        return;
      }

      // ── Regular text chat via Grok ──
      final chatMsgs = _messages
          .where((m) => !m.hasImage || m.text.isNotEmpty)
          .map(
            (m) => <String, dynamic>{
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.text,
            },
          )
          .toList();
      final result = await GrokService.chat(chatMsgs);
      if (!mounted) return;
      final replyText = result['reply'] as String? ?? 'حدث خطأ.';
      final reply = ChatMessage(replyText, false);
      setState(() {
        _messages.add(reply);
        _isLoading = false;
      });
      if (_currentSession != null) {
        await ChatHistoryService.addMessage(_currentSession!.id, reply);
      }
      _speak(replyText);
    } catch (e) {
      if (!mounted) return;
      final err = ChatMessage('⚠️ تعذر الاتصال. حاول مرة أخرى.', false);
      setState(() {
        _messages.add(err);
        _isLoading = false;
      });
      if (_currentSession != null) {
        await ChatHistoryService.addMessage(_currentSession!.id, err);
      }
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Stack(
          children: [
            // Main chat area
            Column(
              children: [
                _buildHeader(topPad),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                      ),
                    ),
                    child: _messages.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            itemCount:
                                _messages.length +
                                (_isLoading ? 1 : 0) +
                                (_messages.length <= 2 && !_isLoading ? 1 : 0),
                            itemBuilder: (_, i) {
                              // Quick actions after first message(s)
                              if (_messages.length <= 2 &&
                                  !_isLoading &&
                                  i == _messages.length) {
                                return _buildQuickActions();
                              }
                              if (i ==
                                  _messages.length +
                                      (_messages.length <= 2 && !_isLoading
                                          ? 1
                                          : 0)) {
                                return _buildTypingIndicator();
                              }
                              if (i >= _messages.length) {
                                if (_isLoading) return _buildTypingIndicator();
                                return const SizedBox.shrink();
                              }
                              return _buildMessageBubble(_messages[i], i);
                            },
                          ),
                  ),
                ),
                _buildInputBar(bottomPad),
              ],
            ),
            // History drawer overlay
            if (_showHistory) ...[
              GestureDetector(
                onTap: () => setState(() => _showHistory = false),
                child: Container(color: Colors.black.withAlpha(120)),
              ),
              _buildHistoryDrawer(topPad),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  HEADER
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeader(double topPad) {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) {
        final v = CurvedAnimation(
          parent: _headerAnim,
          curve: Curves.easeOutCubic,
        ).value;
        return Transform.translate(
          offset: Offset(0, -30 * (1 - v)),
          child: Opacity(opacity: v, child: child),
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C3CE1), Color(0xFF5B6CF0), Color(0xFF4FADE0)],
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C3CE1).withAlpha(60),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back
            _headerIconBtn(
              Icons.arrow_forward_rounded,
              () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF818CF8), Color(0xFFA5B4FC)],
                ),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Colors.white.withAlpha(50), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF818CF8).withAlpha(60),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleService().tr('ai_title'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF34D399),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF34D399).withAlpha(150),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        LocaleService().tr('connected'),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // New chat
            _headerSmallBtn(Icons.edit_note_rounded, _startNewChat),
            const SizedBox(width: 6),
            // History button
            _headerSmallBtn(
              Icons.history_rounded,
              () => setState(() => _showHistory = !_showHistory),
            ),
            ...[
              // TTS toggle
              const SizedBox(width: 6),
              _headerSmallBtn(
                _ttsEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                () {
                  setState(() => _ttsEnabled = !_ttsEnabled);
                  HapticFeedback.selectionClick();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _headerIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.white.withAlpha(25)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _headerSmallBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white.withAlpha(25)),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  HISTORY DRAWER (ChatGPT-style)
  // ═══════════════════════════════════════════════════════════
  Widget _buildHistoryDrawer(double topPad) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      width: 300,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(80),
              blurRadius: 30,
              offset: const Offset(10, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        LocaleService().tr('chat_history'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _startNewChat,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C3CE1), Color(0xFF5B6CF0)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              LocaleService().tr('new_chat'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _sessions.isEmpty
                    ? Center(
                        child: Text(
                          LocaleService().tr('no_prev_chats'),
                          style: TextStyle(
                            color: Colors.white.withAlpha(100),
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _sessions.length,
                        itemBuilder: (_, i) => _buildSessionItem(_sessions[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionItem(ChatSession session) {
    final isActive = session.id == _currentSession?.id;
    final timeAgo = _timeAgo(session.updatedAt);
    return GestureDetector(
      onTap: () => _loadSession(session),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6C3CE1).withAlpha(30)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isActive
              ? Border.all(color: const Color(0xFF6C3CE1).withAlpha(60))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: isActive
                  ? const Color(0xFF818CF8)
                  : Colors.white.withAlpha(60),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withAlpha(180),
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      color: Colors.white.withAlpha(60),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _deleteSession(session.id),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.white.withAlpha(40),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    return 'منذ ${diff.inDays} يوم';
  }

  // ═══════════════════════════════════════════════════════════
  //  EMPTY STATE
  // ═══════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C3CE1), Color(0xFF5B6CF0)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C3CE1).withAlpha(40),
                  blurRadius: 24,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            LocaleService().tr('welcome_agent'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LocaleService().tr('ask_health'),
            style: TextStyle(color: Colors.white.withAlpha(120), fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  INPUT BAR — Dark glassmorphism
  // ═══════════════════════════════════════════════════════════
  Widget _buildInputBar(double bottomPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 0, 12, bottomPad + 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32),
        border: Border(top: BorderSide(color: Colors.white.withAlpha(10))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image preview
          if (_pendingImageBytes != null)
            Container(
              margin: const EdgeInsets.fromLTRB(6, 10, 6, 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A42),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF6C3CE1).withAlpha(40),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      _pendingImageBytes!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '📷 صورة مرفقة — جاهزة للإرسال',
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearPendingImage,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFEF4444),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Speaking indicator + stop
          if (_isSpeaking)
            Container(
              margin: const EdgeInsets.fromLTRB(6, 10, 6, 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF6C3CE1).withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF6C3CE1).withAlpha(40),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.volume_up_rounded,
                    color: Color(0xFF818CF8),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🔊 ترياق يتكلم...',
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _stopSpeaking,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stop_rounded,
                            color: Color(0xFFEF4444),
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'إيقاف',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Input row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            margin: EdgeInsets.only(
              top: _pendingImageBytes == null && !_isSpeaking ? 10 : 0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A42),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withAlpha(15)),
            ),
            child: Row(
              children: [
                // + button: shows popup to pick image or generate
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xFF1E1E32),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (_) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _attachOption(
                                Icons.photo_library_rounded,
                                'رفع صورة من المعرض',
                                'ارفع صورة عشان ترياق يحللها',
                                const Color(0xFF3B82F6),
                                () {
                                  Navigator.pop(context);
                                  _pickImage();
                                },
                              ),
                              const SizedBox(height: 8),
                              _attachOption(
                                Icons.auto_awesome_rounded,
                                'إنشاء صورة بالذكاء الاصطناعي ✨',
                                'وصف الصورة اللي بدك تنشئها',
                                const Color(0xFFEC4899),
                                () {
                                  Navigator.pop(context);
                                  _showImageGenDialog();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _pendingImageBytes != null
                          ? const Color(0xFF6C3CE1).withAlpha(30)
                          : Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _pendingImageBytes != null
                          ? Icons.image_rounded
                          : Icons.add_rounded,
                      color: _pendingImageBytes != null
                          ? const Color(0xFF818CF8)
                          : Colors.white.withAlpha(100),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Mic button — long press for voice selection
                GestureDetector(
                  onTap: _toggleListening,
                  onLongPress: _showVoiceSelectionSheet,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: _isListening
                          ? const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                            )
                          : null,
                      color: _isListening ? null : Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _isListening
                          ? [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withAlpha(40),
                                blurRadius: 12,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: _isListening
                          ? Colors.white
                          : Colors.white.withAlpha(100),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: _pendingImageBytes != null
                          ? 'اكتب سؤال عن الصورة أو أرسلها...'
                          : LocaleService().tr('type_msg'),
                      hintStyle: TextStyle(
                        color: Colors.white.withAlpha(60),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                GestureDetector(
                  onTap: () => _sendMessage(_controller.text),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6C3CE1), Color(0xFF5B6CF0)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C3CE1).withAlpha(50),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
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

  // ═══════════════════════════════════════════════════════════
  //  MESSAGE BUBBLE
  // ═══════════════════════════════════════════════════════════
  Widget _buildMessageBubble(ChatMessage msg, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - v)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: msg.isUser ? _userBubble(msg) : _botBubble(msg),
      ),
    );
  }

  Widget _userBubble(ChatMessage msg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C3CE1), Color(0xFF5B6CF0)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(6),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C3CE1).withAlpha(30),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (msg.imageBase64 != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(msg.imageBase64!),
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (msg.text.isNotEmpty && msg.text != '📷 صورة مرفقة')
                  Text(
                    msg.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.6,
                    ),
                  )
                else if (msg.imageBase64 == null)
                  Text(
                    msg.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _botBubble(ChatMessage msg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C3CE1), Color(0xFF818CF8)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 15,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A42),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                  border: Border.all(color: Colors.white.withAlpha(8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (msg.text.isNotEmpty)
                      Text(
                        msg.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(230),
                          height: 1.6,
                        ),
                      ),
                    // Generated image
                    if (msg.imageBase64 != null) ...[
                      if (msg.text.isNotEmpty) const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(msg.imageBase64!),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ] else if (msg.imageUrl != null) ...[
                      if (msg.text.isNotEmpty) const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          msg.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              height: 200,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xFF818CF8),
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (_, _, _) => Container(
                            height: 100,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E32),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '⚠️ تعذر تحميل الصورة',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (msg.action == 'openMap') ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C3CE1), Color(0xFF5B6CF0)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C3CE1).withAlpha(40),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.navigation_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          LocaleService().tr('show_on_map'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (msg.action == 'bookingConfirmed') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF10B981).withAlpha(40),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        LocaleService().tr('booked_ok'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  TYPING INDICATOR
  // ═══════════════════════════════════════════════════════════
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C3CE1), Color(0xFF818CF8)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 15,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A42),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.white.withAlpha(8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 6 : 0),
                  child: _animDot(i),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + index * 300),
      builder: (_, v, child) {
        final bounce = math.sin(v * math.pi * 2).abs();
        return Transform.translate(
          offset: Offset(0, -4 * bounce),
          child: Opacity(opacity: 0.4 + 0.6 * bounce, child: child),
        );
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C3CE1), Color(0xFF818CF8)],
          ),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  QUICK ACTIONS
  // ═══════════════════════════════════════════════════════════
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: _quickActions.map((a) {
          return GestureDetector(
            onTap: () => _sendMessage(a.label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: a.color.withAlpha(15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: a.color.withAlpha(40)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: a.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(a.icon, size: 14, color: a.color),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    a.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: a.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction(this.icon, this.label, this.color);
}
