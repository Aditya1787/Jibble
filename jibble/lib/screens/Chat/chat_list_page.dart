import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/group_service.dart';
import '../../models/chat_model.dart';
import '../../models/group_model.dart';
import '../../widgets/Chat/chat_list_item_widget.dart';
import 'create_group_page.dart';
import 'group_arena_page.dart';

/// Chat List Page
///
/// Two-tab layout: "Chats" (direct messages) + "Groups".
/// FAB on Groups tab → CreateGroupPage.
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _chatService = ChatService();
  final _groupService = GroupService();

  static const _purple = Color(0xFF6B4CE6);

  late TabController _tabController;

  // Direct chats
  List<ChatModel> _chats = [];
  bool _chatsLoading = true;
  String? _chatsError;

  // Groups
  List<GroupModel> _groups = [];
  bool _groupsLoading = true;
  String? _groupsError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadChats();
    _loadGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Load direct chats ────────────────────────────────────────────────────────

  Future<void> _loadChats() async {
    setState(() {
      _chatsLoading = true;
      _chatsError = null;
    });
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final chats = await _chatService.getConversations();
        if (mounted) setState(() => _chats = chats);
      }
    } catch (e) {
      if (mounted) setState(() => _chatsError = e.toString());
    } finally {
      if (mounted) setState(() => _chatsLoading = false);
    }
  }

  // ── Load groups ──────────────────────────────────────────────────────────────

  Future<void> _loadGroups() async {
    setState(() {
      _groupsLoading = true;
      _groupsError = null;
    });
    try {
      final groups = await _groupService.getMyGroups();
      if (mounted) setState(() => _groups = groups);
    } catch (e) {
      if (mounted) setState(() => _groupsError = e.toString());
    } finally {
      if (mounted) setState(() => _groupsLoading = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: _purple,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: _purple),
        bottom: TabBar(
          controller: _tabController,
          labelColor: _purple,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          indicatorColor: _purple,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Groups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildChatsTab(), _buildGroupsTab()],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          if (_tabController.index != 1) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: _goCreateGroup,
            backgroundColor: _purple,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.group_add_outlined),
            label: const Text(
              'New Group',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  // ── Chats tab ────────────────────────────────────────────────────────────────

  Widget _buildChatsTab() {
    if (_chatsLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_purple),
        ),
      );
    }
    if (_chatsError != null) {
      return _buildError(_chatsError!, _loadChats);
    }
    if (_chats.isEmpty) {
      return _buildEmptyChats();
    }
    return RefreshIndicator(
      onRefresh: _loadChats,
      color: _purple,
      child: ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (_, i) => ChatListItemWidget(chat: _chats[i]),
      ),
    );
  }

  Widget _buildEmptyChats() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation from a user profile',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ── Groups tab ───────────────────────────────────────────────────────────────

  Widget _buildGroupsTab() {
    if (_groupsLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_purple),
        ),
      );
    }
    if (_groupsError != null) {
      return _buildError(_groupsError!, _loadGroups);
    }
    if (_groups.isEmpty) {
      return _buildEmptyGroups();
    }
    return RefreshIndicator(
      onRefresh: _loadGroups,
      color: _purple,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: _groups.length,
        itemBuilder: (_, i) => _buildGroupTile(_groups[i]),
      ),
    );
  }

  Widget _buildGroupTile(GroupModel group) {
    return InkWell(
      onTap: () async {
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => GroupArenaPage(group: group)));
        _loadGroups(); // refresh after returning in case leave/delete
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  group.iconEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1A1A2E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (group.formattedTime.isNotEmpty)
                        Text(
                          group.formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 13,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${group.memberCount} members',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (group.lastMessage != null) ...[
                        Text(
                          ' · ',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            group.lastMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGroups() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.group_outlined, size: 44, color: _purple),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Groups Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a group to chat with multiple people at once.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _goCreateGroup,
              icon: const Icon(Icons.group_add_outlined),
              label: const Text(
                'Create Group',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared error widget ───────────────────────────────────────────────────────

  Widget _buildError(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation ────────────────────────────────────────────────────────────────

  Future<void> _goCreateGroup() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreateGroupPage()));
    _loadGroups(); // refresh list on return
  }
}
