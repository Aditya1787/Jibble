import 'package:jibble/features/follow/domain/repositories/follow_repository.dart';

class RemoveFollowerUseCase {
  final FollowRepository repository;

  RemoveFollowerUseCase(this.repository);

  Future<void> call(String followerId) {
    return repository.removeFollower(followerId);
  }
}
