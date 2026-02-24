import 'package:supabase_flutter/supabase_flutter.dart';

class CoreAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  
  bool get isAuthenticated => currentUser != null;

  String? get currentUserId => currentUser?.id;

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
