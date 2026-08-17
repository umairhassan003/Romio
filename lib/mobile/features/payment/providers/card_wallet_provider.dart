import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/saved_card_store.dart';
import '../models/saved_card.dart';

/// Wallet of the guest's saved cards.
///
/// Cards are persisted **only on this device**, encrypted, via [SavedCardStore]
/// (never sent to Supabase). They are scoped to the signed-in account: call
/// [loadForUser] after login to populate them, and [clearForUser] when the
/// account is deleted. The full card number is kept so a saved card can be paid
/// with on the same device; the CVV is never stored (collected at pay time).
class CardWalletProvider extends ChangeNotifier {
  final SavedCardStore _store;
  final List<SavedCard> _cards = [];
  String? _selectedId;
  String? _userId;

  CardWalletProvider({SavedCardStore? store})
      : _store = store ?? SavedCardStore();

  List<SavedCard> get cards => List.unmodifiable(_cards);
  bool get hasCards => _cards.isNotEmpty;

  SavedCard? get selected {
    if (_selectedId == null) return null;
    for (final c in _cards) {
      if (c.id == _selectedId) return c;
    }
    return null;
  }

  /// Loads the cards saved on this device for [userId] (called after login).
  Future<void> loadForUser(String userId) async {
    _userId = userId;
    final loaded = await _store.load(userId);
    _cards
      ..clear()
      ..addAll(loaded);
    _selectedId = _cards.isNotEmpty ? _cards.first.id : null;
    notifyListeners();
  }

  /// Adds a card, selects it, and persists the wallet. Returns the new card.
  SavedCard addCard({
    required String number,
    required String holderName,
    required int expMonth,
    required int expYear,
    String billingCountry = '',
    String? label,
  }) {
    final card = SavedCard(
      // Timestamp-based id stays unique across sessions (no counter to reset).
      id: 'card_${DateTime.now().microsecondsSinceEpoch}',
      number: number,
      holderName: holderName,
      expMonth: expMonth,
      expYear: expYear,
      billingCountry: billingCountry,
      label: label,
    );
    _cards.add(card);
    _selectedId = card.id;
    _persist();
    notifyListeners();
    return card;
  }

  void removeCard(String id) {
    _cards.removeWhere((c) => c.id == id);
    if (_selectedId == id) {
      _selectedId = _cards.isNotEmpty ? _cards.first.id : null;
    }
    _persist();
    notifyListeners();
  }

  void select(String id) {
    if (_cards.any((c) => c.id == id)) {
      _selectedId = id;
      notifyListeners();
    }
  }

  /// Deletes this account's cards from the device (used on account deletion).
  Future<void> clearForUser(String userId) async {
    if (_userId == userId) {
      _cards.clear();
      _selectedId = null;
      notifyListeners();
    }
    await _store.clear(userId);
  }

  /// Writes the current cards to encrypted device storage for the active user.
  void _persist() {
    final userId = _userId;
    if (userId == null) return;
    unawaited(_store.save(userId, List.of(_cards)));
  }
}
