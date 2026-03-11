import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jibble/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jibble/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:jibble/core/di/injection_container.dart';
import 'package:jibble/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:jibble/features/profile/domain/entities/profile_entity.dart';
import 'package:jibble/features/follow/domain/usecases/get_follower_count_usecase.dart';
import 'package:jibble/features/follow/domain/usecases/get_following_count_usecase.dart';
import 'package:jibble/features/post/domain/usecases/get_user_posts_usecase.dart';
import 'package:jibble/features/profile/presentation/screens/followers_list_page.dart';
import 'package:jibble/features/profile/presentation/screens/following_list_page.dart';
import 'package:jibble/features/profile/presentation/screens/settings_drawer.dart';
import 'package:jibble/features/profile/presentation/screens/edit_profile_page.dart';
import 'package:jibble/features/post/domain/entities/post_entity.dart';
import 'package:jibble/features/post/presentation/widgets/post_card_widget.dart';

/// Profile Page
///
/// Displays the current user's profile information
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final SignOutUseCase _signOutUseCase;
  late final GetProfileUseCase _getProfileUseCase;
  late final GetFollowerCountUseCase _getFollowerCountUseCase;
  late final GetFollowingCountUseCase _getFollowingCountUseCase;
  late final GetUserPostsUseCase _getUserPostsUseCase;

  static const _primaryColor = Color(0xFF3B6FE8);

  ProfileEntity? _profile;
  List<PostEntity> _userPosts = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _followerCount = 0;
  int _followingCount = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
    _signOutUseCase = sl<SignOutUseCase>();
    _getProfileUseCase = sl<GetProfileUseCase>();
    _getFollowerCountUseCase = sl<GetFollowerCountUseCase>();
    _getFollowingCountUseCase = sl<GetFollowingCountUseCase>();
    _getUserPostsUseCase = sl<GetUserPostsUseCase>();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _getCurrentUserUseCase();
      if (user != null) {
        final profile = await _getProfileUseCase(user.id);
        final followerCount = await _getFollowerCountUseCase(user.id);
        final followingCount = await _getFollowingCountUseCase(user.id);
        final posts = await _getUserPostsUseCase(user.id);

        if (mounted) {
          setState(() {
            _profile = profile;
            _userPosts = posts;
            _followerCount = followerCount;
            _followingCount = followingCount;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _signOutUseCase();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: SettingsDrawer(
        profile: _profile,
        onLogout: _handleLogout,
        onProfileUpdated: _loadProfile,
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
                    _buildHeader(),
                    if (_profile?.bio != null && _profile!.bio!.isNotEmpty)
                      _buildBioCard(),
                    if (_errorMessage != null) _buildError(),

                    const SizedBox(height: 24),
                    const Divider(height: 1, thickness: 1),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_userPosts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'No posts yet.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._userPosts.map(
                        (post) => PostCardWidget(
                          post: post,
                          onPostDeleted: _loadProfile,
                        ),
                      ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  // â”€â”€ Header section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildHeader() {
    final user = _getCurrentUserUseCase();
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
          Stack(
            children: [
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
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 50,
                            color: _primaryColor,
                          ),
                        )
                      : Icon(Icons.person, size: 50, color: _primaryColor),
                ),
              ),
            ],
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

          const SizedBox(height: 20),

          // Stats row
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem('Followers', _followerCount, () {
                  if (user != null) {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => FollowersListPage(
                              userId: user.id,
                              isOwnProfile: true,
                            ),
                          ),
                        )
                        .then((_) => _loadProfile());
                  }
                }),
                VerticalDivider(
                  color: Colors.grey.shade300,
                  width: 40,
                  thickness: 1,
                ),
                _buildStatItem('Following', _followingCount, () {
                  if (user != null) {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => FollowingListPage(userId: user.id),
                          ),
                        )
                        .then((_) => _loadProfile());
                  }
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Edit Profile button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                if (_profile == null) return;
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => EditProfilePage(profile: _profile!),
                      ),
                    )
                    .then((updated) {
                      if (updated != null) _loadProfile();
                    });
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                'Edit Profile',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: BorderSide(color: _primaryColor.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
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
          Icon(Icons.notes_rounded, color: _primaryColor, size: 20),
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

  // â”€â”€ Error â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
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
