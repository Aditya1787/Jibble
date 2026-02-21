import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'widgets/auth_gate.dart';
import 'screens/home_page.dart';
import 'screens/Profile/profile_page.dart';
import 'screens/Search/search_page.dart';
import 'screens/splash/splash_screen.dart';
import 'services/first_launch_service.dart';
import 'screens/create_post_page.dart';

// Export MyHomePage so it can be imported by onboarding_gate
export 'screens/home_page.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/feed_provider.dart';

/// Main entry point of the application
///
/// Initializes Supabase before running the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // Make sure to add your credentials in lib/config/supabase_config.dart
  await SupabaseConfig.initialize();

  final isFirstLaunch = await FirstLaunchService().isFirstLaunch();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
      ],
      child: MyApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  final bool isFirstLaunch;
  const MyApp({super.key, required this.isFirstLaunch});

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
      home: isFirstLaunch ? const EnhancedSplashScreen() : const AuthGate(),
      // Named routes for navigation
      routes: {
        '/home': (context) => const MyHomePage(),
        '/profile': (context) => const ProfilePage(),
        '/search': (context) => const SearchPage(),
        '/create-post': (context) => const CreatePostPage(),
      },
    );
  }
}
