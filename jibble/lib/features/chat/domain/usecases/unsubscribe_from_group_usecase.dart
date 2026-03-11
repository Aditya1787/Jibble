import 'package:jibble/features/chat/domain/repositories/group_repository.dart';

class UnsubscribeFromGroupUseCase {
  final GroupRepository repository;

  UnsubscribeFromGroupUseCase(this.repository);

  void call(String groupId) {
    repository.unsubscribeFromGroup(groupId);
  }
}
