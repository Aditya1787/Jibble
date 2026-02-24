/// Group Model
///
/// Represents a group chat and its members.
class GroupModel {
  final String id;
  final String name;
  final String iconEmoji;
  final String createdBy;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final List<GroupMemberModel> members;

  GroupModel({
    required this.id,
    required this.name,
    required this.iconEmoji,
    required this.createdBy,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
    this.members = const [],
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['group_members'] as List<dynamic>? ?? [];
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconEmoji: (json['icon_emoji'] as String?) ?? '👥',
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      members: rawMembers.map((m) => GroupMemberModel.fromJson(m)).toList(),
    );
  }

  /// Formatted time for the last message
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

// ── Member ────────────────────────────────────────────────────────────────────

/// Roles a member can have inside a group.
enum GroupRole { owner, member }

/// Represents a single member inside a group.
class GroupMemberModel {
  final String id; // group_members.id
  final String groupId;
  final String userId;
  final GroupRole role;
  final DateTime joinedAt;

  // Joined from profiles table
  final String? username;
  final String? name;
  final String? profilePictureUrl;

  GroupMemberModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.username,
    this.name,
    this.profilePictureUrl,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final profileRaw = json['profiles'];
    final profile = profileRaw is Map<String, dynamic> ? profileRaw : null;

    return GroupMemberModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      role: (json['role'] as String?) == 'owner'
          ? GroupRole.owner
          : GroupRole.member,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      username: profile?['username'] as String?,
      name: profile?['name'] as String?,
      profilePictureUrl: profile?['profile_picture_url'] as String?,
    );
  }

  /// Display name: real name → username → fallback
  String get displayName =>
      (name != null && name!.isNotEmpty) ? name! : (username ?? 'User');

  String get initials =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

  bool get isOwner => role == GroupRole.owner;
}
