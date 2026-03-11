import 'package:jibble/features/follow/domain/repositories/follow_repository.dart';
import 'package:jibble/features/search/domain/entities/user_search_entity.dart';

class GetFollowingUseCase {
  final FollowRepository repository;

  GetFollowingUseCase(this.repository);

  Future<List<UserSearchEntity>> call(String userId) {
    return repository.getFollowing(userId);
  }
}
