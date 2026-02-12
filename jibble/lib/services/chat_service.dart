import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

/// Chat Service
///
/// Handles all chat and messaging operations including real-time subscriptions
class ChatService {
  final SupabaseClient _supabase = supabase;
  final Map<String, RealtimeChannel> _subscriptions = {};

  /// Get or create a conversation with another user
  Future<String> getOrCreateConversation(String otherUserId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      if (currentUserId == otherUserId) {
        throw Exception('Cannot create conversation with yourself');
      }

      // Ensure user1_id < user2_id for consistent ordering
      final user1Id = currentUserId.compareTo(otherUserId) < 0
          ? currentUserId
          : otherUserId;
      final user2Id = currentUserId.compareTo(otherUserId) < 0
          ? otherUserId
          : currentUserId;

      // Try to find existing conversation
      final existingConversation = await _supabase
          .from('conversations')
          .select('id')
          .eq('user1_id', user1Id)
          .eq('user2_id', user2Id)
          .maybeSingle();

      if (existingConversation != null) {
        return existingConversation['id'] as String;
      }

      // Create new conversation
      final newConversation = await _supabase
          .from('conversations')
          .insert({'user1_id': user1Id, 'user2_id': user2Id})
          .select('id')
          .single();

      return newConversation['id'] as String;
    } catch (e) {
      throw Exception('Failed to get or create conversation: $e');
    }
  }

  /// Get all conversations for the current user
  Future<List<ChatModel>> getConversations() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get conversations where user is either user1 or user2
      final response = await _supabase
          .from('conversations')
          .select('''
            id,
            user1_id,
            user2_id,
            last_message,
            last_message_at
          ''')
          .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId')
          .order('last_message_at', ascending: false);

      final conversations = <ChatModel>[];

      for (final conv in response as List) {
        // Determine the other user's ID
        final user1Id = conv['user1_id'] as String;
        final user2Id = conv['user2_id'] as String;
        final otherUserId = user1Id == currentUserId ? user2Id : user1Id;

        // Get other user's profile info
        final profile = await _supabase
            .from('profiles')
            .select('username, profile_picture_url')
            .eq('id', otherUserId)
            .maybeSingle();

        // Get unread count
        final unreadCount = await getUnreadCount(conv['id'] as String);

        // Create ChatModel with other user's info
        final chatData = {
          ...conv,
          'other_user_name': profile?['username'],
          'other_user_profile_pic': profile?['profile_picture_url'],
          'unread_count': unreadCount,
        };

        conversations.add(
          ChatModel.fromJson(
            Map<String, dynamic>.from(chatData),
            currentUserId,
          ),
        );
      }

      return conversations;
    } catch (e) {
      throw Exception('Failed to get conversations: $e');
    }
  }

  /// Get all messages in a conversation
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  /// Send a new message
  Future<MessageModel> sendMessage(
    String conversationId,
    String content,
  ) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      if (content.trim().isEmpty) {
        throw Exception('Message cannot be empty');
      }

      final response = await _supabase
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': currentUserId,
            'content': content.trim(),
          })
          .select()
          .single();

      return MessageModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Mark all messages in a conversation as read
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Mark all messages in this conversation that were NOT sent by current user as read
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', currentUserId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  /// Get unread message count for a conversation
  Future<int> getUnreadCount(String conversationId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        return 0;
      }

      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .neq('sender_id', currentUserId)
          .eq('is_read', false)
          .count();

      return response.count;
    } catch (e) {
      return 0;
    }
  }

  /// Subscribe to real-time messages in a conversation
  RealtimeChannel subscribeToMessages(
    String conversationId,
    Function(MessageModel) onMessage,
  ) {
    // Unsubscribe from previous subscription if exists
    if (_subscriptions.containsKey(conversationId)) {
      _subscriptions[conversationId]?.unsubscribe();
    }

    // Create new subscription
    final channel = _supabase
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final message = MessageModel.fromJson(payload.newRecord);
            onMessage(message);
          },
        )
        .subscribe();

    _subscriptions[conversationId] = channel;
    return channel;
  }

  /// Unsubscribe from a conversation's messages
  void unsubscribeFromMessages(String conversationId) {
    if (_subscriptions.containsKey(conversationId)) {
      _subscriptions[conversationId]?.unsubscribe();
      _subscriptions.remove(conversationId);
    }
  }

  /// Unsubscribe from all conversations
  void unsubscribeAll() {
    for (final channel in _subscriptions.values) {
      channel.unsubscribe();
    }
    _subscriptions.clear();
  }

  /// Get conversation by ID with other user's info
  Future<ChatModel?> getConversationById(String conversationId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final conv = await _supabase
          .from('conversations')
          .select('''
            id,
            user1_id,
            user2_id,
            last_message,
            last_message_at
          ''')
          .eq('id', conversationId)
          .maybeSingle();

      if (conv == null) return null;

      // Determine the other user's ID
      final user1Id = conv['user1_id'] as String;
      final user2Id = conv['user2_id'] as String;
      final otherUserId = user1Id == currentUserId ? user2Id : user1Id;

      // Get other user's profile info
      final profile = await _supabase
          .from('profiles')
          .select('username, profile_picture_url')
          .eq('id', otherUserId)
          .maybeSingle();

      // Get unread count
      final unreadCount = await getUnreadCount(conversationId);

      // Create ChatModel with other user's info
      final chatData = {
        ...conv,
        'other_user_name': profile?['username'],
        'other_user_profile_pic': profile?['profile_picture_url'],
        'unread_count': unreadCount,
      };

      return ChatModel.fromJson(chatData, currentUserId);
    } catch (e) {
      throw Exception('Failed to get conversation: $e');
    }
  }
}
