import 'dart:io';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity?> getProfile(String userId);
  Future<ProfileEntity?> getProfileByUsername(String username);
  Future<List<ProfileEntity>> searchProfiles(String query);
  Future<ProfileEntity?> updateProfile(ProfileEntity profile);
  Future<ProfileEntity?> createProfile(ProfileEntity profile);
  Future<String> uploadProfilePicture(String userId, File imageFile);
  Future<void> updateProfilePicture(String userId, String imageUrl);
  Future<bool> isUsernameAvailable(String username);
}
