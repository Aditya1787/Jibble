import 'package:jibble/features/chat/domain/repositories/group_repository.dart';
import 'package:jibble/features/chat/domain/entities/group_entity.dart';

class GetGroupByIdUseCase {
  final GroupRepository repository;

  GetGroupByIdUseCase(this.repository);

  Future<GroupEntity> call(String groupId) {
    return repository.getGroupById(groupId);
  }
}
