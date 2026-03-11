class ProfileEntity {
  final String id;
  final String? email;
  final String username;
  final String? name;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? collegeName;
  final String? profilePictureUrl;
  final bool profileCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileEntity({
    required this.id,
    this.email,
    required this.username,
    this.name,
    this.bio,
    this.dateOfBirth,
    this.collegeName,
    this.profilePictureUrl,
    required this.profileCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfileEntity &&
        other.id == id &&
        other.email == email &&
        other.username == username &&
        other.name == name &&
        other.bio == bio &&
        other.dateOfBirth == dateOfBirth &&
        other.collegeName == collegeName &&
        other.profilePictureUrl == profilePictureUrl &&
        other.profileCompleted == profileCompleted &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        username.hashCode ^
        name.hashCode ^
        bio.hashCode ^
        dateOfBirth.hashCode ^
        collegeName.hashCode ^
        profilePictureUrl.hashCode ^
        profileCompleted.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
