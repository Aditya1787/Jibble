import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import '../../screens/Chat/chat_arena_page.dart';

/// Chat List Item Widget
///
/// Displays a single chat conversation in the chat list
class ChatListItemWidget extends StatelessWidget {
  final ChatModel chat;

  const ChatListItemWidget({super.key, required this.chat});

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xFF3B6FE8),
        backgroundImage: chat.otherUserProfilePic != null
            ? NetworkImage(chat.otherUserProfilePic!)
            : null,
        child: chat.otherUserProfilePic == null
            ? Text(
                (chat.otherUserName ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        chat.otherUserName ?? 'Unknown User',
        style: TextStyle(
          fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        chat.lastMessage ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
          fontWeight: chat.unreadCount > 0
              ? FontWeight.w500
              : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (chat.lastMessageAt != null)
            Text(
              _formatTime(chat.lastMessageAt!),
              style: TextStyle(
                color: chat.unreadCount > 0
                    ? const Color(0xFF3B6FE8)
                    : Colors.grey.shade500,
                fontSize: 12,
                fontWeight: chat.unreadCount > 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          if (chat.unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF3B6FE8),
                shape: BoxShape.circle,
              ),
              child: Text(
                chat.unreadCount > 9 ? '9+' : chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatArenaPage(
              conversationId: chat.id,
              otherUserId: chat.otherUserId,
              otherUserName: chat.otherUserName,
              otherUserProfilePic: chat.otherUserProfilePic,
            ),
          ),
        );
      },
    );
  }
}
