import 'package:jibble/features/follow/domain/repositories/follow_repository.dart';

class UnfollowUserUseCase {
  final FollowRepository repository;

  UnfollowUserUseCase(this.repository);

  Future<void> call(String followingId) {
    return repository.unfollowUser(followingId);
  }
}
