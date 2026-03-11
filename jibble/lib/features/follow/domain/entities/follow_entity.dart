abstract class FollowEntity {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  const FollowEntity({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });
}
