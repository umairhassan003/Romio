import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app locale (EN/ES) with persistence via SharedPreferences.
/// The Supabase profile sync is handled by ProfileProvider separately.
class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'preferred_locale';

  Locale _locale = const Locale('es'); // Default Spanish as shown in screenshots

  LocaleProvider() {
    _loadSavedLocale();
  }

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null && (saved == 'en' || saved == 'es')) {
      _locale = Locale(saved);
      notifyListeners();
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode != 'en' && languageCode != 'es') return;
    _locale = Locale(languageCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, languageCode);
  }
}
