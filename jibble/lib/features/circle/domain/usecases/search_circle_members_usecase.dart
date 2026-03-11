import 'package:jibble/features/circle/domain/repositories/circle_repository.dart';
import 'package:jibble/features/circle/domain/entities/circle_member_entity.dart';

class SearchCircleMembersUseCase {
  final CircleRepository repository;

  SearchCircleMembersUseCase(this.repository);

  Future<List<CircleMemberEntity>> call({
    required String collegeName,
    required String query,
  }) {
    return repository.searchCircleMembers(
      collegeName: collegeName,
      query: query,
    );
  }
}
