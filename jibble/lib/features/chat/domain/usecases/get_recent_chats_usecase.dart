import 'package:jibble/features/chat/domain/repositories/chat_repository.dart';
import 'package:jibble/features/chat/domain/entities/chat_entity.dart';

class GetRecentChatsUseCase {
  final ChatRepository repository;

  GetRecentChatsUseCase(this.repository);

  Future<List<ChatEntity>> call() {
    return repository.getRecentChats();
  }
}
