import 'package:jibble/features/chat/domain/repositories/group_repository.dart';
import 'package:jibble/features/chat/domain/entities/group_entity.dart';

class GetUserGroupsStreamUseCase {
  final GroupRepository repository;

  GetUserGroupsStreamUseCase(this.repository);

  Stream<List<GroupEntity>> call() {
    return repository.getUserGroupsStream();
  }
}
