import 'package:jibble/features/chat/domain/repositories/group_repository.dart';

class SendGroupMessageUseCase {
  final GroupRepository repository;

  SendGroupMessageUseCase(this.repository);

  Future<void> call(String groupId, String content) {
    return repository.sendGroupMessage(groupId, content);
  }
}
