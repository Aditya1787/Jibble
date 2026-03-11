import 'package:jibble/features/post/domain/entities/post_entity.dart';

abstract class HomeRepository {
  Future<List<PostEntity>> fetchHomeFeedPaginated({
    required int page,
    required int limit,
  });
}
