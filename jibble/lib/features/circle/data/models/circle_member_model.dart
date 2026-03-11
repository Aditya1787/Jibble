import 'package:jibble/features/circle/domain/entities/circle_member_entity.dart';

/// Circle Member Model
///
/// A lightweight model representing a member inside a college Circle.
/// Data is sourced directly from the `profiles` table using `college_name`.
class CircleMemberModel extends CircleMemberEntity {
  const CircleMemberModel({
    required super.id,
    required super.username,
    super.name,
    super.profilePictureUrl,
    super.collegeName,
    super.bio,
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
}
