import 'dart:io';

Future<void> main() async {
  final Map<String, String> files = {
    // CONSTANTS
    'lib/core/constants/app_constants.dart': '''
class AppConstants {
  static const String appName = 'Jibble';
  static const String appVersion = '1.0.0';
  static const int defaultPaginationLimit = 20;
  static const int maxImageSizeMB = 5;
}
''',
    'lib/core/constants/api_constants.dart': '''
class ApiConstants {
  static const int timeoutInSeconds = 30;
  // Supabase keys are typically loaded via env variables in SupabaseConfig
}
''',
    'lib/core/constants/route_constants.dart': '''
class RouteConstants {
  static const String home = '/home';
  static const String profile = '/profile';
  static const String search = '/search';
  static const String createPost = '/create-post';
  static const String login = '/login';
  static const String register = '/register';
}
''',
    'lib/core/constants/asset_constants.dart': '''
class AssetConstants {
  static const String splashLottie = 'assets/lottie/splash.json';
  static const String placeholderImage = 'assets/images/placeholder.png';
  static const String defaultAvatar = 'assets/images/default_avatar.png';
}
''',
    'lib/core/constants/storage_constants.dart': '''
class StorageConstants {
  static const String avatarsBucket = 'avatars';
  static const String postImagesBucket = 'post_images';
  static const String groupIconsBucket = 'group_icons';
}
''',

    // UTILS
    'lib/core/utils/date_utils.dart': '''
class AppDateUtils {
  static String timeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 365) return "\${(duration.inDays / 365).floor()}y";
    if (duration.inDays > 30) return "\${(duration.inDays / 30).floor()}mo";
    if (duration.inDays > 0) return "\${duration.inDays}d";
    if (duration.inHours > 0) return "\${duration.inHours}h";
    if (duration.inMinutes > 0) return "\${duration.inMinutes}m";
    return "just now";
  }
}
''',
    'lib/core/utils/validators.dart': '''
class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#\$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+.[a-zA-Z]+");
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username is required';
    if (value.length < 3) return 'Username must be at least 3 characters';
    return null;
  }
}
''',
    'lib/core/utils/debouncer.dart': '''
import 'dart:async';
import 'package:flutter/foundation.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
''',
    'lib/core/utils/extensions.dart': '''
import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return "\${this[0].toUpperCase()}\${substring(1).toLowerCase()}";
  }
}
''',
    'lib/core/utils/logger.dart': '''
import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String message, {String tag = 'APP'}) {
    if (kDebugMode) {
      print('[\$tag] \$message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[ERROR] \$message');
      if (error != null) print(error);
      if (stackTrace != null) print(stackTrace);
    }
  }
}
''',
    'lib/core/utils/device_utils.dart': '''
import 'package:flutter/material.dart';

class DeviceUtils {
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static double getScreenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double getScreenHeight(BuildContext context) => MediaQuery.of(context).size.height;
}
''',

    // THEME
    'lib/core/theme/app_colors.dart': '''
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.blue;
  static Color primaryLight = Colors.blue.shade300;
  static Color primaryDark = Colors.blue.shade700;
  
  static const Color background = Colors.white;
  static Color surface = Colors.grey.shade50;
  static Color textPrimary = Colors.black87;
  static Color textSecondary = Colors.grey.shade600;
  
  static Color error = Colors.red.shade400;
  static Color success = Colors.green.shade400;
}
''',
    'lib/core/theme/text_styles.dart': '''
import 'package:flutter/material.dart';

class AppTextStyles {
  // Add GoogleFonts if you have it in pubspec, otherwise use default
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}
''',
    'lib/core/theme/app_spacing.dart': '''
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
''',
    'lib/core/theme/app_radius.dart': '''
import 'package:flutter/material.dart';

class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double round = 999.0;

  static BorderRadius get circularSm => BorderRadius.circular(sm);
  static BorderRadius get circularMd => BorderRadius.circular(md);
  static BorderRadius get circularLg => BorderRadius.circular(lg);
  static BorderRadius get circularXl => BorderRadius.circular(xl);
}
''',
    'lib/core/theme/app_theme.dart': '''
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: AppRadius.circularLg,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularLg,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularLg,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.circularLg),
          elevation: 2,
        ),
      ),
    );
  }
}
''',

    // ERRORS
    'lib/core/errors/exceptions.dart': '''
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'A server error occurred']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Authentication failed']);
}

class CacheException implements Exception {}
''',
    'lib/core/errors/failures.dart': '''
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}
''',
    'lib/core/errors/error_messages.dart': '''
class ErrorMessages {
  static const String serverError = 'An error occurred while communicating with the server.';
  static const String networkError = 'Please check your internet connection.';
  static const String unauthorized = 'You are not authorized to perform this action.';
  static const String unknown = 'An unknown error occurred.';
}
''',
    'lib/core/errors/error_handler.dart': '''
import 'exceptions.dart';
import 'failures.dart';
import 'error_messages.dart';

class ErrorHandler {
  static Failure handleException(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is AuthException) {
      return ServerFailure(exception.message);
    } else {
      return ServerFailure(ErrorMessages.unknown);
    }
  }
}
''',

    // NETWORK
    'lib/core/network/api_client.dart': '''
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
''',
    'lib/core/network/endpoints.dart': '''
class Endpoints {
  static const String users = 'users';
  static const String profiles = 'profiles';
  static const String posts = 'posts';
  static const String comments = 'comments';
  static const String likes = 'likes';
  static const String groups = 'groups';
  static const String groupMembers = 'group_members';
  static const String messages = 'messages';
}
''',
    'lib/core/network/network_info.dart': '''
// Stub interface for network connection checking.
// Typically implemented using internet_connection_checker or connectivity_plus package.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true; // implement actual check
}
''',
    'lib/core/network/network_interceptor.dart': '''
import '../utils/logger.dart';

class NetworkInterceptor {
  static void logRequest(String url, Map<String, dynamic>? params) {
    AppLogger.log('REQ: \$url | Params: \$params', tag: 'NETWORK');
  }

  static void logResponse(String url, dynamic response) {
    AppLogger.log('RES: \$url | Data: \$response', tag: 'NETWORK');
  }
}
''',
    'lib/core/network/api_response.dart': '''
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResponse({required this.success, this.data, this.message});

  factory ApiResponse.success(T data) => ApiResponse(success: true, data: data);
  factory ApiResponse.error(String message) => ApiResponse(success: false, message: message);
}
''',

    // SERVICES
    'lib/core/services/auth_service.dart': '''
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
''',
    'lib/core/services/storage_service.dart': '''
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class CoreStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadFile(String bucketName, File file, String folder, {int maxMb = 5}) async {
    // Basic validation
    final sizeInMb = file.lengthSync() / (1024 * 1024);
    if (sizeInMb > maxMb) {
      throw Exception('File exceeds maximum size of \${maxMb}MB');
    }

    final ext = p.extension(file.path);
    final fileName = '\${DateTime.now().millisecondsSinceEpoch}\$ext';
    final filePath = '\$folder/\$fileName';

    await _supabase.storage.from(bucketName).upload(filePath, file);
    return _supabase.storage.from(bucketName).getPublicUrl(filePath);
  }
}
''',
    'lib/core/services/notification_service.dart': '''
class NotificationService {
  Future<void> initialize() async {
    // Initialize Local Notifications / Firebase Messaging here
  }

  Future<void> showNotification(String title, String body) async {
    // Show local notification
  }
}
''',
    'lib/core/services/analytics_service.dart': '''
class AnalyticsService {
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    // Send event to Firebase Analytics, Mixpanel, etc.
  }

  Future<void> setUserId(String userId) async {
    // Identify user
  }
}
''',
    'lib/core/services/cache_service.dart': '''
class CacheService {
  Future<void> init() async {
    // Initialize SharedPreferences or Hive
  }

  Future<void> saveString(String key, String value) async {
    // Save to cache
  }

  Future<String?> getString(String key) async {
    // Get from cache
    return null;
  }
}
''',
    'lib/core/services/permission_service.dart': '''
class PermissionService {
  Future<bool> requestCameraPermission() async {
    // Utilize permission_handler package
    return true;
  }

  Future<bool> requestGalleryPermission() async {
    // Utilize permission_handler package
    return true;
  }
}
''',
  };

  for (final entry in files.entries) {
    final filePath = entry.key;
    final content = entry.value;
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
    print('Generated \$filePath');
  }
}
