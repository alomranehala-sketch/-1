import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

class ChatScreen extends StatefulWidget {
  final String hospitalName;
  final String hospitalPhone;
  const ChatScreen({
    super.key,
    required this.hospitalName,
    required this.hospitalPhone,
  });
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  // Auto-replies for simulation
  final List<String> _autoReplies = [
    'مرحباً بك في خدمة المراسلة. كيف يمكنني مساعدتك؟',
    'سأقوم بتحويلك للقسم المختص، يرجى الانتظار لحظة.',
    'هل لديك رقم ملف طبي لدينا؟',
    'يمكنك حجز موعد عبر التطبيق مباشرة أو الاتصال بنا.',
    'ساعات الزيارة من 4 مساءً إلى 8 مساءً يومياً.',
    'نعم، هذه الخدمة متوفرة لدينا. هل تريد تحديد موعد؟',
    'شكراً لتواصلك معنا. هل يوجد شيء آخر يمكنني مساعدتك به؟',
    'سيتم إرسال تقريرك عبر البريد الإلكتروني خلال 24 ساعة.',
  ];
  int _replyIndex = 0;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(
      _ChatMessage(
        text: 'مرحباً بك في ${widget.hospitalName}. كيف يمكننا مساعدتك اليوم؟',
        isMe: false,
        time: _timeNow(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _timeNow() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(_ChatMessage(text: text, isMe: true, time: _timeNow()));
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate reply
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          _ChatMessage(
            text: _autoReplies[_replyIndex % _autoReplies.length],
            isMe: false,
            time: _timeNow(),
          ),
        );
        _replyIndex++;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildCommActions(),
            Expanded(child: _buildMessages()),
            if (_isTyping) _buildTypingIndicator(),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_forward_rounded,
          color: AppColors.textDark,
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hospitalName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'متصل الآن',
                      style: TextStyle(fontSize: 11, color: AppColors.success),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // WhatsApp
        IconButton(
          onPressed: () async {
            final phone = widget.hospitalPhone
                .replaceAll(' ', '')
                .replaceAll('-', '');
            final waPhone = phone.startsWith('0')
                ? '962${phone.substring(1)}'
                : phone;
            final uri = Uri.parse(
              'https://wa.me/$waPhone?text=${Uri.encodeComponent('مرحباً، أتواصل معكم من تطبيق ترياق')}',
            );
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          icon: const Icon(Icons.chat, color: Color(0xFF25D366), size: 22),
        ),
        // Phone call
        IconButton(
          onPressed: () async {
            final uri = Uri.parse(
              'tel:${widget.hospitalPhone.replaceAll(' ', '')}',
            );
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          },
          icon: const Icon(
            Icons.phone_rounded,
            color: AppColors.success,
            size: 22,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildCommActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withAlpha(30)),
        ),
      ),
      child: Row(
        children: [
          _commBtn(Icons.chat, 'واتساب', const Color(0xFF25D366), () async {
            final phone = widget.hospitalPhone
                .replaceAll(' ', '')
                .replaceAll('-', '');
            final waPhone = phone.startsWith('0')
                ? '962${phone.substring(1)}'
                : phone;
            final uri = Uri.parse(
              'https://wa.me/$waPhone?text=${Uri.encodeComponent('مرحباً، أتواصل معكم من تطبيق ترياق')}',
            );
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }),
          const SizedBox(width: 8),
          _commBtn(Icons.phone_rounded, 'اتصال', AppColors.success, () async {
            final uri = Uri.parse(
              'tel:${widget.hospitalPhone.replaceAll(' ', '')}',
            );
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          }),
          const SizedBox(width: 8),
          _commBtn(Icons.videocam_rounded, 'مكالمة فيديو', AppColors.info, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('مكالمة الفيديو قريباً'),
                duration: Duration(seconds: 2),
              ),
            );
          }),
          const SizedBox(width: 8),
          _commBtn(
            Icons.location_on_rounded,
            'الموقع',
            const Color(0xFFEF4444),
            () async {
              final uri = Uri.parse(
                'https://www.google.com/maps/search/${Uri.encodeComponent(widget.hospitalName)}',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _commBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(40)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildBubble(_messages[i]),
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    final isMe = msg.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isMe ? AppColors.gradientPrimary : null,
          color: isMe ? null : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe
              ? null
              : Border.all(color: AppColors.border.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white : AppColors.textDark,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withAlpha(180)
                        : AppColors.textLight,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: Colors.white.withAlpha(180),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withAlpha(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _typingDot(0),
            const SizedBox(width: 4),
            _typingDot(1),
            const SizedBox(width: 4),
            _typingDot(2),
            const SizedBox(width: 8),
            const Text(
              'يكتب...',
              style: TextStyle(fontSize: 11, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + index * 200),
      builder: (_, v, child) =>
          Opacity(opacity: (v * 2 - 1).abs().clamp(0.3, 1.0), child: child),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.textLight,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border.withAlpha(30))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border.withAlpha(40)),
              ),
              child: TextField(
                controller: _controller,
                textDirection: TextDirection.rtl,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  const _ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}
