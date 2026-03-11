import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Configuration
///
/// 
/// 1. Go to your Supabase project dashboard (https://app.supabase.com)
/// 2. Navigate to Settings > API
/// 3. Copy your Project URL and paste it in the supabaseUrl variable below
/// 4. Copy your anon/public key and paste it in the supabaseAnonKey variable below
class SupabaseConfig {
  
  // Example: 'https://your-project-id.supabase.co'
  static const String supabaseUrl = 'https://mvqefkzoeoeckovitnkm.supabase.co';

  
  // Example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  static const String supabaseAnonKey = 'sb_publishable_GFp6Ysb7dzM2M-UYbMetQQ_X53dHON8';

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
}

/// Global Supabase client instance
/// Use this throughout your app to access Supabase services
final supabase = Supabase.instance.client;
