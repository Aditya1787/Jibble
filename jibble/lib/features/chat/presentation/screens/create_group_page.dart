import 'package:flutter/material.dart';
import 'package:jibble/core/di/injection_container.dart';
import 'package:jibble/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jibble/features/search/domain/usecases/search_users_usecase.dart';
import 'package:jibble/features/chat/domain/usecases/create_group_usecase.dart';
import 'package:jibble/features/search/domain/entities/user_search_entity.dart';
import 'package:jibble/features/chat/presentation/screens/group_arena_page.dart';

/// Create Group Page
///
/// Step 1: Enter group name + pick an emoji icon
/// Step 2: Pick members from your search list
/// Creates the group and navigates to GroupArenaPage on success.
class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final SearchUsersUseCase _searchUsersUseCase;
  late final CreateGroupUseCase _createGroupUseCase;

  final _nameController = TextEditingController();
  final _searchController = TextEditingController();

  static const _purple = Color(0xFF6B4CE6);

  // Emoji options
  static const _emojis = [
    'ðŸ‘¥',
    'ðŸŽ“',
    'ðŸš€',
    'ðŸŽ®',
    'ðŸ“š',
    'ðŸ‹ï¸',
    'ðŸŽµ',
    'ðŸŽ¨',
    'â¤ï¸',
    'âš½',
    'ðŸ•',
    'ðŸŒ',
    'ðŸ’¡',
    'ðŸ”¥',
    'âœ¨',
    'ðŸŽ­',
  ];

  String _selectedEmoji = 'ðŸ‘¥';
  List<UserSearchEntity> _searchResults = [];
  final Set<String> _selectedIds = {};
  final Map<String, UserSearchEntity> _selectedUsers = {};
  bool _isSearching = false;
  bool _isCreating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
    _searchUsersUseCase = sl<SearchUsersUseCase>();
    _createGroupUseCase = sl<CreateGroupUseCase>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await _searchUsersUseCase(query.trim());
      final myId = _getCurrentUserUseCase()?.id;
      if (mounted) {
        setState(() {
          _searchResults = results.where((u) => u.id != myId).toList();
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _toggleUser(UserSearchEntity user) {
    setState(() {
      if (_selectedIds.contains(user.id)) {
        _selectedIds.remove(user.id);
        _selectedUsers.remove(user.id);
      } else {
        _selectedIds.add(user.id);
        _selectedUsers[user.id] = user;
      }
    });
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a group name');
      return;
    }
    if (_selectedIds.isEmpty) {
      setState(() => _error = 'Please add at least one member');
      return;
    }

    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      final group = await _createGroupUseCase(
        name,
        _selectedIds.toList(),
        iconEmoji: _selectedEmoji,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => GroupArenaPage(group: group)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isCreating = false;
        });
      }
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
        title: const Text(
          'New Group',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _purple,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isCreating ? null : _create,
              child: _isCreating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(_purple),
                      ),
                    )
                  : const Text(
                      'Create',
                      style: TextStyle(
                        color: _purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // â”€â”€ Group info section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji + Name row
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showEmojiPicker,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _purple.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _selectedEmoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        autofocus: true,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Group name',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.normal,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: _purple,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                        ),
                        onChanged: (_) => setState(() => _error = null),
                      ),
                    ),
                  ],
                ),

                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),

          // â”€â”€ Selected members chips â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (_selectedUsers.isNotEmpty)
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Members (${_selectedIds.length})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _selectedUsers.values.map((u) {
                      return Chip(
                        avatar: CircleAvatar(
                          backgroundColor: _purple.withValues(alpha: 0.15),
                          backgroundImage: u.profilePictureUrl != null
                              ? NetworkImage(u.profilePictureUrl!)
                              : null,
                          child: u.profilePictureUrl == null
                              ? Text(
                                  u.displayName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: _purple,
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                        ),
                        label: Text(
                          u.displayName,
                          style: const TextStyle(fontSize: 13),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _toggleUser(u),
                        backgroundColor: _purple.withValues(alpha: 0.06),
                        side: BorderSide(
                          color: _purple.withValues(alpha: 0.15),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // â”€â”€ Search bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            color: Colors.white,
            margin: const EdgeInsets.only(top: 1),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search people to addâ€¦',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey.shade400,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF4F6FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // â”€â”€ Search results â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_purple),
                    ),
                  )
                : _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 52,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Search for people to add'
                              : 'No users found',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 32),
                    itemCount: _searchResults.length,
                    itemBuilder: (_, i) {
                      final u = _searchResults[i];
                      final selected = _selectedIds.contains(u.id);
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: _purple.withValues(alpha: 0.12),
                          backgroundImage: u.profilePictureUrl != null
                              ? NetworkImage(u.profilePictureUrl!)
                              : null,
                          child: u.profilePictureUrl == null
                              ? Text(
                                  u.displayName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: _purple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          u.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: u.collegeName != null
                            ? Text(
                                u.collegeName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              )
                            : null,
                        trailing: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? _purple : Colors.transparent,
                            border: Border.all(
                              color: selected ? _purple : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        onTap: () => _toggleUser(u),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Group Icon',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _emojis.length,
                itemBuilder: (_, i) {
                  final emoji = _emojis[i];
                  final selected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedEmoji = emoji);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected
                            ? _purple.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: selected
                            ? Border.all(color: _purple, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
