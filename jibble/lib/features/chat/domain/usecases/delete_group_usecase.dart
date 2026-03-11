import 'package:jibble/features/chat/domain/repositories/group_repository.dart';

class DeleteGroupUseCase {
  final GroupRepository repository;

  DeleteGroupUseCase(this.repository);

  Future<void> call(String groupId) {
    return repository.deleteGroup(groupId);
  }
}
