import 'package:jibble/features/search/domain/repositories/user_search_repository.dart';
import 'package:jibble/features/search/domain/entities/user_search_entity.dart';

class SearchUsersUseCase {
  final UserSearchRepository repository;

  SearchUsersUseCase(this.repository);

  Future<List<UserSearchEntity>> call(String query) {
    return repository.searchUsers(query);
  }
}
