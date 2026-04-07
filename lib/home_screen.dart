import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  String _agentResponse =
      "مرحبا! أنا مسار الذكي في تطبيق نبض 👋\nنظام Oriented System مفعّل";
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  bool _isConnected = false;

  // Oriented System state
  String _journeyState = 'start';
  int _journeyProgress = 0;
  List<Map<String, dynamic>> _hospitalRanking = [];

  // TODO: Replace with actual user ID from auth system
  static const String _userId = 'guest-user';

  // Socket.IO server URL – change to deployed URL in production
  static const String _socketUrl = 'http://10.0.2.2:3005';

  late io.Socket _socket;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    _socket = io.io(
      '$_socketUrl/ws',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': _userId})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket.onConnect((_) {
      setState(() => _isConnected = true);
    });

    _socket.onDisconnect((_) {
      setState(() => _isConnected = false);
    });

    // AI response from orchestrator
    _socket.on('chat:response', (data) {
      final message = data['message'] ?? data['messageEn'] ?? 'لا يوجد رد';
      setState(() {
        _agentResponse = message;
        _isLoading = false;
        // Update journey from response
        if (data['journey'] != null) {
          _journeyState = data['journey']['state'] ?? _journeyState;
          _journeyProgress =
              data['journey']['progressPercent'] ?? _journeyProgress;
        }
        // Update hospital ranking
        if (data['hospitalRanking'] != null) {
          _hospitalRanking = List<Map<String, dynamic>>.from(
            data['hospitalRanking'],
          );
        }
      });
      _tts.speak(message);
    });

    // Typing indicator
    _socket.on('chat:typing', (data) {
      if (data['isTyping'] == true) {
        setState(() {
          _isLoading = true;
          _agentResponse = "جاري التفكير...";
        });
      }
    });

    // Error handling
    _socket.on('chat:error', (data) {
      setState(() {
        _agentResponse = data['error'] ?? 'حصل خطأ';
        _isLoading = false;
      });
    });

    // Welcome message
    _socket.on('connected', (data) {
      setState(() {
        _agentResponse = data['message'] ?? 'متصل بنجاح';
      });
    });

    // Real-time notifications
    _socket.on('notification', (data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['title'] ?? 'إشعار جديد'),
            backgroundColor: const Color(0xFF006F3E),
          ),
        );
      }
    });

    // Appointment updates
    _socket.on('appointment:update', (data) {
      setState(() {
        _agentResponse = "📅 تحديث موعد: ${data['status'] ?? data.toString()}";
      });
    });

    // Emergency response
    _socket.on('emergency:response', (data) {
      setState(() {
        _agentResponse = "🚨 ${data['message'] ?? 'تم استلام تنبيه الطوارئ'}";
        _isLoading = false;
      });
    });

    // Journey state change (Oriented System)
    _socket.on('journey:update', (data) {
      setState(() {
        _journeyState = data['newState'] ?? _journeyState;
      });
    });

    // Journey status response
    _socket.on('journey:status', (data) {
      setState(() {
        _journeyState = data['state'] ?? _journeyState;
        _journeyProgress = data['progressPercent'] ?? _journeyProgress;
      });
    });

    // Hospital ranking response
    _socket.on('hospitals:ranking', (data) {
      if (data['ranking'] != null) {
        setState(() {
          _hospitalRanking = List<Map<String, dynamic>>.from(
            (data['ranking'] as List).map(
              (h) => <String, dynamic>{
                'hospitalNameAr': h['hospitalNameAr'] ?? '',
                'score': h['score'] ?? 0,
              },
            ),
          );
        });
      }
    });
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    if (!_isConnected) {
      // Offline fallback
      setState(() {
        _agentResponse = "❌ غير متصل بالسيرفر — تأكد من الاتصال بالإنترنت";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _agentResponse = "جاري التفكير...";
    });

    _socket.emit('chat:message', {
      'message': message,
      'context': {'locale': 'ar-JO'},
    });
  }

  void _startListening() async {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            _controller.text = result.recognizedWords;
            _sendMessage(result.recognizedWords);
            setState(() => _isListening = false);
          }
        },
        localeId: "ar-JO",
      );
    }
  }

  @override
  void dispose() {
    _socket.dispose();
    _controller.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "نبض",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              color: _isConnected ? Colors.greenAccent : Colors.redAccent,
              size: 18,
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF006F3E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF003087),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ─── Patient Journey Progress Bar ─────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _journeyStateLabel(_journeyState),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$_journeyProgress%',
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _journeyProgress / 100,
                      minHeight: 8,
                      backgroundColor: Colors.white.withAlpha(40),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF00E676),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Medical Wallet Card
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.qr_code_2,
                  size: 50,
                  color: Color(0xFF006F3E),
                ),
                title: const Text(
                  "محفظتي الصحية",
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: const Text("امسح QR لعرض بياناتك"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 10),

            // Hospitals Map Button
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.local_hospital,
                  size: 50,
                  color: Color(0xFF003087),
                ),
                title: const Text(
                  "المستشفيات القريبة",
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: const Text("اعرض الخريطة"),
                trailing: const Icon(Icons.map),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapScreen()),
                  );
                },
              ),
            ),
            // Top Hospital Badge (from Oriented System)
            if (_hospitalRanking.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '🏆 الأفضل: ${_hospitalRanking.first['hospitalNameAr']} (${_hospitalRanking.first['score']})',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),

            // AI Agent Chat
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : SingleChildScrollView(
                        child: Text(
                          _agentResponse,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Text Input + Voice Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: "اكتب رسالة أو اضغط على الميكروفون...",
                      hintTextDirection: TextDirection.rtl,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (text) => _sendMessage(text),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic_off : Icons.mic,
                    size: 36,
                    color: _isListening ? Colors.red : Colors.white,
                  ),
                  onPressed: _startListening,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    size: 36,
                    color: Color(0xFF00E676),
                  ),
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _journeyStateLabel(String state) {
    const labels = {
      'start': '🚀 البداية',
      'check_symptoms': '🩺 فحص الأعراض',
      'triage': '⚖️ التصنيف',
      'recommendation': '🏥 التوصية',
      'appointment': '📅 الموعد',
      'visit': '👨‍⚕️ الزيارة',
      'followup': '🔄 المتابعة',
      'completed': '✅ مكتمل',
      'emergency': '🚨 طوارئ',
    };
    return labels[state] ?? '📍 رحلة المريض';
  }
}
