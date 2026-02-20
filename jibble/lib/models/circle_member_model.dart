/// Circle Member Model
///
/// A lightweight model representing a member inside a college Circle.
/// Data is sourced directly from the `profiles` table using `college_name`.
class CircleMemberModel {
  final String id;
  final String username;
  final String? name;
  final String? profilePictureUrl;
  final String? collegeName;
  final String? bio;

  const CircleMemberModel({
    required this.id,
    required this.username,
    this.name,
    this.profilePictureUrl,
    this.collegeName,
    this.bio,
  });

  factory CircleMemberModel.fromJson(Map<String, dynamic> json) {
    return CircleMemberModel(
      id: json['id'] as String,
      username: (json['username'] as String?) ?? 'user',
      name: json['name'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      collegeName: json['college_name'] as String?,
      bio: json['bio'] as String?,
    );
  }

  /// Display name priority: name → username
  String get displayName =>
      (name != null && name!.isNotEmpty) ? name! : username;

  /// Avatar initials fallback
  String get initials =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
}
