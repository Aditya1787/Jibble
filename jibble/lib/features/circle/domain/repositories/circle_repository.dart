import 'package:jibble/features/circle/domain/entities/circle_member_entity.dart';

abstract class CircleRepository {
  Future<String?> getCurrentUserCollege(String userId);
  Future<List<CircleMemberEntity>> getCircleMembers({
    required String collegeName,
    String? excludeUserId,
  });
  Future<List<CircleMemberEntity>> searchCircleMembers({
    required String collegeName,
    required String query,
  });
}
