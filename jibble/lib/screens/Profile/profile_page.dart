import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../services/follow_service.dart';
import '../../models/profile_model.dart';
import 'followers_list_page.dart';
import 'following_list_page.dart';
import 'settings_drawer.dart';

/// Profile Page
///
/// Displays the current user's profile information and provides logout functionality
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  final _profileService = ProfileService();
  final _followService = FollowService();

  ProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;
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
      _errorMessage = null;
    });

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final profile = await _profileService.getProfile(user.id);
        final followerCount = await _followService.getFollowerCount(user.id);
        final followingCount = await _followService.getFollowingCount(user.id);

        setState(() {
          _profile = profile;
          _followerCount = followerCount;
          _followingCount = followingCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: SettingsDrawer(
        profile: _profile,
        onLogout: () async {
          try {
            await _authService.signOut();
            // Navigate to login page after successful logout
            if (mounted) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error logging out: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
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

                        // User email - REMOVED
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
                                          userId: user!.id,
                                          isOwnProfile: true,
                                        ),
                                      ),
                                    )
                                    .then((_) => _loadProfile());
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
                                        builder: (context) =>
                                            FollowingListPage(userId: user!.id),
                                      ),
                                    )
                                    .then((_) => _loadProfile());
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),

                        // Error message
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
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
}
