import 'package:jibble/features/chat/domain/entities/group_entity.dart';
import 'package:jibble/features/chat/domain/entities/group_message_entity.dart';

abstract class GroupRepository {
  Future<List<GroupEntity>> getUserGroups();
  Stream<List<GroupEntity>> getUserGroupsStream();
  Future<GroupEntity> createGroup(
    String name,
    List<String> userIds, {
    String iconEmoji = '👥',
  });
  Future<GroupEntity> getGroupById(String groupId);
  Future<List<GroupMessageEntity>> getGroupMessages(String groupId);
  Stream<List<GroupMessageEntity>> getGroupMessagesStream(String groupId);
  Future<void> sendGroupMessage(String groupId, String content);
  Future<void> updateGroup({
    required String groupId,
    String? name,
    String? iconEmoji,
  });
  Future<void> addMembers({
    required String groupId,
    required List<String> userIds,
  });
  Future<void> removeMember({required String groupId, required String userId});
  Future<void> transferOwnership({
    required String groupId,
    required String newOwnerId,
  });
  Future<void> exitGroup(String groupId);
  Future<void> deleteGroup(String groupId);
  void subscribeToGroupMessages(
    String groupId,
    void Function(GroupMessageEntity) onMessage,
  );
  void unsubscribeFromGroup(String groupId);
}
