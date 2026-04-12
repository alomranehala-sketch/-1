import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// Direct Grok (x.ai) API service — bypasses backend servers
/// On web: routes through dev-server proxy (CORS bypass)
/// On mobile: calls x.ai directly
class GrokService {
  static const _apiKey =
      'xai-lSoC8T03HMR5ySPsvTQcLzzjKzzTvZld6qR0qsFwMREzdpt863J4byUFiNp8FLj0IRJWUQv7xXhusq7b';
  static const _directBase = 'https://api.x.ai/v1';

  // On web, use proxy through dev-server to bypass CORS
  static String get _chatUrl => kIsWeb
      ? '${ApiService.baseUrl}/grok/chat'
      : '$_directBase/chat/completions';
  static String get _imageUrl => kIsWeb
      ? '${ApiService.baseUrl}/grok/images'
      : '$_directBase/images/generations';

  static const _chatModel = 'grok-3-mini';
  static const _visionModel = 'grok-4-1-fast-non-reasoning';
  static const _imageModel = 'grok-imagine-image-pro';

  static const _systemPrompt =
      '''أنت "ترياق" — مساعد صحي ذكي أردني يشتغل 24 ساعة.
أنت تابع لتطبيق ترياق — Teryaq Smart Health في الأردن.

أسلوبك:
- احكي بالأردني العامي الطبيعي زي ما الناس بتحكي بالأردن — مش فصحى ومش روبوت
- استخدم كلمات أردنية: "شو"، "كيفك"، "إنشالله"، "يزم"، "هلأ"، "أوكي"، "تمام"، "والله"، "يعني"، "مشان"، "هاي"، "هاد"
- إذا حدا حكى معك بالإنجليزي، رد عليه بالإنجليزي
- إذا حكى عربي فصحى، رد عليه بالأردني العامي
- كون زي صاحب بيفهم بالطب مش دكتور رسمي
- خلي الكلام قصير ومفيد — ما تطوّل
- استخدم إيموجي بس بشكل طبيعي

مهامك:
• الإجابة على الأسئلة الصحية بلغة سهلة
• المساعدة بحجز المواعيد
• شرح نتائج الفحوصات والتحاليل
• نصائح صحية
• تذكير الأدوية
• معلومات عن المستشفيات والعيادات
• تحليل الصور الطبية لما تنبعتلك
• إنشاء صور توضيحية لما يطلبوا منك

قواعد:
- لا تشخّص أمراض — وجّه للدكتور لما يلزم
- ردك لازم يكون بنفس اللغة اللي حكاها المستخدم
- إذا أُرسلت صورة طبية، حللها واشرح بالبسيط
- إذا طُلب رسم أو إنشاء صورة، قول إنك رح تنشئها هلأ''';

  static Map<String, String> get _headers {
    final h = <String, String>{'Content-Type': 'application/json'};
    // On mobile, send auth directly. On web, proxy adds it.
    if (!kIsWeb) h['Authorization'] = 'Bearer $_apiKey';
    return h;
  }

  /// Regular text chat
  static Future<Map<String, dynamic>> chat(
    List<Map<String, dynamic>> messages, {
    String? model,
  }) async {
    try {
      final allMessages = <Map<String, dynamic>>[
        {'role': 'system', 'content': _systemPrompt},
        ...messages,
      ];

      final res = await http
          .post(
            Uri.parse(_chatUrl),
            headers: _headers,
            body: jsonEncode({
              'model': model ?? _chatModel,
              'messages': allMessages,
              'max_tokens': 2048,
              'temperature': 0.4,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String? ?? '';
          return {'reply': content, 'success': true};
        }
      }
      return {
        'reply': 'عذراً، حدث خطأ. حاول مرة أخرى. (${res.statusCode})',
        'success': false,
      };
    } catch (e) {
      return {
        'reply':
            '⚠️ تعذر الاتصال بالذكاء الاصطناعي.\n\nتأكد من:\n• اتصال الإنترنت\n• تشغيل السيرفر المحلي (dev-server)\n\nالخطأ: $e',
        'success': false,
      };
    }
  }

  /// Vision chat — send image + optional text
  static Future<Map<String, dynamic>> chatWithVision(
    List<Map<String, dynamic>> history,
    String base64Image,
    String? userText,
  ) async {
    try {
      final content = <Map<String, dynamic>>[
        if (userText != null && userText.trim().isNotEmpty)
          {'type': 'text', 'text': userText},
        {
          'type': 'image_url',
          'image_url': {
            'url': 'data:image/jpeg;base64,$base64Image',
            'detail': 'high',
          },
        },
      ];

      final allMessages = <Map<String, dynamic>>[
        {'role': 'system', 'content': _systemPrompt},
        // Include history (text-only)
        ...history.where((m) => m['content'] is String).take(6),
        {'role': 'user', 'content': content},
      ];

      final res = await http
          .post(
            Uri.parse(_chatUrl),
            headers: _headers,
            body: jsonEncode({
              'model': _visionModel,
              'messages': allMessages,
              'max_tokens': 2048,
              'temperature': 0.4,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final reply = choices[0]['message']['content'] as String? ?? '';
          return {'reply': reply, 'success': true};
        }
      }
      // Include server error details
      String errDetail = '';
      try {
        final errBody = jsonDecode(res.body) as Map<String, dynamic>;
        errDetail = errBody['error']?['message'] as String? ?? res.body;
      } catch (_) {
        errDetail = res.body;
      }
      return {
        'reply': '⚠️ تعذر تحليل الصورة (${res.statusCode})\n$errDetail',
        'success': false,
      };
    } catch (e) {
      return {'reply': '⚠️ خطأ في تحليل الصورة:\n$e', 'success': false};
    }
  }

  /// Generate image using Grok image model
  static Future<Map<String, dynamic>> generateImage(String prompt) async {
    try {
      final res = await http
          .post(
            Uri.parse(_imageUrl),
            headers: _headers,
            body: jsonEncode({
              'model': _imageModel,
              'prompt': prompt,
              'n': 1,
              'response_format': 'b64_json',
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final items = data['data'] as List;
        if (items.isNotEmpty) {
          final b64 = items[0]['b64_json'] as String?;
          final url = items[0]['url'] as String?;
          return {'success': true, 'imageBase64': b64, 'imageUrl': url};
        }
      }
      return {
        'success': false,
        'error': 'فشل إنشاء الصورة (${res.statusCode})',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'تعذر إنشاء الصورة. تحقق من الإنترنت.',
      };
    }
  }

  /// Check if user is requesting image generation
  static bool isImageGenerationRequest(String text) {
    // Normalize: replace ه at end of word with ة, remove diacritics
    final normalized = text
        .trim()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '') // strip tashkeel
        .replaceAll(RegExp(r'ه\b'), 'ة'); // normalize final ه→ة
    final lower = normalized;
    final triggers = [
      'ارسم',
      'أرسم',
      'ارسمي',
      'أرسمي',
      'صمم',
      'صممي',
      'أنشئ صورة',
      'انشئ صورة',
      'انشئي صورة',
      'اعمل صورة',
      'اعملي صورة',
      'اعمللي صورة',
      'ولد صورة',
      'ولدي صورة',
      'generate image',
      'create image',
      'draw',
      'make image',
      'صور لي',
      'صورلي',
      'اصنع صورة',
      'اصنعي صورة',
      'حطلي صورة',
      'سوي صورة',
      'سولي صورة',
      'عملي صورة',
      'خلي صورة',
    ];
    return triggers.any((t) => lower.contains(t));
  }
}
