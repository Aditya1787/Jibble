import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jibble/core/config/supabase_config.dart';
import 'package:jibble/features/circle/data/models/circle_member_model.dart';

/// Circle Service
///
/// Fetches all members whose `college_name` matches the current user's college.
/// The "Circle" for a college is auto-formed from all profiles that share
/// the same college_name â€” no extra table needed.
class CircleService {
  static final CircleService _instance = CircleService._internal();
  factory CircleService() => _instance;
  CircleService._internal();

  final SupabaseClient _supabase = supabase;

  // â”€â”€ Get the current user's college name â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<String?> getCurrentUserCollege(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('college_name')
          .eq('id', userId)
          .maybeSingle();
      return response?['college_name'] as String?;
    } catch (_) {
      return null;
    }
  }

  // â”€â”€ Get all members of a college circle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<List<CircleMemberModel>> getCircleMembers({
    required String collegeName,
    String? excludeUserId,
  }) async {
    try {
      var query = _supabase
          .from('profiles')
          .select('id, username, name, profile_picture_url, college_name, bio')
          .ilike('college_name', collegeName); // case-insensitive match

      final response = await query.order('username', ascending: true);

      final members = (response as List)
          .map((json) => CircleMemberModel.fromJson(json))
          .toList();

      // Put self at bottom (optional UX choice)
      if (excludeUserId != null) {
        members.sort((a, b) {
          if (a.id == excludeUserId) return 1;
          if (b.id == excludeUserId) return -1;
          return a.displayName.compareTo(b.displayName);
        });
      }

      return members;
    } catch (e) {
      throw 'Failed to load circle members: $e';
    }
  }

  // â”€â”€ Search within a circle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<List<CircleMemberModel>> searchCircleMembers({
    required String collegeName,
    required String query,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return getCircleMembers(collegeName: collegeName);
      }

      final response = await _supabase
          .from('profiles')
          .select('id, username, name, profile_picture_url, college_name, bio')
          .ilike('college_name', collegeName)
          .or('username.ilike.%$query%,name.ilike.%$query%')
          .order('username', ascending: true);

      return (response as List)
          .map((json) => CircleMemberModel.fromJson(json))
          .toList();
    } catch (e) {
      throw 'Failed to search circle members: $e';
    }
  }
}

