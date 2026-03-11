import 'package:flutter/material.dart';
import 'package:jibble/features/profile/domain/entities/profile_entity.dart';
import 'package:jibble/features/profile/presentation/screens/account_information_page.dart';
import 'package:jibble/features/profile/presentation/screens/edit_profile_page.dart';

class SettingsDrawer extends StatelessWidget {
  final ProfileEntity? profile;
  final VoidCallback onLogout;
  final VoidCallback? onProfileUpdated;

  const SettingsDrawer({
    super.key,
    required this.profile,
    required this.onLogout,
    this.onProfileUpdated,
  });

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).pop(); // Close drawer
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  void _showPlaceholder(BuildContext context, String title) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B6FE8), Color(0xFF6B4CE6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    backgroundImage: profile?.profilePictureUrl != null
                        ? NetworkImage(profile!.profilePictureUrl!)
                        : null,
                    child: profile?.profilePictureUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 34,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const Spacer(),
                  // Display name
                  if (profile?.name != null && profile!.name!.isNotEmpty)
                    Text(
                      profile!.name!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  // Username
                  if (profile?.username != null)
                    Text(
                      '@${profile!.username}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // â”€â”€ Menu Items â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: Color(0xFF3B6FE8)),
            title: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              if (profile == null) return;
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => EditProfilePage(profile: profile!),
                    ),
                  )
                  .then((updated) {
                    if (updated != null) {
                      onProfileUpdated?.call();
                    }
                  });
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Account Information'),
            onTap: () =>
                _navigateTo(context, AccountInformationPage(profile: profile)),
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: const Text('Manage Account'),
            onTap: () => _showPlaceholder(context, 'Manage Account'),
          ),
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('Manage Post'),
            onTap: () => _showPlaceholder(context, 'Manage Post'),
          ),

          const Spacer(),
          const Divider(),

          // â”€â”€ Logout â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              Navigator.of(context).pop();
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
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
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true) {
                onLogout();
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
