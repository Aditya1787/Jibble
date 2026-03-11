import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jibble/core/di/injection_container.dart';
import 'package:jibble/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/get_or_create_conversation_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/mark_as_read_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/subscribe_to_messages_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/unsubscribe_from_messages_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:jibble/features/chat/domain/entities/message_entity.dart';
import 'package:jibble/features/profile/presentation/screens/user_profile_page.dart';
import 'package:jibble/features/profile/presentation/screens/fullscreen_photo_page.dart';

/// Chat Arena Page
///
/// Full-screen chat conversation between two users.
class ChatArenaPage extends StatefulWidget {
  /// ID of an existing conversation, or empty string to create a new one.
  final String conversationId;
  final String otherUserId;
  final String? otherUserName;
  final String? otherUserProfilePic;

  const ChatArenaPage({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    this.otherUserName,
    this.otherUserProfilePic,
  });

  @override
  State<ChatArenaPage> createState() => _ChatArenaPageState();
}

class _ChatArenaPageState extends State<ChatArenaPage> {
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final GetOrCreateConversationUseCase _getOrCreateConversationUseCase;
  late final GetMessagesUseCase _getMessagesUseCase;
  late final MarkAsReadUseCase _markAsReadUseCase;
  late final SubscribeToMessagesUseCase _subscribeToMessagesUseCase;
  late final UnsubscribeFromMessagesUseCase _unsubscribeFromMessagesUseCase;
  late final SendMessageUseCase _sendMessageUseCase;

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  static const _primaryColor = Color(0xFF3B6FE8);

  String _conversationId = '';
  List<MessageEntity> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
    _getOrCreateConversationUseCase = sl<GetOrCreateConversationUseCase>();
    _getMessagesUseCase = sl<GetMessagesUseCase>();
    _markAsReadUseCase = sl<MarkAsReadUseCase>();
    _subscribeToMessagesUseCase = sl<SubscribeToMessagesUseCase>();
    _unsubscribeFromMessagesUseCase = sl<UnsubscribeFromMessagesUseCase>();
    _sendMessageUseCase = sl<SendMessageUseCase>();

    _currentUserId = _getCurrentUserUseCase()?.id;
    _conversationId = widget.conversationId;
    _initConversation();
  }

  @override
  void dispose() {
    _unsubscribeFromMessagesUseCase(_conversationId);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initConversation() async {
    try {
      // Get or create the conversation
      if (_conversationId.isEmpty) {
        _conversationId = await _getOrCreateConversationUseCase(
          widget.otherUserId,
        );
      }

      // Load existing messages
      final messages = await _getMessagesUseCase(_conversationId);

      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }

      // Mark messages as read
      await _markAsReadUseCase(_conversationId);

      // Subscribe to new messages in real time
      _subscribeToMessagesUseCase(_conversationId, (message) {
        if (mounted) {
          setState(() => _messages.add(message));
          _scrollToBottom();
          _markAsReadUseCase(_conversationId);
        }
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // â”€â”€ Navigation helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _openOtherProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfilePage(userId: widget.otherUserId),
      ),
    );
  }

  void _openOtherPhoto() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenPhotoPage(
          imageUrl: widget.otherUserProfilePic,
          heroTag: 'avatar_arena_${widget.otherUserId}',
          displayName: widget.otherUserName ?? 'User',
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await _sendMessageUseCase(_conversationId, content);
      // Let real-time handle adding new msg
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _messageController.text = content; // restore
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: _openOtherProfile,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              // Avatar â†’ view photo
              GestureDetector(
                onTap: _openOtherPhoto,
                child: Hero(
                  tag: 'avatar_arena_${widget.otherUserId}',
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: _primaryColor.withValues(alpha: 0.15),
                    backgroundImage: widget.otherUserProfilePic != null
                        ? NetworkImage(widget.otherUserProfilePic!)
                        : null,
                    child: widget.otherUserProfilePic == null
                        ? Text(
                            (widget.otherUserName ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              color: _primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name â†’ view profile
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName ?? 'Chat',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Tap to view profile',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // â”€â”€ Messages list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                    ),
                  )
                : _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No messages yet.\nSay hello! ðŸ‘‹',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _buildMessageBubble(_messages[i]),
                  ),
          ),

          // â”€â”€ Message input â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              8,
              MediaQuery.of(context).padding.bottom + 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Type a messageâ€¦',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: const Color(0xFFF4F6FB),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: _primaryColor,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _isSending ? null : _sendMessage,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageEntity message) {
    final isMine = message.senderId == _currentUserId;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? _primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMine ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: isMine
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.grey.shade400,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
