import 'package:flutter/material.dart';
import 'package:jibble/features/auth/domain/entities/user_entity.dart';
import 'package:jibble/features/auth/domain/usecases/get_auth_state_changes_usecase.dart';
import 'package:jibble/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jibble/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:jibble/core/di/injection_container.dart';
import 'package:jibble/features/profile/domain/entities/profile_entity.dart';
import 'package:jibble/features/profile/domain/usecases/get_profile_usecase.dart';

class AuthProvider extends ChangeNotifier {
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final GetAuthStateChangesUseCase _getAuthStateChangesUseCase;
  late final SignOutUseCase _signOutUseCase;
  late final GetProfileUseCase _getProfileUseCase;

  UserEntity? _user;
  ProfileEntity? _profile;
  bool _isLoading = true;

  UserEntity? get user => _user;
  ProfileEntity? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
    _getAuthStateChangesUseCase = sl<GetAuthStateChangesUseCase>();
    _signOutUseCase = sl<SignOutUseCase>();
    _getProfileUseCase = sl<GetProfileUseCase>();
    _initAuth();
  }

  Future<void> _initAuth() async {
    _user = _getCurrentUserUseCase();

    // Listen to auth state changes
    _getAuthStateChangesUseCase().listen((user) async {
      _user = user;
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

      _profile = await _getProfileUseCase(_user!.id);
    } catch (e) {
      debugPrint('Error fetching profile: \$e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _signOutUseCase();
  }
}
