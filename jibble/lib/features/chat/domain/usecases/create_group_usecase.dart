import 'package:jibble/features/chat/domain/repositories/group_repository.dart';
import 'package:jibble/features/chat/domain/entities/group_entity.dart';

class CreateGroupUseCase {
  final GroupRepository repository;

  CreateGroupUseCase(this.repository);

  Future<GroupEntity> call(
    String name,
    List<String> userIds, {
    String iconEmoji = '👥',
  }) {
    return repository.createGroup(name, userIds, iconEmoji: iconEmoji);
  }
}
