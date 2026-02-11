import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_search_service.dart';
import '../../services/follow_service.dart';
import '../../models/profile_model.dart';
import '../Follow/follow_button_widget.dart';
import 'followers_list_page.dart';
import 'following_list_page.dart';

/// User Profile Page
///
/// Displays another user's profile with follow/unfollow functionality
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
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _userSearchService.getUserProfile(widget.userId);
      final isFollowing = await _followService.isFollowing(widget.userId);
      final followerCount = await _followService.getFollowerCount(
        widget.userId,
      );
      final followingCount = await _followService.getFollowingCount(
        widget.userId,
      );

      setState(() {
        _profile = profile;
        _isFollowing = isFollowing;
        _followerCount = followerCount;
        _followingCount = followingCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
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

      setState(() {
        _followerCount = followerCount;
        _followingCount = followingCount;
        _isFollowing = isFollowing;
      });
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUser?.id;
    final isOwnProfile = currentUserId == widget.userId;

    // If viewing own profile, navigate to the main profile page
    if (isOwnProfile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/profile');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade600, Colors.blue.shade50],
                  stops: const [0.0, 0.3],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade600, Colors.blue.shade50],
                  stops: const [0.0, 0.3],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // User Avatar with Profile Picture
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: _profile?.profilePictureUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    _profile!.profilePictureUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.blue.shade600,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.blue.shade600,
                                ),
                        ),
                        const SizedBox(height: 24),

                        // Username
                        if (_profile?.username != null) ...[
                          Text(
                            '@${_profile!.username}',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        // User email
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _profile?.email ?? 'No email',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Follower/Following Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatItem(
                              'Followers',
                              _followerCount.toString(),
                              () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (context) => FollowersListPage(
                                          userId: widget.userId,
                                          isOwnProfile: false,
                                        ),
                                      ),
                                    )
                                    .then((_) => _refreshCounts());
                              },
                            ),
                            const SizedBox(width: 32),
                            _buildStatItem(
                              'Following',
                              _followingCount.toString(),
                              () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (context) => FollowingListPage(
                                          userId: widget.userId,
                                        ),
                                      ),
                                    )
                                    .then((_) => _refreshCounts());
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Follow Button
                        FollowButtonWidget(
                          userId: widget.userId,
                          initialIsFollowing: _isFollowing,
                          onFollowChanged: _refreshCounts,
                        ),
                        const SizedBox(height: 32),

                        // Profile info card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profile Information',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),

                                // Username
                                if (_profile?.username != null) ...[
                                  _buildInfoRow(
                                    Icons.alternate_email,
                                    'Username',
                                    _profile!.username,
                                  ),
                                  const Divider(height: 24),
                                ],

                                // Date of Birth
                                if (_profile?.dateOfBirth != null) ...[
                                  _buildInfoRow(
                                    Icons.cake_outlined,
                                    'Date of Birth',
                                    '${_formatDate(_profile!.dateOfBirth!)} (${_calculateAge(_profile!.dateOfBirth!)} years old)',
                                  ),
                                  const Divider(height: 24),
                                ],

                                // College
                                if (_profile?.collegeName != null) ...[
                                  _buildInfoRow(
                                    Icons.school_outlined,
                                    'College',
                                    _profile!.collegeName!,
                                  ),
                                  const Divider(height: 24),
                                ],

                                // Email
                                _buildInfoRow(
                                  Icons.email_outlined,
                                  'Email',
                                  _profile?.email ?? 'Not available',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade600, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
