import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../services/first_launch_service.dart';
import '../../widgets/auth_gate.dart';

/// Enhanced Splash Screen with Lottie Animation
///
/// Displays a beautiful handshake animation with welcome text
/// Auto-navigates to AuthGate after animation completes
class EnhancedSplashScreen extends StatefulWidget {
  const EnhancedSplashScreen({super.key});

  @override
  State<EnhancedSplashScreen> createState() => _EnhancedSplashScreenState();
}

class _EnhancedSplashScreenState extends State<EnhancedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Setup fade animation for text
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Setup slide animation for text
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start animations with delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });

    // Navigate after animation
    _navigateToAuth();
  }

  Future<void> _navigateToAuth() async {
    // Wait for 4 seconds to show the animation
    await Future.delayed(const Duration(seconds: 4));

    // Mark first launch as complete
    final firstLaunchService = FirstLaunchService();
    await firstLaunchService.setFirstLaunchComplete();

    // Navigate to AuthGate
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AuthGate(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E3A8A), // Deep blue
              const Color(0xFF3B82F6), // Bright blue
              const Color(0xFF60A5FA), // Light blue
              const Color(0xFF93C5FD), // Very light blue
            ],
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Lottie Animation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Lottie.asset(
                  'assets/Loffie Animations/Handshake Loop.json',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
              ),

              const SizedBox(height: 40),

              // Animated Text Content
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // App Name
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFF0F9FF)],
                        ).createShader(bounds),
                        child: Text(
                          'Jibble',
                          style: GoogleFonts.poppins(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 3,
                            height: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tagline
                      Text(
                        'Connect. Collaborate. Celebrate.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.5,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Your campus community awaits',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading your experience...',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
