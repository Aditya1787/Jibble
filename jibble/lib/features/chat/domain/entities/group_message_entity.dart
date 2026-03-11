class GroupMessageEntity {
  final String id;
  final String groupId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  final String? senderUsername;
  final String? senderProfilePic;

  const GroupMessageEntity({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.senderUsername,
    this.senderProfilePic,
  });

  bool isMine(String currentUserId) => senderId == currentUserId;

  String get senderDisplayName => senderUsername ?? 'User';

  String get formattedTime {
    final h = createdAt.hour.toString().padLeft(2, '0');
    final m = createdAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
