abstract class UserSearchEntity {
  final String id;
  final String? email;
  final String? username;
  final String? profilePictureUrl;
  final String? collegeName;

  const UserSearchEntity({
    required this.id,
    this.email,
    this.username,
    this.profilePictureUrl,
    this.collegeName,
  });

  /// Get display name (username or email or id)
  String get displayName =>
      username ?? (email != null ? email!.split('@')[0] : 'User');
}
