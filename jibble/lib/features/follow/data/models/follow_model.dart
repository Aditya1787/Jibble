import 'package:jibble/features/follow/domain/entities/follow_entity.dart';

/// Follow Model
///
/// Represents a follow relationship between two users
class FollowModel extends FollowEntity {
  const FollowModel({
    required super.id,
    required super.followerId,
    required super.followingId,
    required super.createdAt,
  });

  /// Create a FollowModel from JSON
  factory FollowModel.fromJson(Map<String, dynamic> json) {
    return FollowModel(
      id: json['id'] as String,
      followerId: json['follower_id'] as String,
      followingId: json['following_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert FollowModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
