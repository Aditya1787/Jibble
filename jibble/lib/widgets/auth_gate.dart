import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../screens/Authentication/login_page.dart';
import 'onboarding_gate.dart';

/// Authentication Gate
///
/// This widget acts as a route guard that checks if the user is authenticated.
/// - If authenticated: shows the OnboardingGate (which checks profile completion)
/// - If not authenticated: shows the LoginPage
///
/// It also listens to auth state changes and updates the UI accordingly
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Check if we have a session (user is logged in)
        if (snapshot.hasData && snapshot.data?.session != null) {
          return const OnboardingGate();
        }

        // No session, show login page
        return const LoginPage();
      },
    );
  }
}
