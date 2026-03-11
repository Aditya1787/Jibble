import 'package:jibble/features/chat/domain/entities/chat_entity.dart';
import 'package:jibble/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Future<List<ChatEntity>> getRecentChats();
  Stream<List<ChatEntity>> getRecentChatsStream();
  Future<List<MessageEntity>> getMessages(String conversationId);
  Stream<List<MessageEntity>> getMessagesStream(String conversationId);
  Future<void> sendMessage(String receiverId, String content);
  Future<void> markAsRead(String conversationId);
  Future<String> getOrCreateConversation(String otherUserId);
  void subscribeToMessages(
    String conversationId,
    void Function(MessageEntity) onMessage,
  );
  void unsubscribeFromMessages(String conversationId);
}
