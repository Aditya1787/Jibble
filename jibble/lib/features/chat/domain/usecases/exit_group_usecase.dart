import 'package:jibble/features/chat/domain/repositories/group_repository.dart';

class ExitGroupUseCase {
  final GroupRepository repository;

  ExitGroupUseCase(this.repository);

  Future<void> call(String groupId) {
    return repository.exitGroup(groupId);
  }
}
