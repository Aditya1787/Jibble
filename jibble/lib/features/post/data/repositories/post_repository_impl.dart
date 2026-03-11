import 'dart:io';
import 'package:jibble/features/post/domain/entities/post_entity.dart';
import 'package:jibble/features/post/domain/repositories/post_repository.dart';
import 'package:jibble/features/post/data/datasources/post_service.dart';

class PostRepositoryImpl implements PostRepository {
  final PostService remoteDataSource;

  PostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> toggleLike(String postId, bool isCurrentlyLiked) async {
    await remoteDataSource.toggleLike(postId, isCurrentlyLiked);
  }

  @override
  Future<void> createPost({
    required String type,
    String? caption,
    File? imageFile,
    bool isAnonymous = false,
  }) async {
    await remoteDataSource.createPost(
      type: type,
      caption: caption,
      imageFile: imageFile,
      isAnonymous: isAnonymous,
    );
  }

  @override
  Future<void> deletePost(String postId) async {
    await remoteDataSource.deletePost(postId);
  }

  @override
  Future<List<PostEntity>> getUserPosts(String userId) async {
    return await remoteDataSource.fetchUserPosts(userId);
  }

  @override
  Future<List<PostEntity>> fetchCircleFeed(String postType) async {
    return await remoteDataSource.fetchCircleFeed(postType);
  }
}
