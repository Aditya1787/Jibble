import 'dart:io';
import 'package:jibble/features/profile/domain/repositories/profile_repository.dart';

class UploadProfilePictureUseCase {
  final ProfileRepository repository;

  UploadProfilePictureUseCase(this.repository);

  Future<String> call(String userId, File imageFile) {
    return repository.uploadProfilePicture(userId, imageFile);
  }
}
