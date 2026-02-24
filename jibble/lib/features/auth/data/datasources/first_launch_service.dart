import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage first-launch detection
///
/// Uses SharedPreferences to track whether the app has been launched before
class FirstLaunchService {
  static const String _firstLaunchKey = 'has_launched_before';

  /// Check if this is the first time the app is being launched
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunchedBefore = prefs.getBool(_firstLaunchKey) ?? false;
    return !hasLaunchedBefore;
  }

  /// Mark that the first launch has been completed
  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, true);
  }
}
