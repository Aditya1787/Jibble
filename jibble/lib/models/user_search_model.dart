/// User Search Model
///
/// Represents a user in search results with basic profile information
class UserSearchModel {
  final String id;
  final String? email;
  final String? username;
  final String? profilePictureUrl;
  final String? collegeName;

  UserSearchModel({
    required this.id,
    this.email,
    this.username,
    this.profilePictureUrl,
    this.collegeName,
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

  /// Get display name (username or email or id)
  String get displayName =>
      username ?? (email != null ? email!.split('@')[0] : 'User');
}
