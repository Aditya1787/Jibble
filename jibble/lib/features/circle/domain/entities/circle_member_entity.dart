abstract class CircleMemberEntity {
  final String id;
  final String username;
  final String? name;
  final String? profilePictureUrl;
  final String? collegeName;
  final String? bio;

  const CircleMemberEntity({
    required this.id,
    required this.username,
    this.name,
    this.profilePictureUrl,
    this.collegeName,
    this.bio,
  });

  /// Display name priority: name → username
  String get displayName =>
      (name != null && name!.isNotEmpty) ? name! : username;

  /// Avatar initials fallback
  String get initials =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
}
