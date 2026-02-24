import 'package:flutter/material.dart';
import 'package:jibble/features/post/data/datasources/post_service.dart';
import 'package:jibble/features/post/data/models/post_model.dart';
import 'package:jibble/features/post/presentation/widgets/post_card_widget.dart';
import 'package:jibble/features/post/presentation/screens/create_post_page.dart';

class CircleFeedPage extends StatefulWidget {
  final String title;
  final String postType;

  const CircleFeedPage({
    super.key,
    required this.title,
    required this.postType,
  });

  @override
  State<CircleFeedPage> createState() => _CircleFeedPageState();
}

class _CircleFeedPageState extends State<CircleFeedPage> {
  final _postService = PostService();
  List<PostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _postService.fetchCircleFeed(widget.postType);
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No ${widget.title.toLowerCase()} yet.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  return PostCardWidget(
                    post: _posts[index],
                    onPostDeleted: _loadPosts,
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6B4CE6),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => CreatePostPage(
                    isCirclePost: true,
                    postType: widget.postType,
                  ),
                ),
              )
              .then((_) => _loadPosts());
        },
        icon: const Icon(Icons.add),
        label: Text(
          'New ${widget.title.substring(0, widget.title.length > 1 && widget.title.endsWith('s') ? widget.title.length - 1 : widget.title.length)}',
        ),
      ),
    );
  }
}

