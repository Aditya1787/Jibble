import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final SupabaseClient supabase;

  ApiClient(this.supabase);

  Future<dynamic> get(String table, {Map<String, dynamic>? query}) async {
    try {
      var request = supabase.from(table).select();
      if (query != null) {
        query.forEach((key, value) {
          request = request.eq(key, value);
        });
      }
      return await request;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
