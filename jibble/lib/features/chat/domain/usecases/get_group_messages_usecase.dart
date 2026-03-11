import 'package:jibble/features/chat/domain/repositories/group_repository.dart';
import 'package:jibble/features/chat/domain/entities/group_message_entity.dart';

class GetGroupMessagesUseCase {
  final GroupRepository repository;

  GetGroupMessagesUseCase(this.repository);

  Future<List<GroupMessageEntity>> call(String groupId) {
    return repository.getGroupMessages(groupId);
  }
}
