import 'package:jibble/features/chat/domain/repositories/group_repository.dart';
import 'package:jibble/features/chat/domain/entities/group_message_entity.dart';

class GetGroupMessagesStreamUseCase {
  final GroupRepository repository;

  GetGroupMessagesStreamUseCase(this.repository);

  Stream<List<GroupMessageEntity>> call(String groupId) {
    return repository.getGroupMessagesStream(groupId);
  }
}
