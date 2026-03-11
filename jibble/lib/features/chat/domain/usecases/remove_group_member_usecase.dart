import 'package:jibble/features/chat/domain/repositories/group_repository.dart';

class RemoveGroupMemberUseCase {
  final GroupRepository repository;

  RemoveGroupMemberUseCase(this.repository);

  Future<void> call({required String groupId, required String userId}) {
    return repository.removeMember(groupId: groupId, userId: userId);
  }
}
