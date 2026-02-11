import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_search_model.dart';
import '../models/profile_model.dart';

/// User Search Service
///
/// Handles user search functionality and user profile retrieval
class UserSearchService {
  final SupabaseClient _supabase = supabase;

  /// Search users by username
  Future<List<UserSearchModel>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final response = await _supabase
          .from('profiles')
          .select('id, email, username, profile_picture_url, college_name')
          .ilike('username', '%$query%')
          .limit(20);

      return (response as List)
          .map((json) => UserSearchModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  /// Get user profile by ID
  Future<ProfileModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Get user basic info by ID (for search results)
  Future<UserSearchModel?> getUserBasicInfo(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, email, username, profile_picture_url, college_name')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return UserSearchModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }
}
