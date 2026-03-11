class ChatEntity {
  final String id;
  final String otherUserId;
  final String? otherUserName;
  final String? otherUserProfilePic;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatEntity({
    required this.id,
    required this.otherUserId,
    this.otherUserName,
    this.otherUserProfilePic,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  String get displayName => otherUserName ?? 'User';

  String get formattedTime {
    if (lastMessageAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastMessageAt!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastMessageAt!.day}/${lastMessageAt!.month}/${lastMessageAt!.year}';
    }
  }
}
