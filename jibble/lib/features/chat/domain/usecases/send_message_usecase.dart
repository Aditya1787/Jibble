import 'package:jibble/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> call(String receiverId, String content) {
    return repository.sendMessage(receiverId, content);
  }
}
