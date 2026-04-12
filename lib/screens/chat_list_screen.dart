import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final bool asTab;
  const ChatListScreen({super.key, this.asTab = false});

  static const List<_ChatEntry> _chats = [
    _ChatEntry(
      name: 'مستشفى الأردن',
      phone: '06 560 7777',
      lastMessage: 'مرحباً بك. كيف يمكننا مساعدتك؟',
      time: '10:30',
      unread: 1,
    ),
    _ChatEntry(
      name: 'مستشفى الجامعة الأردنية',
      phone: '06 535 5000',
      lastMessage: 'سيتم إرسال نتائج الفحوصات خلال 24 ساعة',
      time: '09:15',
      unread: 0,
    ),
    _ChatEntry(
      name: 'مدينة الحسين الطبية',
      phone: '06 580 4804',
      lastMessage: 'تم تأكيد موعدك يوم الأربعاء',
      time: 'أمس',
      unread: 0,
    ),
    _ChatEntry(
      name: 'المركز العربي الطبي',
      phone: '06 592 1199',
      lastMessage: 'ساعات الزيارة من 4 إلى 8 مساءً',
      time: 'أمس',
      unread: 2,
    ),
    _ChatEntry(
      name: 'مستشفى الخالدي',
      phone: '06 464 4281',
      lastMessage: 'شكراً لتواصلك معنا',
      time: 'الإثنين',
      unread: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final body = _chats.isEmpty
        ? _buildEmpty()
        : ListView.builder(
            padding: EdgeInsets.only(top: asTab ? 0 : 8, bottom: 8),
            itemCount: _chats.length + (asTab ? 1 : 0),
            itemBuilder: (_, i) {
              if (asTab && i == 0) return _buildTabHeader(topPad);
              return _buildChatTile(context, _chats[asTab ? i - 1 : i]);
            },
          );

    if (asTab) {
      return Scaffold(backgroundColor: AppColors.background, body: body);
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.textDark,
            ),
          ),
          title: const Text(
            'المحادثات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          centerTitle: true,
        ),
        body: body,
      ),
    );
  }

  Widget _buildTabHeader(double topPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withAlpha(40), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'الرسائل',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_chats.where((c) => c.unread > 0).length} جديد',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد محادثات بعد',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ محادثة مع أي مستشفى من صفحة التفاصيل',
            style: TextStyle(fontSize: 13, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, _ChatEntry chat) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                ChatScreen(hospitalName: chat.name, hospitalPhone: chat.phone),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border.withAlpha(20)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: chat.unread > 0
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        chat.time,
                        style: TextStyle(
                          fontSize: 11,
                          color: chat.unread > 0
                              ? AppColors.primary
                              : AppColors.textLight,
                          fontWeight: chat.unread > 0
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: chat.unread > 0
                                ? AppColors.textMedium
                                : AppColors.textLight,
                            fontWeight: chat.unread > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            gradient: AppColors.gradientPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${chat.unread}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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

class _ChatEntry {
  final String name;
  final String phone;
  final String lastMessage;
  final String time;
  final int unread;
  const _ChatEntry({
    required this.name,
    required this.phone,
    required this.lastMessage,
    required this.time,
    required this.unread,
  });
}
