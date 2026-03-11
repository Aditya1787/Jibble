import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class CreateProfileUseCase {
  final ProfileRepository repository;

  CreateProfileUseCase(this.repository);

  Future<ProfileEntity?> call(ProfileEntity profile) {
    return repository.createProfile(profile);
  }
}
