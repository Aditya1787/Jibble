import 'package:jibble/features/chat/domain/repositories/chat_repository.dart';
import 'package:jibble/features/chat/domain/entities/message_entity.dart';

class SubscribeToMessagesUseCase {
  final ChatRepository repository;

  SubscribeToMessagesUseCase(this.repository);

  void call(String conversationId, void Function(MessageEntity) onMessage) {
    repository.subscribeToMessages(conversationId, onMessage);
  }
}
