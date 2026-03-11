import 'package:jibble/features/chat/domain/entities/group_message_entity.dart';

/// Group Message Model
///
/// A single message inside a group chat.
class GroupMessageModel extends GroupMessageEntity {
  GroupMessageModel({
    required super.id,
    required super.groupId,
    required super.senderId,
    required super.content,
    required super.createdAt,
    super.senderUsername,
    super.senderProfilePic,
  });

  factory GroupMessageModel.fromJson(Map<String, dynamic> json) {
    final profileRaw = json['profiles'];
    final profile = profileRaw is Map<String, dynamic> ? profileRaw : null;

    return GroupMessageModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderUsername: profile?['username'] as String?,
      senderProfilePic: profile?['profile_picture_url'] as String?,
    );
  }

  bool isMine(String currentUserId) => senderId == currentUserId;

  String get senderDisplayName => senderUsername ?? 'User';

  String get formattedTime {
    final h = createdAt.hour.toString().padLeft(2, '0');
    final m = createdAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
