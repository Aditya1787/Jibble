import 'package:jibble/features/follow/domain/repositories/follow_repository.dart';

class GetFollowingCountUseCase {
  final FollowRepository repository;

  GetFollowingCountUseCase(this.repository);

  Future<int> call(String userId) {
    return repository.getFollowingCount(userId);
  }
}
