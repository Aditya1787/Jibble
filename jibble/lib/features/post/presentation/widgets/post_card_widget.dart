import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jibble/features/post/data/models/post_model.dart';
import 'package:jibble/features/follow/data/datasources/follow_service.dart';
import 'package:jibble/features/post/data/datasources/post_service.dart';
import 'package:jibble/features/auth/data/datasources/auth_service.dart';
import 'package:jibble/features/home/presentation/provider/feed_provider.dart';

class PostCardWidget extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onPostDeleted;
  final VoidCallback? onPostUpdated;

  const PostCardWidget({
    super.key,
    required this.post,
    this.onPostDeleted,
    this.onPostUpdated,
  });

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  final _followService = FollowService();
  final _postService = PostService();
  final _authService = AuthService();

  bool _isFollowing = false;
  bool _isLoadingFollow = false;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    if (widget.post.userId == null) return; // Anonymous post
    if (widget.post.userId == _authService.currentUser?.id) return; // Own post

    setState(() => _isLoadingFollow = true);
    try {
      final isFollowing = await _followService.isFollowing(widget.post.userId!);
      if (mounted) {
        setState(() => _isFollowing = isFollowing);
      }
    } catch (e) {
      // Ignore
    } finally {
      if (mounted) {
        setState(() => _isLoadingFollow = false);
      }
    }
  }

  Future<void> _toggleFollow() async {
    if (widget.post.userId == null) return;

    setState(() {
      _isLoadingFollow = true;
    });

    try {
      if (_isFollowing) {
        await _followService.unfollowUser(widget.post.userId!);
      } else {
        await _followService.followUser(widget.post.userId!);
      }
      setState(() {
        _isFollowing = !_isFollowing;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update follow status: \$e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFollow = false;
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    await context.read<FeedProvider>().toggleLike(
      widget.post.id,
      widget.post.isLikedByMe,
    );
  }

  void _showOptions() {
    final isOwnPost = widget.post.userId == _authService.currentUser?.id;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOwnPost) ...[
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete Post',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _postService.deletePost(widget.post.id);
                    widget.onPostDeleted?.call();
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.visibility_off),
                  title: const Text('Hide Post'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post hidden (mock)')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text('Report'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post reported')),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwnPost = widget.post.userId == _authService.currentUser?.id;
    final isAnonymous = widget.post.type == 'confession';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  widget.post.profilePictureUrl != null && !isAnonymous
                  ? CachedNetworkImageProvider(
                      widget.post.profilePictureUrl!,
                      maxHeight: 156,
                      maxWidth: 156,
                    )
                  : null,
              child: widget.post.profilePictureUrl == null || isAnonymous
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Row(
              children: [
                Text(
                  widget.post.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (widget.post.type == 'event') ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Event',
                      style: TextStyle(fontSize: 10, color: Colors.blue),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              '${widget.post.formattedTime} â€¢ ${widget.post.collegeName ?? ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isOwnPost && !isAnonymous)
                  _isLoadingFollow
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton(
                          onPressed: _toggleFollow,
                          child: Text(
                            _isFollowing ? 'Unfollow' : 'Follow',
                            style: TextStyle(
                              color: _isFollowing ? Colors.grey : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: _showOptions,
                ),
              ],
            ),
          ),

          // Caption
          if (widget.post.caption != null && widget.post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Text(widget.post.caption!),
            ),

          // Image
          if (widget.post.imageUrl != null)
            CachedNetworkImage(
              imageUrl: widget.post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              memCacheWidth: 1080,
              placeholder: (context, url) => Container(
                height: 200,
                color: Colors.grey[100],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.error)),
              ),
            ),

          // Footer Actions
          Row(
            children: [
              IconButton(
                icon: Icon(
                  widget.post.isLikedByMe
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.post.isLikedByMe ? Colors.red : Colors.black,
                ),
                onPressed: _toggleLike,
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {
                  // Navigate to comments page soon
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comments page coming soon!')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  // Share
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share clicked')),
                  );
                },
              ),
            ],
          ),

          // Counts and Recent Liker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.post.likesCount > 0)
                  Text(
                    '${widget.post.likesCount} ${widget.post.likesCount == 1 ? 'like' : 'likes'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                if (widget.post.recentLikerUsername != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Liked by ${widget.post.recentLikerUsername}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                if (widget.post.commentsCount > 0)
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'View all ${widget.post.commentsCount} comments',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

