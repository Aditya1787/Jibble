import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Authentication Service
///
/// Handles all authentication operations including sign up, sign in, sign out,
/// and auth state management using Supabase
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Get the current authenticated user
  User? get currentUser => supabase.auth.currentUser;

  /// Stream of auth state changes
  /// Listen to this to react to login/logout events
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  /// Sign up a new user with email and password
  ///
  /// Returns the User object on success
  /// Throws an exception on failure
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred during sign up';
    }
  }

  /// Sign in an existing user with email and password
  ///
  /// Returns the User object on success
  /// Throws an exception on failure
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred during sign in';
    }
  }

  /// Sign out the current user
  ///
  /// Throws an exception on failure
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred during sign out';
    }
  }

  /// Check if a user is currently signed in
  bool isSignedIn() {
    return currentUser != null;
  }
}
