import 'package:jibble/features/post/domain/repositories/post_repository.dart';

class ToggleLikeUseCase {
  final PostRepository repository;

  ToggleLikeUseCase(this.repository);

  Future<void> call(String postId, bool isCurrentlyLiked) {
    return repository.toggleLike(postId, isCurrentlyLiked);
  }
}
