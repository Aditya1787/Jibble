import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import '../../models/message_model.dart';
import '../../services/auth_service.dart'; // Added for current user ID
import '../../widgets/Chat/message_bubble_widget.dart';

/// Chat Arena Page
///
/// The main chat interface for one-to-one messaging
class ChatArenaPage extends StatefulWidget {
  final String conversationId;
  final String? otherUserId; // Optional if starting new conversation
  final String? otherUserName;
  final String? otherUserProfilePic;

  const ChatArenaPage({
    super.key,
    required this.conversationId,
    this.otherUserId,
    this.otherUserName,
    this.otherUserProfilePic,
  });

  @override
  State<ChatArenaPage> createState() => _ChatArenaPageState();
}

class _ChatArenaPageState extends State<ChatArenaPage> {
  final _chatService = ChatService();
  final _authService = AuthService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  List<MessageModel> _messages = [];
  bool _isLoading = true;
  String? _currentUserId;
  String _activeConversationId = '';

  // To handle the case where we might need to create a conversation first
  // although mostly we expect a valid conversationId passed in

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.currentUser?.id;
    _activeConversationId = widget.conversationId;
    _loadMessages();
    _subscribeToMessages();

    // Mark messages as read when entering the chat
    if (_activeConversationId.isNotEmpty) {
      _chatService.markMessagesAsRead(_activeConversationId);
    }
  }

  @override
  void dispose() {
    _chatService.unsubscribeFromMessages(_activeConversationId);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (_activeConversationId.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await _chatService.getMessages(_activeConversationId);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error cleanly
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load messages: $e')));
      }
    }
  }

  void _subscribeToMessages() {
    if (_activeConversationId.isEmpty) return;

    _chatService.subscribeToMessages(_activeConversationId, (newMessage) {
      if (!mounted) return;

      setState(() {
        _messages.add(newMessage);
      });
      _scrollToBottom();

      // Mark as read if we are looking at the screen
      // Ideally we should check if app is in foreground
      _chatService.markMessagesAsRead(_activeConversationId);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    try {
      // If we don't have a conversation ID yet (shouldn't happen with current flow but good for safety)
      if (_activeConversationId.isEmpty && widget.otherUserId != null) {
        final newId = await _chatService.getOrCreateConversation(
          widget.otherUserId!,
        );
        setState(() {
          _activeConversationId = newId;
        });
        _subscribeToMessages();
      }

      final message = await _chatService.sendMessage(
        _activeConversationId,
        content,
      );

      // We don't need to add it manually if subscription is working,
      // but adding it provides immediate feedback before the server roundgrip
      // However, to avoid duplicates if subscription is fast, we can check
      if (!_messages.any((m) => m.id == message.id)) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(body: Center(child: Text('Please log in to chat')));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Slightly off-white background
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
              ),
              child: widget.otherUserProfilePic != null
                  ? ClipOval(
                      child: Image.network(
                        widget.otherUserProfilePic!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  : Icon(Icons.person, size: 20, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName ?? 'User',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Online status could go here
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6B4CE6),
                      ),
                    ),
                  )
                : _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.waving_hand_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Say hello!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMine = message.senderId == _currentUserId;

                      // Check if we need to show date separator
                      // Implement date headers if needed later

                      return MessageBubbleWidget(
                        message: message,
                        isMine: isMine,
                      );
                    },
                  ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _messageController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          isDense: true,
                        ),
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF6B4CE6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
