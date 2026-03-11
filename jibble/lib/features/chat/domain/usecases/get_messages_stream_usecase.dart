import 'package:jibble/features/chat/domain/repositories/chat_repository.dart';
import 'package:jibble/features/chat/domain/entities/message_entity.dart';

class GetMessagesStreamUseCase {
  final ChatRepository repository;

  GetMessagesStreamUseCase(this.repository);

  Stream<List<MessageEntity>> call(String conversationId) {
    return repository.getMessagesStream(conversationId);
  }
}
