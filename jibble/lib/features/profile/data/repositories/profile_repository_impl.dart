import 'dart:io';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfileEntity?> getProfile(String userId) async {
    final model = await remoteDataSource.getProfile(userId);
    return model;
  }

  @override
  Future<ProfileEntity?> getProfileByUsername(String username) async {
    final model = await remoteDataSource.getProfileByUsername(username);
    return model;
  }

  @override
  Future<List<ProfileEntity>> searchProfiles(String query) async {
    final models = await remoteDataSource.searchProfiles(query);
    return models.cast<ProfileEntity>();
  }

  @override
  Future<ProfileEntity?> updateProfile(ProfileEntity profile) async {
    final model = await remoteDataSource.updateProfile(
      userId: profile.id,
      username: profile.username,
      name: profile.name,
      bio: profile.bio,
      dateOfBirth: profile.dateOfBirth,
      collegeName: profile.collegeName,
      profilePictureUrl: profile.profilePictureUrl,
      profileCompleted: profile.profileCompleted,
    );
    return model;
  }

  @override
  Future<ProfileEntity?> createProfile(ProfileEntity profile) async {
    final model = await remoteDataSource.createProfile(
      userId: profile.id,
      username: profile.username,
      name: profile.name,
      bio: profile.bio,
      dateOfBirth: profile.dateOfBirth,
      collegeName: profile.collegeName,
      profilePictureUrl: profile.profilePictureUrl,
      profileCompleted: profile.profileCompleted,
    );
    return model;
  }

  @override
  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    return await remoteDataSource.uploadProfilePicture(
      userId: userId,
      imageFile: imageFile,
    );
  }

  @override
  Future<void> updateProfilePicture(String userId, String imageUrl) async {
    await remoteDataSource.updateProfilePicture(userId, imageUrl);
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    return await remoteDataSource.isUsernameAvailable(username);
  }
}
