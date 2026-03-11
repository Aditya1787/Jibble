import 'package:jibble/features/chat/domain/repositories/chat_repository.dart';

class GetOrCreateConversationUseCase {
  final ChatRepository repository;

  GetOrCreateConversationUseCase(this.repository);

  Future<String> call(String otherUserId) {
    return repository.getOrCreateConversation(otherUserId);
  }
}
