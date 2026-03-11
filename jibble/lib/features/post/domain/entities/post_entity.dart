class PostEntity {
  final String id;
  final String? userId; // Null for anonymous confessions
  final String type; // 'standard', 'event', 'confession'
  final String? caption;
  final String? imageUrl;
  final String? collegeName;
  final DateTime createdAt;

  // Joined from profiles
  final String? username;
  final String? fullName;
  final String? profilePictureUrl;

  // Computed counters
  final int likesCount;
  final int commentsCount;

  // Has the current user liked it?
  final bool isLikedByMe;

  // Who recently liked it (for UI)
  final String? recentLikerUsername;

  const PostEntity({
    required this.id,
    this.userId,
    required this.type,
    this.caption,
    this.imageUrl,
    this.collegeName,
    required this.createdAt,
    this.username,
    this.fullName,
    this.profilePictureUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLikedByMe = false,
    this.recentLikerUsername,
  });

  PostEntity copyWith({
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
    return PostEntity(
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
}
