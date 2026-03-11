import 'package:jibble/features/chat/domain/entities/group_entity.dart';

/// Group Model
///
/// Represents a group chat and its members.
class GroupModel extends GroupEntity {
  GroupModel({
    required super.id,
    required super.name,
    required super.iconEmoji,
    required super.createdBy,
    required super.createdAt,
    super.lastMessage,
    super.lastMessageAt,
    List<GroupMemberModel> members = const [],
  }) : super(members: members);

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
}

// ── Member ────────────────────────────────────────────────────────────────────

/// Represents a single member inside a group.
class GroupMemberModel extends GroupMemberEntity {
  GroupMemberModel({
    required super.id,
    required super.groupId,
    required super.userId,
    required super.role,
    required super.joinedAt,
    super.username,
    super.name,
    super.profilePictureUrl,
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
}
