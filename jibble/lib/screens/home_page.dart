import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import 'Chat/chat_list_page.dart';
import '../widgets/post_card_widget.dart';
import '../widgets/home_drawer.dart';
import '../widgets/custom_bottom_nav_bar.dart';

/// Main Home Page with Instagram-like UI
/// Features: Provider state management, Pagination, Cached Images
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial feed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().loadHomeFeed(refresh: true);
    });

    // Pagination listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 500) {
        context.read<FeedProvider>().loadHomeFeed();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onBottomNavTap(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        break;
      case 1: // Search
        Navigator.of(context).pushNamed('/search');
        break;
      case 2: // Upload
        await Navigator.of(context).pushNamed('/create-post');
        if (!mounted) return;
        context.read<FeedProvider>().loadHomeFeed(refresh: true);
        setState(() => _selectedIndex = 0);
        break;
      case 3: // Reels
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reels feature coming soon!')),
        );
        break;
      case 4: // Chat
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const ChatListPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF6B4CE6)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Jibble',
          style: TextStyle(
            fontFamily: 'DancingScript',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B4CE6),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Color(0xFF6B4CE6)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined, color: Color(0xFF6B4CE6)),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const HomeDrawer(),
      body: _buildPostGrid(),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onBottomNavTap,
      ),
    );
  }

  Widget _buildPostGrid() {
    return Consumer<FeedProvider>(
      builder: (context, feed, _) {
        if (feed.homePosts.isEmpty && feed.isHomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (feed.homePosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feed_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No posts yet.\nBe the first to share something!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => feed.loadHomeFeed(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: feed.homePosts.length + (feed.hasMoreHomePosts ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == feed.homePosts.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return PostCardWidget(
                post: feed.homePosts[index],
                onPostDeleted: () => feed.loadHomeFeed(refresh: true),
              );
            },
          ),
        );
      },
    );
  }
}
