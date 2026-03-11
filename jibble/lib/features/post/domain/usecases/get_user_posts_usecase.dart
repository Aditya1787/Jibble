import 'package:jibble/features/post/domain/repositories/post_repository.dart';
import 'package:jibble/features/post/domain/entities/post_entity.dart';

class GetUserPostsUseCase {
  final PostRepository repository;

  GetUserPostsUseCase(this.repository);

  Future<List<PostEntity>> call(String userId) {
    return repository.getUserPosts(userId);
  }
}
