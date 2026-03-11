import 'dart:io';
import 'package:jibble/features/post/domain/repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  Future<void> call({
    required String type,
    String? caption,
    File? imageFile,
    bool isAnonymous = false,
  }) {
    return repository.createPost(
      type: type,
      caption: caption,
      imageFile: imageFile,
      isAnonymous: isAnonymous,
    );
  }
}
