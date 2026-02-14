import 'package:flutter/material.dart';
import '../../models/user_search_model.dart';
import '../../services/follow_service.dart';
import '../Profile/user_profile_page.dart';
import 'follow_button_widget.dart';

/// User List Item Widget
///
/// Reusable widget for displaying a user in a list
class UserListItemWidget extends StatelessWidget {
  final UserSearchModel user;
  final bool showFollowButton;
  final bool showRemoveButton;
  final VoidCallback? onRemoved;

  const UserListItemWidget({
    super.key,
    required this.user,
    this.showFollowButton = false,
    this.showRemoveButton = false,
    this.onRemoved,
  });

  Future<void> _removeFollower(BuildContext context) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Follower'),
        content: Text('Remove ${user.displayName} from your followers?'),
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

    if (shouldRemove == true && context.mounted) {
      try {
        await FollowService().removeFollower(user.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Follower removed')));
          onRemoved?.call();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xFF6B4CE6),
        backgroundImage: user.profilePictureUrl != null
            ? NetworkImage(user.profilePictureUrl!)
            : null,
        child: user.profilePictureUrl == null
            ? Text(
                user.displayName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        user.displayName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: user.collegeName != null
          ? Text(
              user.collegeName!,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            )
          : null,
      trailing: showFollowButton
          ? FollowButtonWidget(userId: user.id, initialIsFollowing: false)
          : showRemoveButton
          ? IconButton(
              icon: const Icon(Icons.person_remove, color: Colors.red),
              onPressed: () => _removeFollower(context),
            )
          : null,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserProfilePage(userId: user.id),
          ),
        );
      },
    );
  }
}
