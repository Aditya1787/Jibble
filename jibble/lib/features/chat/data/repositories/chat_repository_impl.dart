import 'package:jibble/features/chat/domain/repositories/chat_repository.dart';
import 'package:jibble/features/chat/domain/entities/chat_entity.dart';
import 'package:jibble/features/chat/domain/entities/message_entity.dart';
import 'package:jibble/features/chat/data/datasources/chat_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatService remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChatEntity>> getRecentChats() async {
    return await remoteDataSource.getRecentChats();
  }

  @override
  Stream<List<ChatEntity>> getRecentChatsStream() {
    return remoteDataSource.getRecentChatsStream();
  }

  @override
  Future<List<MessageEntity>> getMessages(String conversationId) async {
    return await remoteDataSource.getMessages(conversationId);
  }

  @override
  Stream<List<MessageEntity>> getMessagesStream(String conversationId) {
    return remoteDataSource.getMessagesStream(conversationId);
  }

  @override
  Future<void> sendMessage(String receiverId, String content) async {
    await remoteDataSource.sendMessage(receiverId, content);
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    return await remoteDataSource.markAsRead(conversationId);
  }

  @override
  Future<String> getOrCreateConversation(String otherUserId) async {
    return await remoteDataSource.getOrCreateConversation(otherUserId);
  }

  @override
  void subscribeToMessages(
    String conversationId,
    void Function(MessageEntity) onMessage,
  ) {
    remoteDataSource.subscribeToMessages(
      conversationId,
      (model) => onMessage(model),
    );
  }

  @override
  void unsubscribeFromMessages(String conversationId) {
    remoteDataSource.unsubscribeFromMessages(conversationId);
  }
}
