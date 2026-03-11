import 'package:jibble/features/search/domain/entities/user_search_entity.dart';

abstract class FollowRepository {
  Future<void> followUser(String followingId);
  Future<void> unfollowUser(String followingId);
  Future<bool> isFollowing(String userId);
  Future<int> getFollowerCount(String userId);
  Future<int> getFollowingCount(String userId);
  Future<List<UserSearchEntity>> getFollowers(String userId);
  Future<List<UserSearchEntity>> getFollowing(String userId);
  Future<void> removeFollower(String followerId);
}
