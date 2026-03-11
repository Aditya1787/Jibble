import 'package:jibble/features/chat/domain/repositories/group_repository.dart';

class AddGroupMembersUseCase {
  final GroupRepository repository;

  AddGroupMembersUseCase(this.repository);

  Future<void> call({required String groupId, required List<String> userIds}) {
    return repository.addMembers(groupId: groupId, userIds: userIds);
  }
}
