import 'package:jibble/features/circle/domain/repositories/circle_repository.dart';

class GetCurrentUserCollegeUseCase {
  final CircleRepository repository;

  GetCurrentUserCollegeUseCase(this.repository);

  Future<String?> call(String userId) {
    return repository.getCurrentUserCollege(userId);
  }
}
