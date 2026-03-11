import 'package:jibble/features/search/domain/repositories/user_search_repository.dart';
import 'package:jibble/features/search/domain/entities/user_search_entity.dart';
import 'package:jibble/features/profile/domain/entities/profile_entity.dart';
import 'package:jibble/features/search/data/datasources/user_search_service.dart';

class UserSearchRepositoryImpl implements UserSearchRepository {
  final UserSearchService remoteDataSource;

  UserSearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<UserSearchEntity>> searchUsers(String query) async {
    return await remoteDataSource.searchUsers(query);
  }

  @override
  Future<ProfileEntity?> getUserProfile(String userId) async {
    return await remoteDataSource.getUserProfile(userId);
  }

  @override
  Future<UserSearchEntity?> getUserBasicInfo(String userId) async {
    return await remoteDataSource.getUserBasicInfo(userId);
  }
}
