import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../services/auth_service.dart';

class AccountInformationPage extends StatelessWidget {
  final ProfileModel? profile;
  final AuthService _authService = AuthService();

  AccountInformationPage({super.key, required this.profile});

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

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Information'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade600, Colors.blue.shade50],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username
                    if (profile?.username != null) ...[
                      _buildInfoRow(
                        Icons.alternate_email,
                        'Username',
                        profile!.username,
                      ),
                      const Divider(height: 24),
                    ],

                    // Date of Birth
                    if (profile?.dateOfBirth != null) ...[
                      _buildInfoRow(
                        Icons.cake_outlined,
                        'Date of Birth',
                        '${_formatDate(profile!.dateOfBirth!)} (${_calculateAge(profile!.dateOfBirth!)} years old)',
                      ),
                      const Divider(height: 24),
                    ],

                    // College
                    if (profile?.collegeName != null) ...[
                      _buildInfoRow(
                        Icons.school_outlined,
                        'College',
                        profile!.collegeName!,
                      ),
                      const Divider(height: 24),
                    ],

                    // Email
                    _buildInfoRow(
                      Icons.email_outlined,
                      'Email',
                      user?.email ?? 'Not available',
                    ),
                    const Divider(height: 24),

                    // User ID
                    _buildInfoRow(
                      Icons.verified_user_outlined,
                      'User ID',
                      user?.id ?? 'Not available',
                    ),
                    const Divider(height: 24),

                    // Account Created
                    _buildInfoRow(
                      Icons.calendar_today_outlined,
                      'Account Created',
                      user?.createdAt != null
                          ? _formatDate(DateTime.parse(user!.createdAt))
                          : 'Not available',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
