import 'package:flutter/material.dart';
import '../../models/user_search_model.dart';
import '../../services/follow_service.dart';
import '../../services/auth_service.dart';
import '../Profile/user_profile_page.dart';
import 'follow_button_widget.dart';

/// User List Item Widget
///
/// Displays a user in a list with profile picture, username, and follow button
class UserListItemWidget extends StatefulWidget {
  final UserSearchModel user;
  final bool showFollowButton;
  final bool showRemoveButton;
  final VoidCallback? onFollowChanged;
  final VoidCallback? onRemoved;

  const UserListItemWidget({
    super.key,
    required this.user,
    this.showFollowButton = true,
    this.showRemoveButton = false,
    this.onFollowChanged,
    this.onRemoved,
  });

  @override
  State<UserListItemWidget> createState() => _UserListItemWidgetState();
}

class _UserListItemWidgetState extends State<UserListItemWidget> {
  final _followService = FollowService();
  final _authService = AuthService();
  bool _isFollowing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    if (!widget.showFollowButton) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final isFollowing = await _followService.isFollowing(widget.user.id);
      setState(() {
        _isFollowing = isFollowing;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFollower() async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Follower'),
        content: Text('Remove ${widget.user.displayName} from your followers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (shouldRemove == true) {
      try {
        await _followService.removeFollower(widget.user.id);
        widget.onRemoved?.call();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Follower removed')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove follower: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUser?.id;
    final isOwnProfile = currentUserId == widget.user.id;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserProfilePage(userId: widget.user.id),
            ),
          );
        },
        child: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF6B4CE6),
          backgroundImage: widget.user.profilePictureUrl != null
              ? NetworkImage(widget.user.profilePictureUrl!)
              : null,
          child: widget.user.profilePictureUrl == null
              ? const Icon(Icons.person, color: Colors.white, size: 28)
              : null,
        ),
      ),
      title: Text(
        widget.user.displayName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: widget.user.collegeName != null
          ? Text(
              widget.user.collegeName!,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            )
          : null,
      trailing: isOwnProfile
          ? null
          : widget.showRemoveButton
          ? TextButton(
              onPressed: _removeFollower,
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            )
          : widget.showFollowButton
          ? _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : FollowButtonWidget(
                    userId: widget.user.id,
                    initialIsFollowing: _isFollowing,
                    onFollowChanged: () {
                      setState(() {
                        _isFollowing = !_isFollowing;
                      });
                      widget.onFollowChanged?.call();
                    },
                  )
          : null,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserProfilePage(userId: widget.user.id),
          ),
        );
      },
    );
  }
}
