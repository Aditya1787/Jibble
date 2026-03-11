import 'package:jibble/features/follow/domain/repositories/follow_repository.dart';
import 'package:jibble/features/search/domain/entities/user_search_entity.dart';
import 'package:jibble/features/follow/data/datasources/follow_service.dart';

class FollowRepositoryImpl implements FollowRepository {
  final FollowService remoteDataSource;

  FollowRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> followUser(String followingId) async {
    await remoteDataSource.followUser(followingId);
  }

  @override
  Future<void> unfollowUser(String followingId) async {
    await remoteDataSource.unfollowUser(followingId);
  }

  @override
  Future<bool> isFollowing(String userId) async {
    return await remoteDataSource.isFollowing(userId);
  }

  @override
  Future<int> getFollowerCount(String userId) async {
    return await remoteDataSource.getFollowerCount(userId);
  }

  @override
  Future<int> getFollowingCount(String userId) async {
    return await remoteDataSource.getFollowingCount(userId);
  }

  @override
  Future<List<UserSearchEntity>> getFollowers(String userId) async {
    return await remoteDataSource.getFollowers(userId);
  }

  @override
  Future<List<UserSearchEntity>> getFollowing(String userId) async {
    return await remoteDataSource.getFollowing(userId);
  }

  @override
  Future<void> removeFollower(String followerId) async {
    await remoteDataSource.removeFollower(followerId);
  }
}
