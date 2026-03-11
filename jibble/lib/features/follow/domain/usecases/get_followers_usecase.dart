import 'package:jibble/features/follow/domain/repositories/follow_repository.dart';
import 'package:jibble/features/search/domain/entities/user_search_entity.dart';

class GetFollowersUseCase {
  final FollowRepository repository;

  GetFollowersUseCase(this.repository);

  Future<List<UserSearchEntity>> call(String userId) {
    return repository.getFollowers(userId);
  }
}
