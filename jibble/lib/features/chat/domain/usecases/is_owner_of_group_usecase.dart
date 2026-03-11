import 'package:jibble/features/chat/domain/entities/group_entity.dart';

class IsOwnerOfGroupUseCase {
  bool call(GroupEntity group, String currentUserId) {
    return group.members.any((m) => m.userId == currentUserId && m.isOwner);
  }
}
