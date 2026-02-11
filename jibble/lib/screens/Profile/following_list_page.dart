import 'package:flutter/material.dart';
import '../../services/follow_service.dart';
import '../../models/user_search_model.dart';
import '../Follow/user_list_item_widget.dart';

/// Following List Page
///
/// Displays the list of users that the current user is following
class FollowingListPage extends StatefulWidget {
  final String userId;

  const FollowingListPage({super.key, required this.userId});

  @override
  State<FollowingListPage> createState() => _FollowingListPageState();
}

class _FollowingListPageState extends State<FollowingListPage> {
  final _followService = FollowService();
  List<UserSearchModel> _following = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final following = await _followService.getFollowing(widget.userId);
      setState(() {
        _following = following;
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
          'Following',
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
                    'Error loading following',
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
                    onPressed: _loadFollowing,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _following.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Not following anyone yet',
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
              onRefresh: _loadFollowing,
              child: ListView.builder(
                itemCount: _following.length,
                itemBuilder: (context, index) {
                  return UserListItemWidget(
                    user: _following[index],
                    showFollowButton: true,
                    onFollowChanged: _loadFollowing,
                  );
                },
              ),
            ),
    );
  }
}
