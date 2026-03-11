import 'package:jibble/features/chat/domain/repositories/chat_repository.dart';

class UnsubscribeFromMessagesUseCase {
  final ChatRepository repository;

  UnsubscribeFromMessagesUseCase(this.repository);

  void call(String conversationId) {
    repository.unsubscribeFromMessages(conversationId);
  }
}
