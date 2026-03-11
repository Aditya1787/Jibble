import 'package:jibble/features/chat/domain/repositories/group_repository.dart';
import 'package:jibble/features/chat/domain/entities/group_entity.dart';
import 'package:jibble/features/chat/domain/entities/group_message_entity.dart';
import 'package:jibble/features/chat/data/datasources/group_service.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupService remoteDataSource;

  GroupRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<GroupEntity>> getUserGroups() async {
    return await remoteDataSource.getUserGroups();
  }

  @override
  Stream<List<GroupEntity>> getUserGroupsStream() {
    return remoteDataSource.getUserGroupsStream();
  }

  @override
  Future<GroupEntity> createGroup(
    String name,
    List<String> userIds, {
    String iconEmoji = '👥',
  }) async {
    return await remoteDataSource.createGroup(
      name: name,
      memberIds: userIds,
      iconEmoji: iconEmoji,
    );
  }

  @override
  Future<GroupEntity> getGroupById(String groupId) async {
    return await remoteDataSource.getGroupById(groupId);
  }

  @override
  Future<List<GroupMessageEntity>> getGroupMessages(String groupId) async {
    return await remoteDataSource.getGroupMessages(groupId);
  }

  @override
  Stream<List<GroupMessageEntity>> getGroupMessagesStream(String groupId) {
    return remoteDataSource.getGroupMessagesStream(groupId);
  }

  @override
  Future<void> sendGroupMessage(String groupId, String content) async {
    await remoteDataSource.sendGroupMessage(groupId, content);
  }

  @override
  Future<void> updateGroup({
    required String groupId,
    String? name,
    String? iconEmoji,
  }) async {
    return await remoteDataSource.updateGroup(
      groupId: groupId,
      name: name,
      iconEmoji: iconEmoji,
    );
  }

  @override
  Future<void> addMembers({
    required String groupId,
    required List<String> userIds,
  }) async {
    return await remoteDataSource.addMembers(
      groupId: groupId,
      userIds: userIds,
    );
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    return await remoteDataSource.removeMember(
      groupId: groupId,
      userId: userId,
    );
  }

  @override
  Future<void> transferOwnership({
    required String groupId,
    required String newOwnerId,
  }) async {
    return await remoteDataSource.transferOwnership(
      groupId: groupId,
      newOwnerId: newOwnerId,
    );
  }

  @override
  Future<void> exitGroup(String groupId) async {
    return await remoteDataSource.exitGroup(groupId);
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    return await remoteDataSource.deleteGroup(groupId);
  }

  @override
  void subscribeToGroupMessages(
    String groupId,
    void Function(GroupMessageEntity) onMessage,
  ) {
    remoteDataSource.subscribeToGroupMessages(
      groupId,
      (model) => onMessage(model),
    );
  }

  @override
  void unsubscribeFromGroup(String groupId) {
    remoteDataSource.unsubscribeFromGroup(groupId);
  }
}
