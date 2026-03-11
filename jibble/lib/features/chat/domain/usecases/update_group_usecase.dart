import 'package:jibble/features/chat/domain/repositories/group_repository.dart';

class UpdateGroupUseCase {
  final GroupRepository repository;

  UpdateGroupUseCase(this.repository);

  Future<void> call({
    required String groupId,
    String? name,
    String? iconEmoji,
  }) {
    return repository.updateGroup(
      groupId: groupId,
      name: name,
      iconEmoji: iconEmoji,
    );
  }
}
