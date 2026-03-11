import 'package:jibble/features/search/domain/repositories/user_search_repository.dart';
import 'package:jibble/features/profile/domain/entities/profile_entity.dart';

class GetUserProfileForSearchUseCase {
  final UserSearchRepository repository;

  GetUserProfileForSearchUseCase(this.repository);

  Future<ProfileEntity?> call(String userId) {
    return repository.getUserProfile(userId);
  }
}
