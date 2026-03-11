import 'package:jibble/features/circle/domain/repositories/circle_repository.dart';
import 'package:jibble/features/circle/domain/entities/circle_member_entity.dart';
import 'package:jibble/features/circle/data/datasources/circle_service.dart';

class CircleRepositoryImpl implements CircleRepository {
  final CircleService remoteDataSource;

  CircleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String?> getCurrentUserCollege(String userId) async {
    return await remoteDataSource.getCurrentUserCollege(userId);
  }

  @override
  Future<List<CircleMemberEntity>> getCircleMembers({
    required String collegeName,
    String? excludeUserId,
  }) async {
    return await remoteDataSource.getCircleMembers(
      collegeName: collegeName,
      excludeUserId: excludeUserId,
    );
  }

  @override
  Future<List<CircleMemberEntity>> searchCircleMembers({
    required String collegeName,
    required String query,
  }) async {
    return await remoteDataSource.searchCircleMembers(
      collegeName: collegeName,
      query: query,
    );
  }
}
