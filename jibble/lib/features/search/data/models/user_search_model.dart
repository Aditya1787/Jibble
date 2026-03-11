import 'package:jibble/features/search/domain/entities/user_search_entity.dart';

/// User Search Model
///
/// Represents a user in search results with basic profile information
class UserSearchModel extends UserSearchEntity {
  const UserSearchModel({
    required super.id,
    super.email,
    super.username,
    super.profilePictureUrl,
    super.collegeName,
  });

  /// Create a UserSearchModel from JSON
  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    return UserSearchModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      username: json['username'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      collegeName: json['college_name'] as String?,
    );
  }

  /// Convert UserSearchModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'profile_picture_url': profilePictureUrl,
      'college_name': collegeName,
    };
  }
}
