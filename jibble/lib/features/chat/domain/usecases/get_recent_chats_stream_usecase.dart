import 'package:jibble/features/chat/domain/repositories/chat_repository.dart';
import 'package:jibble/features/chat/domain/entities/chat_entity.dart';

class GetRecentChatsStreamUseCase {
  final ChatRepository repository;

  GetRecentChatsStreamUseCase(this.repository);

  Stream<List<ChatEntity>> call() {
    return repository.getRecentChatsStream();
  }
}
