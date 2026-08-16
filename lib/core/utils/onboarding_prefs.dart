import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the user has already seen the onboarding flow, so it is
/// shown only on the first app launch.
class OnboardingPrefs {
  OnboardingPrefs._();

  static const String _seenKey = 'onboarding_seen';

  /// True once the user has completed (or skipped past) onboarding.
  static Future<bool> hasSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenKey) ?? false;
  }

  /// Marks onboarding as seen so it won't be shown again.
  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
  }
}
