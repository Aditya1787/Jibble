import '../../domain/entities/profile_entity.dart';

/// User Profile Model
///
/// Represents a user's profile information stored in Supabase
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    super.email,
    required super.username,
    super.name,
    super.bio,
    super.dateOfBirth,
    super.collegeName,
    super.profilePictureUrl,
    required super.profileCompleted,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create ProfileModel from JSON
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      username: json['username'] as String,
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      collegeName: json['college_name'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      profileCompleted: json['profile_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert ProfileModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'bio': bio,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'college_name': collegeName,
      'profile_picture_url': profilePictureUrl,
      'profile_completed': profileCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  ProfileModel copyWith({
    String? id,
    String? email,
    String? username,
    String? name,
    String? bio,
    DateTime? dateOfBirth,
    String? collegeName,
    String? profilePictureUrl,
    bool? profileCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      collegeName: collegeName ?? this.collegeName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
