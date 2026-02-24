import 'package:flutter/material.dart';
import 'package:jibble/features/auth/data/datasources/auth_service.dart';
import 'package:jibble/features/chat/data/datasources/group_service.dart';
import 'package:jibble/features/search/data/datasources/user_search_service.dart';
import 'package:jibble/features/chat/data/models/group_model.dart';
import 'package:jibble/features/search/data/models/user_search_model.dart';

/// Group Settings Page
///
/// Owner capabilities:
///  â€¢ Rename group / change emoji icon
///  â€¢ Add members
///  â€¢ Remove members
///  â€¢ Transfer ownership (make someone owner)
///  â€¢ Delete group
///
/// All members:
///  â€¢ View members list
///  â€¢ Exit group
class GroupSettingsPage extends StatefulWidget {
  final GroupModel group;

  const GroupSettingsPage({super.key, required this.group});

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  final _groupService = GroupService();
  final _authService = AuthService();
  final _userSearchService = UserSearchService();

  static const _purple = Color(0xFF6B4CE6);
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

  late GroupModel _group;
  late TextEditingController _nameController;
  String? _currentUserId;
  bool _isOwner = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _currentUserId = _authService.currentUser?.id;
    _isOwner = _groupService.isOwnerOf(_group);
    _nameController = TextEditingController(text: _group.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // â”€â”€ Save name + emoji â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _saveInfo() async {
    if (!_isOwner) return;
    setState(() => _isSaving = true);
    try {
      await _groupService.updateGroup(
        groupId: _group.id,
        name: _nameController.text,
        iconEmoji: _group.iconEmoji,
      );
      final updated = await _groupService.getGroupById(_group.id);
      if (mounted) setState(() => _group = updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // â”€â”€ Change emoji â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _pickEmoji() {
    if (!_isOwner) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Icon',
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
                final e = _emojis[i];
                final sel = e == _group.iconEmoji;
                return GestureDetector(
                  onTap: () {
                    setState(
                      () => _group = GroupModel.fromJson({
                        'id': _group.id,
                        'name': _group.name,
                        'icon_emoji': e,
                        'created_by': _group.createdBy,
                        'created_at': _group.createdAt.toIso8601String(),
                        'last_message': _group.lastMessage,
                        'last_message_at': _group.lastMessageAt
                            ?.toIso8601String(),
                        'group_members': [],
                      }),
                    );
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: sel
                          ? _purple.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: sel
                          ? Border.all(color: _purple, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Add members â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showAddMembers() {
    final searchCtrl = TextEditingController();
    List<UserSearchModel> results = [];
    final Set<String> adding = {};
    final existingIds = _group.members.map((m) => m.userId).toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.75,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add Members',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search usersâ€¦',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF4F6FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (q) async {
                      if (q.trim().isEmpty) {
                        setModal(() => results = []);
                        return;
                      }
                      final r = await _userSearchService.searchUsers(q.trim());
                      setModal(
                        () => results = r
                            .where((u) => !existingIds.contains(u.id))
                            .toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final u = results[i];
                      final sel = adding.contains(u.id);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _purple.withValues(alpha: 0.12),
                          backgroundImage: u.profilePictureUrl != null
                              ? NetworkImage(u.profilePictureUrl!)
                              : null,
                          child: u.profilePictureUrl == null
                              ? Text(
                                  u.displayName[0].toUpperCase(),
                                  style: const TextStyle(color: _purple),
                                )
                              : null,
                        ),
                        title: Text(u.displayName),
                        trailing: Checkbox(
                          value: sel,
                          activeColor: _purple,
                          onChanged: (_) => setModal(() {
                            sel ? adding.remove(u.id) : adding.add(u.id);
                          }),
                        ),
                        onTap: () => setModal(() {
                          sel ? adding.remove(u.id) : adding.add(u.id);
                        }),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: adding.isEmpty
                          ? null
                          : () async {
                              Navigator.pop(ctx);
                              await _groupService.addMembers(
                                groupId: _group.id,
                                userIds: adding.toList(),
                              );
                              final updated = await _groupService.getGroupById(
                                _group.id,
                              );
                              if (mounted) {
                                setState(() => _group = updated);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        adding.isEmpty
                            ? 'Select members to add'
                            : 'Add ${adding.length} member${adding.length == 1 ? '' : 's'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // â”€â”€ Member options â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showMemberOptions(GroupMemberModel member) {
    if (!_isOwner || member.userId == _currentUserId) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              member.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            // Transfer ownership
            if (!member.isOwner)
              ListTile(
                leading: const Icon(Icons.star_outline, color: _purple),
                title: const Text('Make Owner'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirm = await _showConfirm(
                    'Transfer Ownership',
                    'Make ${member.displayName} the owner? You will become a regular member.',
                  );
                  if (confirm) {
                    await _groupService.transferOwnership(
                      groupId: _group.id,
                      newOwnerId: member.userId,
                    );
                    final updated = await _groupService.getGroupById(_group.id);
                    if (mounted) {
                      setState(() {
                        _group = updated;
                        _isOwner = _groupService.isOwnerOf(updated);
                      });
                    }
                  }
                },
              ),
            // Remove member
            ListTile(
              leading: const Icon(
                Icons.person_remove_outlined,
                color: Colors.red,
              ),
              title: const Text(
                'Remove from Group',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await _showConfirm(
                  'Remove Member',
                  'Remove ${member.displayName} from the group?',
                );
                if (confirm) {
                  await _groupService.removeMember(
                    groupId: _group.id,
                    userId: member.userId,
                  );
                  final updated = await _groupService.getGroupById(_group.id);
                  if (mounted) setState(() => _group = updated);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Exit group â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _exitGroup() async {
    final confirm = await _showConfirm(
      'Exit Group',
      _isOwner && _group.memberCount > 1
          ? 'You will exit and ownership will transfer to another member.'
          : 'Are you sure you want to exit this group?',
    );
    if (!confirm) return;

    try {
      await _groupService.exitGroup(_group.id);
      if (mounted) {
        // Pop settings + group arena back to chat list
        Navigator.of(context)
          ..pop()
          ..pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // â”€â”€ Delete group â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _deleteGroup() async {
    final confirm = await _showConfirm(
      'Delete Group',
      'This will permanently delete "${_group.name}" and all messages.',
      destructive: true,
    );
    if (!confirm) return;

    try {
      await _groupService.deleteGroup(_group.id);
      if (mounted) {
        Navigator.of(context)
          ..pop()
          ..pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<bool> _showConfirm(
    String title,
    String message, {
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: destructive
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : TextButton.styleFrom(foregroundColor: _purple),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Group Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: _purple),
        ),
        actions: [
          if (_isOwner)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: _isSaving ? null : _saveInfo,
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_purple),
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: _purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ Group identity card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Emoji icon (tappable for owner)
                  GestureDetector(
                    onTap: _pickEmoji,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: _isOwner
                            ? Border.all(
                                color: _purple.withValues(alpha: 0.3),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              _group.iconEmoji,
                              style: const TextStyle(fontSize: 34),
                            ),
                          ),
                          if (_isOwner)
                            Positioned(
                              right: 4,
                              bottom: 4,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _purple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field (editable for owner)
                        _isOwner
                            ? TextField(
                                controller: _nameController,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Group name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: _purple,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              )
                            : Text(
                                _group.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        const SizedBox(height: 6),
                        Text(
                          '${_group.memberCount} members',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                        if (_isOwner)
                          Text(
                            'You are the owner',
                            style: TextStyle(
                              color: _purple.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // â”€â”€ Members section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Members',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_group.memberCount}',
                      style: const TextStyle(
                        color: _purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_isOwner)
                    TextButton.icon(
                      onPressed: _showAddMembers,
                      icon: const Icon(
                        Icons.person_add_outlined,
                        size: 16,
                        color: _purple,
                      ),
                      label: const Text(
                        'Add',
                        style: TextStyle(
                          color: _purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _group.members.map((member) {
                  final isMe = member.userId == _currentUserId;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: _purple.withValues(alpha: 0.12),
                      backgroundImage: member.profilePictureUrl != null
                          ? NetworkImage(member.profilePictureUrl!)
                          : null,
                      child: member.profilePictureUrl == null
                          ? Text(
                              member.initials,
                              style: const TextStyle(
                                color: _purple,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            member.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                color: _purple,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      '@${member.username ?? 'user'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    trailing: member.isOwner
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _purple,
                                  _purple.withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'ðŸ‘‘ Owner',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : (_isOwner && !isMe)
                        ? IconButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: Colors.grey.shade400,
                            ),
                            onPressed: () => _showMemberOptions(member),
                          )
                        : null,
                    onLongPress: (_isOwner && !isMe)
                        ? () => _showMemberOptions(member)
                        : null,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // â”€â”€ Danger zone â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Exit group
                  OutlinedButton.icon(
                    onPressed: _exitGroup,
                    icon: const Icon(Icons.exit_to_app, color: Colors.orange),
                    label: const Text(
                      'Exit Group',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  if (_isOwner) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _deleteGroup,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Delete Group',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

