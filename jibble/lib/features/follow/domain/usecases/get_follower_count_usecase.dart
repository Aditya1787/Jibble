import 'package:jibble/features/follow/domain/repositories/follow_repository.dart';

class GetFollowerCountUseCase {
  final FollowRepository repository;

  GetFollowerCountUseCase(this.repository);

  Future<int> call(String userId) {
    return repository.getFollowerCount(userId);
  }
}
