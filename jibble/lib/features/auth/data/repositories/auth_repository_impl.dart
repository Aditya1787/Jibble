import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_service.dart';
import '../models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthRepositoryImpl implements AuthRepository {
  final AuthService remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity?> signUp({
    required String email,
    required String password,
  }) async {
    final supabaseUser = await remoteDataSource.signUp(
      email: email,
      password: password,
    );
    if (supabaseUser != null) {
      return UserModel.fromSupabaseUser(supabaseUser);
    }
    return null;
  }

  @override
  Future<UserEntity?> signIn({
    required String email,
    required String password,
  }) async {
    final supabaseUser = await remoteDataSource.signIn(
      email: email,
      password: password,
    );
    if (supabaseUser != null) {
      return UserModel.fromSupabaseUser(supabaseUser);
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  UserEntity? getCurrentUser() {
    final supabaseUser = remoteDataSource.currentUser;
    if (supabaseUser != null) {
      return UserModel.fromSupabaseUser(supabaseUser);
    }
    return null;
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((supabase.AuthState state) {
      final user = state.session?.user;
      if (user != null) {
        return UserModel.fromSupabaseUser(user);
      }
      return null;
    });
  }

  @override
  bool isSignedIn() {
    return remoteDataSource.isSignedIn();
  }
}
