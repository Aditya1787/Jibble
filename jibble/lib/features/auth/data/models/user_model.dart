import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({required super.id, super.email, super.createdAt});

  factory UserModel.fromSupabaseUser(supabase.User user) {
    return UserModel(id: user.id, email: user.email, createdAt: user.createdAt);
  }
}
