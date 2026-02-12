import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/profile_model.dart';
import 'account_information_page.dart';

class SettingsDrawer extends StatelessWidget {
  final ProfileModel? profile;
  final VoidCallback onLogout;

  const SettingsDrawer({
    super.key,
    required this.profile,
    required this.onLogout,
  });

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).pop(); // Close drawer
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  void _showPlaceholder(BuildContext context, String title) {
    Navigator.of(context).pop(); // Close drawer
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
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (profile?.username != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '@${profile!.username}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Profile'),
            onTap: () => _showPlaceholder(context, 'Edit Profile'),
          ),
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('Manage Post'),
            onTap: () => _showPlaceholder(context, 'Manage Post'),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              Navigator.of(context).pop(); // Close drawer

              // Show confirmation
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
