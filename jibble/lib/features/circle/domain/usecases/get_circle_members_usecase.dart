import 'package:jibble/features/circle/domain/repositories/circle_repository.dart';
import 'package:jibble/features/circle/domain/entities/circle_member_entity.dart';

class GetCircleMembersUseCase {
  final CircleRepository repository;

  GetCircleMembersUseCase(this.repository);

  Future<List<CircleMemberEntity>> call({
    required String collegeName,
    String? excludeUserId,
  }) {
    return repository.getCircleMembers(
      collegeName: collegeName,
      excludeUserId: excludeUserId,
    );
  }
}
