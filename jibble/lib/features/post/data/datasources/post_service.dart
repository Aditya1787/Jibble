import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jibble/core/config/supabase_config.dart';
import 'package:jibble/features/post/data/models/post_model.dart';

class PostService {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  /// Constants
  static const String postsTable = 'posts';
  static const String likesTable = 'post_likes';
  static const String commentsTable = 'post_comments';
  static const String storageBucket = 'post_images';
  static const int maxFileSize = 5 * 1024 * 1024; // 5 MB

  /// Fetch public 'standard' posts for the home feed
  Future<List<PostModel>> fetchHomeFeed() async {
    final currentUser = supabase.auth.currentUser;
    final response = await supabase
        .from(postsTable)
        .select('''
          *,
          profiles:user_id(username, name, profile_picture_url),
          post_likes(user_id, profiles:user_id(username)),
          post_comments(id)
        ''')
        .eq('type', 'standard')
        .order('created_at', ascending: false)
        .limit(50);

    return (response as List<dynamic>)
        .map((post) => PostModel.fromJson(post, currentUserId: currentUser?.id))
        .toList();
  }

  /// Fetch public 'standard' posts using Pagination
  Future<List<PostModel>> fetchHomeFeedPaginated({
    required int page,
    required int limit,
  }) async {
    final currentUser = supabase.auth.currentUser;
    final start = page * limit;
    final end = start + limit - 1;

    final response = await supabase
        .from(postsTable)
        .select('''
          *,
          profiles:user_id(username, name, profile_picture_url),
          post_likes(user_id, profiles:user_id(username)),
          post_comments(id)
        ''')
        .eq('type', 'standard')
        .order('created_at', ascending: false)
        .range(start, end);

    return (response as List<dynamic>)
        .map((post) => PostModel.fromJson(post, currentUserId: currentUser?.id))
        .toList();
  }

  /// Fetch 'event' and 'confession' posts for the user's circle
  Future<List<PostModel>> fetchCircleFeed(String type) async {
    final currentUser = supabase.auth.currentUser;
    final response = await supabase
        .from(postsTable)
        .select('''
          *,
          profiles:user_id(username, name, profile_picture_url),
          post_likes(user_id, profiles:user_id(username)),
          post_comments(id)
        ''')
        .eq('type', type)
        .order('created_at', ascending: false)
        .limit(50);

    return (response as List<dynamic>)
        .map((post) => PostModel.fromJson(post, currentUserId: currentUser?.id))
        .toList();
  }

  /// Fetch a user's own posts for their profile
  Future<List<PostModel>> fetchUserPosts(String userId) async {
    final currentUser = supabase.auth.currentUser;
    final response = await supabase
        .from(postsTable)
        .select('''
          *,
          profiles:user_id(username, name, profile_picture_url),
          post_likes(user_id, profiles:user_id(username)),
          post_comments(id)
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((post) => PostModel.fromJson(post, currentUserId: currentUser?.id))
        .toList();
  }

  /// Upload image to Supabase Storage
  Future<String> uploadPostImage(File imageFile) async {
    try {
      if (imageFile.lengthSync() > maxFileSize) {
        throw Exception('Image size must be less than 5MB');
      }

      // Compress image
      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithFile(
            imageFile.absolute.path,
            minWidth: 1080,
            minHeight: 1080,
            quality: 75,
          );

      if (compressedBytes == null) throw Exception('Failed to compress image');

      final ext = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final currentUserId = supabase.auth.currentUser!.id;
      final filePath = '$currentUserId/$fileName';

      await supabase.storage
          .from(storageBucket)
          .uploadBinary(
            filePath,
            compressedBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      return supabase.storage.from(storageBucket).getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Create a new post
  Future<void> createPost({
    required String type,
    String? caption,
    File? imageFile,
    bool isAnonymous = false,
  }) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadPostImage(imageFile);
      }

      final currentUser = supabase.auth.currentUser!;

      // Get user's college for circle linking if it's not a standard post
      String? collegeName;
      if (type != 'standard') {
        final profileResponse = await supabase
            .from('profiles')
            .select('college_name')
            .eq('id', currentUser.id)
            .single();
        collegeName = profileResponse['college_name'] as String?;
      }

      await supabase.from(postsTable).insert({
        'user_id': isAnonymous ? null : currentUser.id,
        'type': type,
        'caption': caption,
        'image_url': imageUrl,
        'college_name': collegeName,
      });
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await supabase.from(postsTable).delete().eq('id', postId);
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  /// Toggle Like
  Future<void> toggleLike(String postId, bool isCurrentlyLiked) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      if (isCurrentlyLiked) {
        await supabase
            .from(likesTable)
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
      } else {
        await supabase.from(likesTable).insert({
          'post_id': postId,
          'user_id': userId,
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  /// Fetch comments for a post
  Future<List<CommentModel>> fetchComments(String postId) async {
    try {
      final response = await supabase
          .from(commentsTable)
          .select('*, profiles:user_id(username, name, profile_picture_url)')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      return (response as List<dynamic>)
          .map((c) => CommentModel.fromJson(c))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }

  /// Add a comment
  Future<void> addComment(String postId, String content) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from(commentsTable).insert({
        'post_id': postId,
        'user_id': userId,
        'content': content,
      });
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }
}

