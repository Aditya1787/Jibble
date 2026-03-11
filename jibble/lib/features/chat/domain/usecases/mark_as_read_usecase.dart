import 'package:jibble/features/chat/domain/repositories/chat_repository.dart';

class MarkAsReadUseCase {
  final ChatRepository repository;

  MarkAsReadUseCase(this.repository);

  Future<void> call(String conversationId) {
    return repository.markAsRead(conversationId);
  }
}
