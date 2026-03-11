import 'package:jibble/features/follow/domain/repositories/follow_repository.dart';

class IsFollowingUseCase {
  final FollowRepository repository;

  IsFollowingUseCase(this.repository);

  Future<bool> call(String userId) {
    return repository.isFollowing(userId);
  }
}
