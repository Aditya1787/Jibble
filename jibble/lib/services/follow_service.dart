import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_search_model.dart';

/// Follow Service
///
/// Handles all follow/unfollow operations and follower/following queries
class FollowService {
  final SupabaseClient _supabase = supabase;

  /// Follow a user
  Future<void> followUser(String followingId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (userId == followingId) {
        throw Exception('Cannot follow yourself');
      }

      await _supabase.from('follows').insert({
        'follower_id': userId,
        'following_id': followingId,
      });
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  /// Unfollow a user
  Future<void> unfollowUser(String followingId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('follows')
          .delete()
          .eq('follower_id', userId)
          .eq('following_id', followingId);
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  /// Check if current user is following another user
  Future<bool> isFollowing(String userId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        return false;
      }

      final response = await _supabase
          .from('follows')
          .select()
          .eq('follower_id', currentUserId)
          .eq('following_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check follow status: $e');
    }
  }

  /// Get follower count for a user
  Future<int> getFollowerCount(String userId) async {
    try {
      final response = await _supabase
          .from('follows')
          .select()
          .eq('following_id', userId)
          .count();

      return response.count;
    } catch (e) {
      throw Exception('Failed to get follower count: $e');
    }
  }

  /// Get following count for a user
  Future<int> getFollowingCount(String userId) async {
    try {
      final response = await _supabase
          .from('follows')
          .select()
          .eq('follower_id', userId)
          .count();

      return response.count;
    } catch (e) {
      throw Exception('Failed to get following count: $e');
    }
  }

  /// Get list of followers for a user
  Future<List<UserSearchModel>> getFollowers(String userId) async {
    try {
      // First, get all follower IDs
      final followsResponse = await _supabase
          .from('follows')
          .select('follower_id')
          .eq('following_id', userId);

      if (followsResponse.isEmpty) {
        return [];
      }

      // Extract follower IDs
      final followerIds = (followsResponse as List)
          .map((item) => item['follower_id'] as String)
          .toList();

      // Then, get profiles for those IDs
      final profilesResponse = await _supabase
          .from('profiles')
          .select('id, email, username, profile_picture_url, college_name')
          .inFilter('id', followerIds);

      // Convert to UserSearchModel
      return (profilesResponse as List)
          .map((json) => UserSearchModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get followers: $e');
    }
  }

  /// Get list of users that a user is following
  Future<List<UserSearchModel>> getFollowing(String userId) async {
    try {
      // First, get all following IDs
      final followsResponse = await _supabase
          .from('follows')
          .select('following_id')
          .eq('follower_id', userId);

      if (followsResponse.isEmpty) {
        return [];
      }

      // Extract following IDs
      final followingIds = (followsResponse as List)
          .map((item) => item['following_id'] as String)
          .toList();

      // Then, get profiles for those IDs
      final profilesResponse = await _supabase
          .from('profiles')
          .select('id, email, username, profile_picture_url, college_name')
          .inFilter('id', followingIds);

      // Convert to UserSearchModel
      return (profilesResponse as List)
          .map((json) => UserSearchModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get following: $e');
    }
  }

  /// Remove a follower
  Future<void> removeFollower(String followerId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('follows')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', userId);
    } catch (e) {
      throw Exception('Failed to remove follower: $e');
    }
  }
}
