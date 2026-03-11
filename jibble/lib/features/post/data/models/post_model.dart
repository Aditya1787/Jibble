import 'package:jibble/features/post/domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  PostModel({
    required super.id,
    super.userId,
    required super.type,
    super.caption,
    super.imageUrl,
    super.collegeName,
    required super.createdAt,
    super.username,
    super.fullName,
    super.profilePictureUrl,
    super.likesCount = 0,
    super.commentsCount = 0,
    super.isLikedByMe = false,
    super.recentLikerUsername,
  });

  factory PostModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final profile = json['profiles'];
    final postLikes = json['post_likes'] as List<dynamic>? ?? [];
    final postComments = json['post_comments'] as List<dynamic>? ?? [];

    bool isLiked = false;
    String? recentLiker;

    if (currentUserId != null) {
      isLiked = postLikes.any((like) => like['user_id'] == currentUserId);
    }

    // Attempt to get a recent liker's username (assuming the query joined profiles on post_likes)
    if (postLikes.isNotEmpty) {
      final firstLike = postLikes.first as Map<String, dynamic>;
      if (firstLike['profiles'] != null &&
          firstLike['profiles']['username'] != null) {
        recentLiker = firstLike['profiles']['username'] as String;
      }
    }

    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      type: json['type'] as String,
      caption: json['caption'] as String?,
      imageUrl: json['image_url'] as String?,
      collegeName: json['college_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),

      // If it's an anonymous confession, force these to null
      username: (json['type'] == 'confession')
          ? null
          : profile?['username'] as String?,
      fullName: (json['type'] == 'confession')
          ? null
          : profile?['name'] as String?,
      profilePictureUrl: (json['type'] == 'confession')
          ? null
          : profile?['profile_picture_url'] as String?,

      // Fallback to array length if exact count wasn't provided
      likesCount: json['likesCount'] as int? ?? postLikes.length,
      commentsCount: json['commentsCount'] as int? ?? postComments.length,
      isLikedByMe: isLiked,
      recentLikerUsername: recentLiker,
    );
  }

  String get displayName => (fullName != null && fullName!.isNotEmpty)
      ? fullName!
      : (username ?? 'Anonymous');

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  @override
  PostModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? caption,
    String? imageUrl,
    String? collegeName,
    DateTime? createdAt,
    String? username,
    String? fullName,
    String? profilePictureUrl,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByMe,
    String? recentLikerUsername,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      collegeName: collegeName ?? this.collegeName,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      recentLikerUsername: recentLikerUsername ?? this.recentLikerUsername,
    );
  }
}

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;

  final String? username;
  final String? fullName;
  final String? profilePictureUrl;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.username,
    this.fullName,
    this.profilePictureUrl,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      username: profile?['username'] as String?,
      fullName: profile?['name'] as String?,
      profilePictureUrl: profile?['profile_picture_url'] as String?,
    );
  }

  String get displayName => (fullName != null && fullName!.isNotEmpty)
      ? fullName!
      : (username ?? 'User');

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
