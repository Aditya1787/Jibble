import 'package:jibble/features/post/domain/entities/post_entity.dart';
import 'package:jibble/features/post/domain/repositories/post_repository.dart';

class GetCircleFeedUseCase {
  final PostRepository repository;

  GetCircleFeedUseCase(this.repository);

  Future<List<PostEntity>> call(String postType) {
    return repository.fetchCircleFeed(postType);
  }
}
