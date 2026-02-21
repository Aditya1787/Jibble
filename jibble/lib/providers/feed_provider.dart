import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class FeedProvider extends ChangeNotifier {
  final PostService _postService = PostService();

  final List<PostModel> _homePosts = [];
  bool _isHomeLoading = false;
  bool _hasMoreHomePosts = true;
  int _homePage = 0;
  final int _limit = 15;

  List<PostModel> get homePosts => _homePosts;
  bool get isHomeLoading => _isHomeLoading;
  bool get hasMoreHomePosts => _hasMoreHomePosts;

  Future<void> loadHomeFeed({bool refresh = false}) async {
    if (refresh) {
      _homePage = 0;
      _hasMoreHomePosts = true;
      _homePosts.clear();
    }

    if (_isHomeLoading || !_hasMoreHomePosts) return;

    _isHomeLoading = true;
    notifyListeners();

    try {
      final newPosts = await _postService.fetchHomeFeedPaginated(
        page: _homePage,
        limit: _limit,
      );

      if (newPosts.length < _limit) {
        _hasMoreHomePosts = false;
      }

      _homePosts.addAll(newPosts);
      _homePage++;
    } catch (e) {
      debugPrint('Error loading home feed: \$e');
    } finally {
      _isHomeLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId, bool isCurrentlyLiked) async {
    try {
      // Optimistic UI update
      final postIndex = _homePosts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final post = _homePosts[postIndex];
        _homePosts[postIndex] = post.copyWith(
          isLikedByMe: !isCurrentlyLiked,
          likesCount: isCurrentlyLiked
              ? post.likesCount - 1
              : post.likesCount + 1,
        );
        notifyListeners();
      }

      await _postService.toggleLike(postId, isCurrentlyLiked);
    } catch (e) {
      // Revert if failed
      debugPrint('Error toggling like: \$e');
      loadHomeFeed(refresh: true); // Simple way to revert
    }
  }

  void removePostLocally(String postId) {
    _homePosts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }
}
