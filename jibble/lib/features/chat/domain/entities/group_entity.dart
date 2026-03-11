enum GroupRole { owner, member }

class GroupMemberEntity {
  final String id;
  final String groupId;
  final String userId;
  final GroupRole role;
  final DateTime joinedAt;

  final String? username;
  final String? name;
  final String? profilePictureUrl;

  const GroupMemberEntity({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.username,
    this.name,
    this.profilePictureUrl,
  });

  String get displayName =>
      (name != null && name!.isNotEmpty) ? name! : (username ?? 'User');

  String get initials =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

  bool get isOwner => role == GroupRole.owner;
}

class GroupEntity {
  final String id;
  final String name;
  final String iconEmoji;
  final String createdBy;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final List<GroupMemberEntity> members;

  const GroupEntity({
    required this.id,
    required this.name,
    required this.iconEmoji,
    required this.createdBy,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
    this.members = const [],
  });

  String get formattedTime {
    if (lastMessageAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    return '${lastMessageAt!.day}/${lastMessageAt!.month}';
  }

  int get memberCount => members.length;
}
