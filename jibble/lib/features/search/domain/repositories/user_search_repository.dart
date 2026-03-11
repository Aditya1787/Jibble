import 'package:jibble/features/search/domain/entities/user_search_entity.dart';
import 'package:jibble/features/profile/domain/entities/profile_entity.dart';

abstract class UserSearchRepository {
  Future<List<UserSearchEntity>> searchUsers(String query);
  Future<ProfileEntity?> getUserProfile(String userId);
  Future<UserSearchEntity?> getUserBasicInfo(String userId);
}
