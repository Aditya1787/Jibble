/// Chat Model
///
/// Represents a conversation with another user
class ChatModel {
  final String id;
  final String otherUserId;
  final String? otherUserName;
  final String? otherUserProfilePic;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ChatModel({
    required this.id,
    required this.otherUserId,
    this.otherUserName,
    this.otherUserProfilePic,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  /// Create a ChatModel from JSON
  /// Note: This assumes the JSON includes the other user's info
  factory ChatModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    // Determine which user is the "other" user
    final user1Id = json['user1_id'] as String;
    final user2Id = json['user2_id'] as String;
    final otherUserId = user1Id == currentUserId ? user2Id : user1Id;

    return ChatModel(
      id: json['id'] as String,
      otherUserId: otherUserId,
      otherUserName: json['other_user_name'] as String?,
      otherUserProfilePic: json['other_user_profile_pic'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  /// Convert ChatModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'other_user_id': otherUserId,
      'other_user_name': otherUserName,
      'other_user_profile_pic': otherUserProfilePic,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_count': unreadCount,
    };
  }

  /// Get display name for the other user
  String get displayName => otherUserName ?? 'User';

  /// Get formatted last message time
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

  /// Create a copy with updated fields
  ChatModel copyWith({
    String? id,
    String? otherUserId,
    String? otherUserName,
    String? otherUserProfilePic,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return ChatModel(
      id: id ?? this.id,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserProfilePic: otherUserProfilePic ?? this.otherUserProfilePic,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
