import 'package:jibble/features/search/domain/repositories/user_search_repository.dart';
import 'package:jibble/features/search/domain/entities/user_search_entity.dart';

class GetUserBasicInfoUseCase {
  final UserSearchRepository repository;

  GetUserBasicInfoUseCase(this.repository);

  Future<UserSearchEntity?> call(String userId) {
    return repository.getUserBasicInfo(userId);
  }
}
