import 'package:flutter/material.dart';
import 'package:jibble/core/config/supabase_config.dart';
import 'package:jibble/features/auth/presentation/widgets/auth_gate.dart';
import 'package:jibble/features/home/presentation/screens/home_page.dart';
import 'package:jibble/features/profile/presentation/screens/profile_page.dart';
import 'package:jibble/features/search/presentation/screens/search_page.dart';
import 'package:jibble/features/auth/presentation/screens/splash_screen.dart';
import 'package:jibble/features/auth/data/datasources/first_launch_service.dart';
import 'package:jibble/features/post/presentation/screens/create_post_page.dart';

// Export MyHomePage so it can be imported by onboarding_gate
export 'package:jibble/features/home/presentation/screens/home_page.dart';

import 'package:provider/provider.dart';
import 'package:jibble/features/auth/presentation/provider/auth_provider.dart';
import 'package:jibble/features/home/presentation/provider/feed_provider.dart';
import 'package:jibble/core/theme/app_theme.dart';

import 'package:jibble/core/di/injection_container.dart' as di;

/// Main entry point of the application
///
/// Initializes Supabase before running the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection
  await di.init();

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
      title: 'Jibble',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
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
