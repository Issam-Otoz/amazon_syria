import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:amazon_syria/features/auth/presentation/providers/auth_provider.dart';
import 'package:amazon_syria/features/chat/domain/entities/chat_room_entity.dart';
import 'package:amazon_syria/features/chat/presentation/providers/chat_provider.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      context.read<ChatProvider>().loadChatRooms(userId);
    }
  }

  String _otherParticipantName(ChatRoomEntity room, String currentUserId) {
    for (final entry in room.participantNames.entries) {
      if (entry.key != currentUserId) return entry.value;
    }
    return 'مستخدم';
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return timeago.format(dateTime, locale: 'ar');
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final chatProvider = context.watch<ChatProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المحادثات'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: _buildBody(chatProvider, currentUser?.id ?? ''),
      ),
    );
  }

  Widget _buildBody(ChatProvider provider, String currentUserId) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.chatRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'لا توجد محادثات',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ محادثة من صفحة المنتج',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.chatRooms.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 76,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        final room = provider.chatRooms[index];
        return _ChatRoomTile(
          room: room,
          currentUserId: currentUserId,
          otherName: _otherParticipantName(room, currentUserId),
          timeText: _formatTime(room.lastMessageTime),
          onTap: () => context.push('/chat/${room.id}'),
        );
      },
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoomEntity room;
  final String currentUserId;
  final String otherName;
  final String timeText;
  final VoidCallback onTap;

  const _ChatRoomTile({
    required this.room,
    required this.currentUserId,
    required this.otherName,
    required this.timeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = otherName.isNotEmpty ? otherName[0] : '?';

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: const Color(0xFF232F3E),
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        otherName,
        style: const TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: room.lastMessage != null
          ? Text(
              room.lastMessage!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            )
          : Text(
              'لا توجد رسائل بعد',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade400,
              ),
            ),
      trailing: timeText.isNotEmpty
          ? Text(
              timeText,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            )
          : null,
    );
  }
}
