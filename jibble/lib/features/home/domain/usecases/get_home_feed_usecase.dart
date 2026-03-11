import '../repositories/home_repository.dart';
import 'package:jibble/features/post/domain/entities/post_entity.dart';

class GetHomeFeedUseCase {
  final HomeRepository repository;

  GetHomeFeedUseCase(this.repository);

  Future<List<PostEntity>> call({required int page, required int limit}) {
    return repository.fetchHomeFeedPaginated(page: page, limit: limit);
  }
}
