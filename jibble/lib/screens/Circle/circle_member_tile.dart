import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/circle_member_model.dart';
import '../../screens/Profile/user_profile_page.dart';
import '../../screens/Profile/fullscreen_photo_page.dart';

/// A single member tile inside the Circle members list.
/// Tapping the avatar opens a fullscreen photo; tapping the tile opens the profile.
class CircleMemberTile extends StatelessWidget {
  final CircleMemberModel member;
  final bool isCurrentUser;

  const CircleMemberTile({
    super.key,
    required this.member,
    this.isCurrentUser = false,
  });

  static const _purple = Color(0xFF6B4CE6);

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UserProfilePage(userId: member.id)),
    );
  }

  void _openPhoto(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenPhotoPage(
          imageUrl: member.profilePictureUrl,
          heroTag: 'circle_avatar_${member.id}',
          displayName: member.displayName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openProfile(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: () => _openPhoto(context),
              child: Hero(
                tag: 'circle_avatar_${member.id}',
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _purple.withValues(alpha: 0.18),
                        _purple.withValues(alpha: 0.06),
                      ],
                    ),
                    border: Border.all(
                      color: _purple.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: member.profilePictureUrl != null
                        ? CachedNetworkImage(
                            imageUrl: member.profilePictureUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                _buildInitialAvatar(),
                          )
                        : _buildInitialAvatar(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + bio
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.displayName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _purple.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(
                              fontSize: 11,
                              color: _purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${member.username}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  if (member.bio != null && member.bio!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      member.bio!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade300,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialAvatar() {
    return Container(
      color: _purple.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Text(
        member.initials,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _purple,
        ),
      ),
    );
  }
}
