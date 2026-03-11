import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jibble/core/config/supabase_config.dart';
import 'package:jibble/features/chat/data/models/group_model.dart';
import 'package:jibble/features/chat/data/models/group_message_model.dart';

/// Group Service
///
/// Handles all group chat operations:
///  - Create / update / delete groups
///  - Member management (add, remove, transfer ownership)
///  - Messages (send, fetch, real-time subscription)
class GroupService {
  static final GroupService _instance = GroupService._internal();
  factory GroupService() => _instance;
  GroupService._internal();

  final SupabaseClient _supabase = supabase;
  final Map<String, RealtimeChannel> _subscriptions = {};

  final StreamController<List<GroupModel>> _userGroupsController =
      StreamController<List<GroupModel>>.broadcast();

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Stream<List<GroupModel>> getUserGroupsStream() =>
      _userGroupsController.stream;

  Stream<List<GroupMessageModel>> getGroupMessagesStream(String groupId) {
    return _supabase
        .from('group_messages')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .map(
          (event) => event.map((e) => GroupMessageModel.fromJson(e)).toList(),
        );
  }

  // â”€â”€ Create group â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<GroupModel> createGroup({
    required String name,
    required String iconEmoji,
    required List<String> memberIds,
  }) async {
    final uid = _currentUserId;
    if (uid == null) throw 'Not authenticated';
    if (name.trim().isEmpty) throw 'Group name cannot be empty';

    // Call the SECURITY DEFINER RPC function â€” bypasses RLS entirely.
    // The function creates the group row AND adds the creator as owner
    // in one atomic transaction.
    final groupId =
        await _supabase.rpc(
              'create_group_chat',
              params: {'p_name': name.trim(), 'p_icon_emoji': iconEmoji},
            )
            as String;

    // Add other members (RLS allows this since we are now a member)
    for (final memberId in memberIds) {
      if (memberId != uid) {
        try {
          await _supabase.from('group_members').insert({
            'group_id': groupId,
            'user_id': memberId,
            'role': 'member',
          });
        } catch (_) {
          // Ignore duplicate member errors
        }
      }
    }

    return getGroupById(groupId);
  }

  // â”€â”€ Fetch groups â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<List<GroupModel>> getUserGroups() async => getMyGroups();

  Future<List<GroupModel>> getMyGroups() async {
    final uid = _currentUserId;
    if (uid == null) throw 'Not authenticated';

    // Find groups this user belongs to
    final memberRows = await _supabase
        .from('group_members')
        .select('group_id')
        .eq('user_id', uid);

    final groupIds = (memberRows as List)
        .map((r) => r['group_id'] as String)
        .toList();

    if (groupIds.isEmpty) return [];

    final rows = await _supabase
        .from('group_chats')
        .select('''
          id, name, icon_emoji, created_by, created_at,
          last_message, last_message_at,
          group_members(
            id, group_id, user_id, role, joined_at,
            profiles(username, name, profile_picture_url)
          )
        ''')
        .inFilter('id', groupIds)
        .order('last_message_at', ascending: false);

    return (rows as List).map((r) => GroupModel.fromJson(r)).toList();
  }

  Future<GroupModel> getGroupById(String groupId) async {
    final row = await _supabase
        .from('group_chats')
        .select('''
          id, name, icon_emoji, created_by, created_at,
          last_message, last_message_at,
          group_members(
            id, group_id, user_id, role, joined_at,
            profiles(username, name, profile_picture_url)
          )
        ''')
        .eq('id', groupId)
        .single();

    return GroupModel.fromJson(row);
  }

  // â”€â”€ Update group info â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> updateGroup({
    required String groupId,
    String? name,
    String? iconEmoji,
  }) async {
    final data = <String, dynamic>{};
    if (name != null && name.trim().isNotEmpty) {
      data['name'] = name.trim();
    }
    if (iconEmoji != null && iconEmoji.isNotEmpty) {
      data['icon_emoji'] = iconEmoji;
    }
    if (data.isEmpty) return;

    await _supabase.from('group_chats').update(data).eq('id', groupId);
  }

  // â”€â”€ Member management â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> addMembers({
    required String groupId,
    required List<String> userIds,
  }) async {
    for (final uid in userIds) {
      // Only insert if not already a member
      final existing = await _supabase
          .from('group_members')
          .select('id')
          .eq('group_id', groupId)
          .eq('user_id', uid)
          .maybeSingle();
      if (existing == null) {
        await _supabase.from('group_members').insert({
          'group_id': groupId,
          'user_id': uid,
          'role': 'member',
        });
      }
    }
  }

  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    await _supabase
        .from('group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', userId);
  }

  /// Transfer ownership to another member (demotes current owner to member)
  Future<void> transferOwnership({
    required String groupId,
    required String newOwnerId,
  }) async {
    final uid = _currentUserId;
    if (uid == null) throw 'Not authenticated';

    // Make new owner
    await _supabase
        .from('group_members')
        .update({'role': 'owner'})
        .eq('group_id', groupId)
        .eq('user_id', newOwnerId);

    // Demote old owner
    await _supabase
        .from('group_members')
        .update({'role': 'member'})
        .eq('group_id', groupId)
        .eq('user_id', uid);
  }

  /// Exit the group. If user is owner and there are other members,
  /// automatically transfers ownership to the next member.
  Future<void> exitGroup(String groupId) async {
    final uid = _currentUserId;
    if (uid == null) throw 'Not authenticated';

    final group = await getGroupById(groupId);
    final isOwner = group.members.any((m) => m.userId == uid && m.isOwner);

    // If owner and others remain, transfer first
    if (isOwner) {
      final others = group.members.where((m) => m.userId != uid).toList();
      if (others.isNotEmpty) {
        await _supabase
            .from('group_members')
            .update({'role': 'owner'})
            .eq('group_id', groupId)
            .eq('user_id', others.first.userId);
      } else {
        // Last member â€” delete the group entirely
        await deleteGroup(groupId);
        return;
      }
    }

    await removeMember(groupId: groupId, userId: uid);
  }

  /// Delete the whole group (owner only)
  Future<void> deleteGroup(String groupId) async {
    await _supabase.from('group_chats').delete().eq('id', groupId);
  }

  // â”€â”€ Messaging â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<List<GroupMessageModel>> getGroupMessages(String groupId) async =>
      getMessages(groupId);

  Future<List<GroupMessageModel>> getMessages(String groupId) async {
    final rows = await _supabase
        .from('group_messages')
        .select('''
          id, group_id, sender_id, content, created_at,
          profiles(username, profile_picture_url)
        ''')
        .eq('group_id', groupId)
        .order('created_at', ascending: true);

    return (rows as List).map((r) => GroupMessageModel.fromJson(r)).toList();
  }

  Future<GroupMessageModel> sendGroupMessage(
    String groupId,
    String content,
  ) async => sendMessage(groupId: groupId, content: content);

  Future<GroupMessageModel> sendMessage({
    required String groupId,
    required String content,
  }) async {
    final uid = _currentUserId;
    if (uid == null) throw 'Not authenticated';

    final row = await _supabase
        .from('group_messages')
        .insert({
          'group_id': groupId,
          'sender_id': uid,
          'content': content.trim(),
        })
        .select('''
          id, group_id, sender_id, content, created_at,
          profiles(username, profile_picture_url)
        ''')
        .single();

    // Update group last_message
    await _supabase
        .from('group_chats')
        .update({
          'last_message': content.trim(),
          'last_message_at': DateTime.now().toIso8601String(),
        })
        .eq('id', groupId);

    return GroupMessageModel.fromJson(row);
  }

  // â”€â”€ Real-time subscription â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void subscribeToGroupMessages(
    String groupId,
    void Function(GroupMessageModel) onMessage,
  ) {
    _subscriptions[groupId]?.unsubscribe();

    final channel = _supabase
        .channel('group_messages:$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'group_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (payload) async {
            // Fetch full row with sender profile
            try {
              final row = await _supabase
                  .from('group_messages')
                  .select('''
                    id, group_id, sender_id, content, created_at,
                    profiles(username, profile_picture_url)
                  ''')
                  .eq('id', payload.newRecord['id'] as String)
                  .single();
              onMessage(GroupMessageModel.fromJson(row));
            } catch (_) {}
          },
        )
        .subscribe();

    _subscriptions[groupId] = channel;
  }

  void unsubscribeFromGroup(String groupId) {
    _subscriptions[groupId]?.unsubscribe();
    _subscriptions.remove(groupId);
  }

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  bool isOwnerOf(GroupModel group) {
    final uid = _currentUserId;
    return group.members.any((m) => m.userId == uid && m.isOwner);
  }
}
