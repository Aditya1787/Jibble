import 'package:flutter/material.dart';
import 'package:jibble/features/auth/presentation/screens/onboarding/college_page.dart';
import 'package:jibble/core/theme/app_colors.dart';
import 'package:jibble/core/theme/app_radius.dart';
import 'package:jibble/core/theme/app_spacing.dart';
import 'package:jibble/core/theme/text_styles.dart';

/// Date of Birth Input Page
///
/// Second step of onboarding - collects user's date of birth
class DateOfBirthPage extends StatefulWidget {
  final String username;

  const DateOfBirthPage({super.key, required this.username});

  @override
  State<DateOfBirthPage> createState() => _DateOfBirthPageState();
}

class _DateOfBirthPageState extends State<DateOfBirthPage> {
  DateTime? _selectedDate;
  String? _errorMessage;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _errorMessage = null;
      });
    }
  }

  void _handleNext() {
    if (_selectedDate == null) {
      setState(() {
        _errorMessage = 'Please select your date of birth';
      });
      return;
    }

    // Navigate to next page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CollegePage(username: widget.username, dateOfBirth: _selectedDate!),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Date of Birth',
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
                      _buildProgressLine(false),
                      _buildProgressDot(false),
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
                      Icons.cake_outlined,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Title
                  Text(
                    'When\'s Your Birthday?',
                    style: AppTextStyles.heading1.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'We use this to personalize your experience',
                    style: AppTextStyles.bodyText.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Date selector card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.circularXl,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Date display/selector
                          InkWell(
                            onTap: _selectDate,
                            borderRadius: AppRadius.circularLg,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _errorMessage != null
                                      ? AppColors.error
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: AppRadius.circularLg,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      _selectedDate != null
                                          ? _formatDate(_selectedDate!)
                                          : 'Select your date of birth',
                                      style: AppTextStyles.bodyText.copyWith(
                                        color: _selectedDate != null
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Error message
                          if (_errorMessage != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _errorMessage!,
                              style: AppTextStyles.bodyText.copyWith(
                                color: AppColors.error,
                                fontSize: 12,
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.lg),

                          // Next button
                          ElevatedButton(
                            onPressed: _handleNext,
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
