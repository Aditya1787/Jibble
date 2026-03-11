import 'dart:io';
import 'package:jibble/features/post/domain/entities/post_entity.dart';

abstract class PostRepository {
  Future<void> toggleLike(String postId, bool isCurrentlyLiked);
  Future<void> createPost({
    required String type,
    String? caption,
    File? imageFile,
    bool isAnonymous = false,
  });
  Future<void> deletePost(String postId);
  Future<List<PostEntity>> getUserPosts(String userId);
  Future<List<PostEntity>> fetchCircleFeed(String postType);
}
