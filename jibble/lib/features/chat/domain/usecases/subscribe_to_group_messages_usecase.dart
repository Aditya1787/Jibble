import 'package:jibble/features/chat/domain/repositories/group_repository.dart';
import 'package:jibble/features/chat/domain/entities/group_message_entity.dart';

class SubscribeToGroupMessagesUseCase {
  final GroupRepository repository;

  SubscribeToGroupMessagesUseCase(this.repository);

  void call(String groupId, void Function(GroupMessageEntity) onMessage) {
    repository.subscribeToGroupMessages(groupId, onMessage);
  }
}
