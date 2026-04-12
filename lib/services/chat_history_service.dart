import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? action;
  final String? hospitalName;
  final String? imageBase64; // base64-encoded image (uploaded or generated)
  final String? imageUrl; // URL for remote images
  final DateTime timestamp;

  ChatMessage(
    this.text,
    this.isUser, {
    this.action,
    this.hospitalName,
    this.imageBase64,
    this.imageUrl,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get hasImage => imageBase64 != null || imageUrl != null;

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'action': action,
    'hospitalName': hospitalName,
    // Don't save base64 images — they're too large for SharedPreferences
    if (imageUrl != null) 'imageUrl': imageUrl,
    'hasImage': imageBase64 != null,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    json['text'] as String,
    json['isUser'] as bool,
    action: json['action'] as String?,
    hospitalName: json['hospitalName'] as String?,
    imageBase64: json['imageBase64'] as String?,
    imageUrl: json['imageUrl'] as String?,
    timestamp:
        DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
  );
}

class ChatSession {
  final String id;
  String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : messages = messages ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((m) => m.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] as String,
    title: json['title'] as String,
    messages: (json['messages'] as List?)
        ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
  );
}

class ChatHistoryService {
  static const _storageKey = 'teryaq_chat_sessions';
  static List<ChatSession> _sessions = [];
  static bool _loaded = false;

  static Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _sessions = list
            .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
            .toList();
        _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      } catch (_) {
        _sessions = [];
      }
    }
    _loaded = true;
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(json));
  }

  static Future<List<ChatSession>> getSessions() async {
    await _ensureLoaded();
    return List.unmodifiable(_sessions);
  }

  static Future<ChatSession> createSession() async {
    await _ensureLoaded();
    final session = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'محادثة جديدة',
    );
    _sessions.insert(0, session);
    await _save();
    return session;
  }

  static Future<void> addMessage(String sessionId, ChatMessage message) async {
    try {
      await _ensureLoaded();
      final idx = _sessions.indexWhere((s) => s.id == sessionId);
      if (idx == -1) return; // Session not found — skip silently
      final session = _sessions[idx];
      session.messages.add(message);
      session.updatedAt = DateTime.now();

      // Auto-title from first user message
      if (session.title == 'محادثة جديدة' && message.isUser) {
        final text = message.text;
        session.title = text.length > 30 ? '${text.substring(0, 30)}...' : text;
      }

      await _save();
    } catch (_) {
      // Don't crash the chat if storage fails
    }
  }

  static Future<void> deleteSession(String sessionId) async {
    await _ensureLoaded();
    _sessions.removeWhere((s) => s.id == sessionId);
    await _save();
  }

  static Future<void> clearAll() async {
    _sessions.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
