import 'package:jibble/features/post/domain/repositories/post_repository.dart';

class DeletePostUseCase {
  final PostRepository repository;

  DeletePostUseCase(this.repository);

  Future<void> call(String postId) {
    return repository.deletePost(postId);
  }
}
