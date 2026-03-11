import 'package:flutter/material.dart';
import 'package:jibble/features/post/domain/entities/post_entity.dart';
import 'package:jibble/features/home/domain/usecases/get_home_feed_usecase.dart';
import 'package:jibble/features/post/domain/usecases/toggle_like_usecase.dart';
import 'package:jibble/core/di/injection_container.dart';

class FeedProvider extends ChangeNotifier {
  late final GetHomeFeedUseCase _getHomeFeedUseCase;
  late final ToggleLikeUseCase _toggleLikeUseCase;

  final List<PostEntity> _homePosts = [];
  bool _isHomeLoading = false;
  bool _hasMoreHomePosts = true;
  int _homePage = 0;
  final int _limit = 15;

  FeedProvider() {
    _getHomeFeedUseCase = sl<GetHomeFeedUseCase>();
    _toggleLikeUseCase = sl<ToggleLikeUseCase>();
  }

  List<PostEntity> get homePosts => _homePosts;
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
      final newPosts = await _getHomeFeedUseCase(
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

      await _toggleLikeUseCase(postId, isCurrentlyLiked);
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
