import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/profile_model.dart';

/// Profile Service
///
/// Handles all profile-related operations including CRUD operations
/// and profile picture uploads to Supabase Storage
class ProfileService {
  // Singleton pattern
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  /// Get the current user's profile
  ///
  /// Returns null if profile doesn't exist
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return ProfileModel.fromJson(response);
    } catch (e) {
      throw 'Failed to fetch profile: $e';
    }
  }

  /// Create a new profile
  Future<ProfileModel> createProfile({
    required String userId,
    required String username,
    DateTime? dateOfBirth,
    String? collegeName,
    String? profilePictureUrl,
    bool profileCompleted = false,
  }) async {
    try {
      final now = DateTime.now();
      final profileData = {
        'id': userId,
        'username': username,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'college_name': collegeName,
        'profile_picture_url': profilePictureUrl,
        'profile_completed': profileCompleted,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await supabase
          .from('profiles')
          .upsert(profileData)
          .select()
          .single();

      return ProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Unique constraint violation
        throw 'Username already taken';
      }
      throw 'Failed to create profile: ${e.message}';
    } catch (e) {
      throw 'Failed to create profile: $e';
    }
  }

  /// Update an existing profile
  Future<ProfileModel> updateProfile({
    required String userId,
    String? username,
    DateTime? dateOfBirth,
    String? collegeName,
    String? profilePictureUrl,
    bool? profileCompleted,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) updateData['username'] = username;
      if (dateOfBirth != null) {
        updateData['date_of_birth'] = dateOfBirth.toIso8601String();
      }
      if (collegeName != null) updateData['college_name'] = collegeName;
      if (profilePictureUrl != null) {
        updateData['profile_picture_url'] = profilePictureUrl;
      }
      if (profileCompleted != null) {
        updateData['profile_completed'] = profileCompleted;
      }

      final response = await supabase
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return ProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw 'Username already taken';
      }
      throw 'Failed to update profile: ${e.message}';
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }

  /// Upload profile picture to Supabase Storage
  ///
  /// Returns the public URL of the uploaded image
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId/profile.$fileExt';

      // Upload to storage
      await supabase.storage
          .from('profile-pictures')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              upsert: true, // Replace if exists
            ),
          );

      // Get public URL
      final publicUrl = supabase.storage
          .from('profile-pictures')
          .getPublicUrl(fileName);

      return publicUrl;
    } on StorageException catch (e) {
      throw 'Failed to upload image: ${e.message}';
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  /// Delete profile picture from Supabase Storage
  Future<void> deleteProfilePicture(String userId) async {
    try {
      // List all files in user's folder
      final files = await supabase.storage
          .from('profile-pictures')
          .list(path: userId);

      // Delete all files
      for (final file in files) {
        await supabase.storage.from('profile-pictures').remove([
          '$userId/${file.name}',
        ]);
      }
    } catch (e) {
      throw 'Failed to delete profile picture: $e';
    }
  }

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await supabase
          .from('profiles')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      return response == null;
    } catch (e) {
      throw 'Failed to check username availability: $e';
    }
  }
}
