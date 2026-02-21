import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  User? _user;
  ProfileModel? _profile;
  bool _isLoading = true;

  User? get user => _user;
  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _user = _authService.currentUser;

    // Listen to auth state changes
    _authService.authStateChanges.listen((data) async {
      _user = data.session?.user;
      if (_user != null) {
        await fetchProfile();
      } else {
        _profile = null;
        _isLoading = false;
        notifyListeners();
      }
    });

    if (_user != null) {
      await fetchProfile();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    if (_user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      _profile = await _profileService.getProfile(_user!.id);
    } catch (e) {
      debugPrint('Error fetching profile: \$e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
