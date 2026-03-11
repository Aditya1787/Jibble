import '../../domain/repositories/home_repository.dart';
import 'package:jibble/features/post/domain/entities/post_entity.dart';
import 'package:jibble/features/post/data/datasources/post_service.dart';

class HomeRepositoryImpl implements HomeRepository {
  final PostService remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PostEntity>> fetchHomeFeedPaginated({
    required int page,
    required int limit,
  }) async {
    final models = await remoteDataSource.fetchHomeFeedPaginated(
      page: page,
      limit: limit,
    );
    return models.cast<PostEntity>();
  }
}
