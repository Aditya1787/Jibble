import 'package:jibble/features/chat/domain/repositories/group_repository.dart';
import 'package:jibble/features/chat/domain/entities/group_entity.dart';

class GetUserGroupsUseCase {
  final GroupRepository repository;

  GetUserGroupsUseCase(this.repository);

  Future<List<GroupEntity>> call() {
    return repository.getUserGroups();
  }
}
