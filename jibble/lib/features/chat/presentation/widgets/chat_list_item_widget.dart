import 'package:flutter/material.dart';
import 'package:jibble/features/chat/domain/entities/chat_entity.dart';
import 'package:jibble/features/chat/presentation/screens/chat_arena_page.dart';
import 'package:jibble/features/profile/presentation/screens/user_profile_page.dart';
import 'package:jibble/features/profile/presentation/screens/fullscreen_photo_page.dart';

/// Chat List Item Widget
///
/// Displays a single chat conversation in the chat list.
/// â€¢ Tap the row â†’ open chat
/// â€¢ Tap the avatar â†’ bottom sheet (View Profile / Open Chat / View Photo)
class ChatListItemWidget extends StatelessWidget {
  final ChatEntity chat;

  const ChatListItemWidget({super.key, required this.chat});

  // â”€â”€ helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  void _openChat(BuildContext context) {
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
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfilePage(userId: chat.otherUserId),
      ),
    );
  }

  void _openPhoto(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenPhotoPage(
          imageUrl: chat.otherUserProfilePic,
          heroTag: 'avatar_chat_list_${chat.otherUserId}',
          displayName: chat.otherUserName ?? 'User',
        ),
      ),
    );
  }

  // â”€â”€ bottom sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showAvatarOptions(BuildContext context) {
    final displayName = chat.otherUserName ?? 'User';
    final hasPhoto = chat.otherUserProfilePic != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Avatar preview row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Hero(
                    tag: 'avatar_chat_list_${chat.otherUserId}',
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF3B6FE8),
                      backgroundImage: hasPhoto
                          ? NetworkImage(chat.otherUserProfilePic!)
                          : null,
                      child: !hasPhoto
                          ? Text(
                              displayName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '@$displayName',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 24),

            // Option: View Profile
            _OptionTile(
              icon: Icons.person_outline_rounded,
              label: 'View Profile',
              onTap: () {
                Navigator.of(context).pop();
                _openProfile(context);
              },
            ),

            // Option: Open Chat
            _OptionTile(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Open Chat',
              onTap: () {
                Navigator.of(context).pop();
                _openChat(context);
              },
            ),

            // Option: View Profile Photo
            _OptionTile(
              icon: Icons.photo_outlined,
              label: 'View Profile Photo',
              onTap: () {
                Navigator.of(context).pop();
                _openPhoto(context);
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // â”€â”€ build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: GestureDetector(
        onTap: () => _showAvatarOptions(context),
        child: Hero(
          tag: 'avatar_chat_list_${chat.otherUserId}',
          child: CircleAvatar(
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
        ),
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
      onTap: () => _openChat(context),
    );
  }
}

// â”€â”€ Private helper widget â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF3B6FE8).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF3B6FE8), size: 22),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
