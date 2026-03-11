import 'package:jibble/features/chat/domain/repositories/group_repository.dart';

class TransferGroupOwnershipUseCase {
  final GroupRepository repository;

  TransferGroupOwnershipUseCase(this.repository);

  Future<void> call({required String groupId, required String newOwnerId}) {
    return repository.transferOwnership(
      groupId: groupId,
      newOwnerId: newOwnerId,
    );
  }
}
