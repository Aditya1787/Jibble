import 'package:flutter/material.dart';
import 'package:jibble/features/auth/presentation/screens/onboarding/profile_picture_page.dart';
import 'package:jibble/core/theme/app_colors.dart';
import 'package:jibble/core/theme/app_radius.dart';
import 'package:jibble/core/theme/app_spacing.dart';
import 'package:jibble/core/theme/text_styles.dart';

/// College Name Input Page
///
/// Third step of onboarding - collects user's college name
class CollegePage extends StatefulWidget {
  final String username;
  final DateTime dateOfBirth;

  const CollegePage({
    super.key,
    required this.username,
    required this.dateOfBirth,
  });

  @override
  State<CollegePage> createState() => _CollegePageState();
}

class _CollegePageState extends State<CollegePage> {
  final _formKey = GlobalKey<FormState>();
  final _collegeController = TextEditingController();

  final bool _isLoading = false;

  @override
  void dispose() {
    _collegeController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    // Navigate to next page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfilePicturePage(
          username: widget.username,
          dateOfBirth: widget.dateOfBirth,
          collegeName: _collegeController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'College',
          style: AppTextStyles.heading1.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Progress indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProgressDot(true),
                      _buildProgressLine(true),
                      _buildProgressDot(true),
                      _buildProgressLine(true),
                      _buildProgressDot(true),
                      _buildProgressLine(false),
                      _buildProgressDot(false),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Icon
                  Container(
                    width: 100,
                    height: 100,
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
                    child: Icon(
                      Icons.school_outlined,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Title
                  Text(
                    'Which College?',
                    style: AppTextStyles.heading1.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Connect with students from your college',
                    style: AppTextStyles.bodyText.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Form
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.circularXl,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _collegeController,
                              decoration: const InputDecoration(
                                labelText: 'College Name',
                                prefixIcon: Icon(Icons.school),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your college name';
                                }
                                if (value.length < 3) {
                                  return 'College name must be at least 3 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleNext,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.circularLg,
                                ),
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                'Next',
                                style: AppTextStyles.bodyText.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildProgressDot(bool isActive) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      width: 30,
      height: 2,
      color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
    );
  }
}
