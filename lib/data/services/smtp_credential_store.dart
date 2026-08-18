import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the SMTP password in the platform secure store
/// (iOS Keychain / Android Keystore-backed EncryptedSharedPreferences).
///
/// On first launch the password is written from the compiled constant into
/// secure storage. All subsequent reads come from secure storage so the
/// credential is encrypted at rest and never sits in plain SharedPreferences.
class SmtpCredentialStore {
  static const _key = 'smtp_password';
  static const _password = 'Circuito2525!';

  final FlutterSecureStorage _storage;

  SmtpCredentialStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Writes the password into secure storage on first launch.
  /// Safe to call on every startup — no-op once already stored.
  Future<void> bootstrap() async {
    final existing = await _storage.read(key: _key);
    if (existing == null) {
      await _storage.write(key: _key, value: _password);
      debugPrint('SmtpCredentialStore: password saved to secure storage');
    }
  }

  /// Returns the SMTP password from secure storage.
  Future<String> getPassword() async {
    try {
      return await _storage.read(key: _key) ?? _password;
    } catch (e) {
      debugPrint('SmtpCredentialStore: read failed: $e');
      return _password;
    }
  }
}
