import 'package:jibble/features/follow/domain/repositories/follow_repository.dart';

class FollowUserUseCase {
  final FollowRepository repository;

  FollowUserUseCase(this.repository);

  Future<void> call(String followingId) {
    return repository.followUser(followingId);
  }
}
