import 'package:jibble/features/chat/domain/repositories/chat_repository.dart';
import 'package:jibble/features/chat/domain/entities/message_entity.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Future<List<MessageEntity>> call(String conversationId) {
    return repository.getMessages(conversationId);
  }
}
