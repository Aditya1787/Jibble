import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jibble/features/auth/data/datasources/auth_service.dart';
import 'package:jibble/features/search/data/datasources/user_search_service.dart';
import 'package:jibble/features/follow/data/datasources/follow_service.dart';
import 'package:jibble/features/profile/data/models/profile_model.dart';
import 'package:jibble/features/follow/presentation/widgets/follow_button_widget.dart';
import 'package:jibble/features/profile/presentation/screens/followers_list_page.dart';
import 'package:jibble/features/profile/presentation/screens/following_list_page.dart';
import 'package:jibble/features/chat/presentation/screens/chat_arena_page.dart';

/// User Profile Page
///
/// Displays another user's profile with follow/unfollow and message functionality
class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _authService = AuthService();
  final _userSearchService = UserSearchService();
  final _followService = FollowService();

  static const _primaryColor = Color(0xFF3B6FE8);

  ProfileModel? _profile;
  bool _isLoading = true;
  bool _isFollowing = false;
  int _followerCount = 0;
  int _followingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final profile = await _userSearchService.getUserProfile(widget.userId);
      final isFollowing = await _followService.isFollowing(widget.userId);
      final followerCount = await _followService.getFollowerCount(
        widget.userId,
      );
      final followingCount = await _followService.getFollowingCount(
        widget.userId,
      );

      if (mounted) {
        setState(() {
          _profile = profile;
          _isFollowing = isFollowing;
          _followerCount = followerCount;
          _followingCount = followingCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshCounts() async {
    try {
      final followerCount = await _followService.getFollowerCount(
        widget.userId,
      );
      final followingCount = await _followService.getFollowingCount(
        widget.userId,
      );
      final isFollowing = await _followService.isFollowing(widget.userId);
      if (mounted) {
        setState(() {
          _followerCount = followerCount;
          _followingCount = followingCount;
          _isFollowing = isFollowing;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUser?.id;
    final isOwnProfile = currentUserId == widget.userId;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text(
          _profile?.username != null ? '@${_profile!.username}' : 'Profile',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProfile,
              color: _primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(isOwnProfile),
                    if (_profile?.bio != null && _profile!.bio!.isNotEmpty)
                      _buildBioCard(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildHeader(bool isOwnProfile) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _primaryColor.withValues(alpha: 0.15),
                  _primaryColor.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: _primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _profile?.profilePictureUrl != null
                  ? CachedNetworkImage(
                      imageUrl: _profile!.profilePictureUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: 300,
                      memCacheHeight: 300,
                      errorWidget: (context, url, error) =>
                          Icon(Icons.person, size: 50, color: _primaryColor),
                    )
                  : Icon(Icons.person, size: 50, color: _primaryColor),
            ),
          ),
          const SizedBox(height: 14),

          // Display name
          if (_profile?.name != null && _profile!.name!.isNotEmpty)
            Text(
              _profile!.name!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

          // Username
          if (_profile?.username != null) ...[
            const SizedBox(height: 4),
            Text(
              '@${_profile!.username}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          // College
          if (_profile?.collegeName != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  _profile!.collegeName!,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Stats
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem(
                  'Followers',
                  _followerCount,
                  () => Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => FollowersListPage(
                            userId: widget.userId,
                            isOwnProfile: isOwnProfile,
                          ),
                        ),
                      )
                      .then((_) => _refreshCounts()),
                ),
                VerticalDivider(
                  color: Colors.grey.shade300,
                  width: 40,
                  thickness: 1,
                ),
                _buildStatItem(
                  'Following',
                  _followingCount,
                  () => Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) =>
                              FollowingListPage(userId: widget.userId),
                        ),
                      )
                      .then((_) => _refreshCounts()),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // â”€â”€ Follow + Message buttons (only for other users) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (!isOwnProfile)
            Row(
              children: [
                // Follow / Unfollow
                Expanded(
                  child: FollowButtonWidget(
                    userId: widget.userId,
                    initialIsFollowing: _isFollowing,
                    onFollowChanged: _refreshCounts,
                  ),
                ),
                const SizedBox(width: 12),
                // Message
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatArenaPage(
                            conversationId: '',
                            otherUserId: widget.userId,
                            otherUserName: _profile?.username,
                            otherUserProfilePic: _profile?.profilePictureUrl,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text(
                      'Message',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryColor,
                      side: BorderSide(
                        color: _primaryColor.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // â”€â”€ Bio card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildBioCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notes_rounded, color: _primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _profile!.bio!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Stat item â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildStatItem(String label, int value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

