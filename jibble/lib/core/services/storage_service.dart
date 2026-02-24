import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class CoreStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadFile(String bucketName, File file, String folder, {int maxMb = 5}) async {
    // Basic validation
    final sizeInMb = file.lengthSync() / (1024 * 1024);
    if (sizeInMb > maxMb) {
      throw Exception('File exceeds maximum size of ${maxMb}MB');
    }

    final ext = p.extension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final filePath = '$folder/$fileName';

    await _supabase.storage.from(bucketName).upload(filePath, file);
    return _supabase.storage.from(bucketName).getPublicUrl(filePath);
  }
}
