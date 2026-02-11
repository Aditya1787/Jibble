import 'package:flutter/material.dart';
import '../../services/follow_service.dart';
import '../../models/user_search_model.dart';
import '../Follow/user_list_item_widget.dart';

/// Followers List Page
///
/// Displays the list of users following the current user
class FollowersListPage extends StatefulWidget {
  final String userId;
  final bool isOwnProfile;

  const FollowersListPage({
    super.key,
    required this.userId,
    this.isOwnProfile = false,
  });

  @override
  State<FollowersListPage> createState() => _FollowersListPageState();
}

class _FollowersListPageState extends State<FollowersListPage> {
  final _followService = FollowService();
  List<UserSearchModel> _followers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFollowers();
  }

  Future<void> _loadFollowers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final followers = await _followService.getFollowers(widget.userId);
      setState(() {
        _followers = followers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Followers',
          style: TextStyle(
            color: Color(0xFF6B4CE6),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF6B4CE6)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B4CE6)),
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading followers',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFollowers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _followers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No followers yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadFollowers,
              child: ListView.builder(
                itemCount: _followers.length,
                itemBuilder: (context, index) {
                  return UserListItemWidget(
                    user: _followers[index],
                    showFollowButton: !widget.isOwnProfile,
                    showRemoveButton: widget.isOwnProfile,
                    onRemoved: _loadFollowers,
                  );
                },
              ),
            ),
    );
  }
}
