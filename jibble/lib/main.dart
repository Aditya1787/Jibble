import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'widgets/auth_gate.dart';
import 'screens/home_page.dart';
import 'screens/Profile/profile_page.dart';
import 'screens/Search/search_page.dart';
import 'screens/splash/splash_screen.dart';
import 'services/first_launch_service.dart';

// Export MyHomePage so it can be imported by onboarding_gate
export 'screens/home_page.dart';

/// Main entry point of the application
///
/// Initializes Supabase before running the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // Make sure to add your credentials in lib/config/supabase_config.dart
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jibble Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // Check if first launch and show appropriate screen
      home: FutureBuilder<bool>(
        future: FirstLaunchService().isFirstLaunch(),
        builder: (context, snapshot) {
          // Show loading while checking first launch status
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Show splash screen on first launch, otherwise show AuthGate
          final isFirstLaunch = snapshot.data ?? false;
          return isFirstLaunch
              ? const EnhancedSplashScreen()
              : const AuthGate();
        },
      ),
      // Named routes for navigation
      routes: {
        '/home': (context) => const MyHomePage(),
        '/profile': (context) => const ProfilePage(),
        '/search': (context) => const SearchPage(),
      },
    );
  }
}
