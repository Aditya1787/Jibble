import '../repositories/profile_repository.dart';

class IsUsernameAvailableUseCase {
  final ProfileRepository repository;

  IsUsernameAvailableUseCase(this.repository);

  Future<bool> call(String username) {
    return repository.isUsernameAvailable(username);
  }
}
