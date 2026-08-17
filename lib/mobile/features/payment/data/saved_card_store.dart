import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/saved_card.dart';

/// Persists the guest's cards **only on this device**, encrypted at rest via the
/// platform secure storage (iOS Keychain / Android Keystore-backed
/// EncryptedSharedPreferences). Nothing is ever sent to Supabase or any server.
///
/// Cards are keyed by account (`saved_cards_<userId>`) so different accounts on
/// the same device don't share cards, and a card added on one device is not
/// available on another (the user re-enters it there). The CVV is never stored.
class SavedCardStore {
  final FlutterSecureStorage _storage;

  SavedCardStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  String _key(String userId) => 'saved_cards_$userId';

  Future<List<SavedCard>> load(String userId) async {
    try {
      final raw = await _storage.read(key: _key(userId));
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(SavedCard.fromJson)
          .toList();
    } catch (e) {
      debugPrint('SavedCardStore: load failed: $e');
      return [];
    }
  }

  Future<void> save(String userId, List<SavedCard> cards) async {
    try {
      final raw = jsonEncode(cards.map((c) => c.toJson()).toList());
      await _storage.write(key: _key(userId), value: raw);
    } catch (e) {
      debugPrint('SavedCardStore: save failed: $e');
    }
  }

  Future<void> clear(String userId) async {
    try {
      await _storage.delete(key: _key(userId));
    } catch (e) {
      debugPrint('SavedCardStore: clear failed: $e');
    }
  }
}
