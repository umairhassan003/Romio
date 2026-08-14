import 'package:flutter/foundation.dart';
import '../models/saved_card.dart';

/// In-memory wallet of cards the guest added during this session.
///
/// Nothing here is persisted to Supabase — the list (including card numbers)
/// lives only in RAM and is gone on app restart. This backs the add / delete /
/// select-to-pay UI; swapping it for a vault-backed store later is isolated to
/// this class.
class CardWalletProvider extends ChangeNotifier {
  final List<SavedCard> _cards = [];
  String? _selectedId;
  int _counter = 0;

  List<SavedCard> get cards => List.unmodifiable(_cards);
  bool get hasCards => _cards.isNotEmpty;

  SavedCard? get selected {
    if (_selectedId == null) return null;
    for (final c in _cards) {
      if (c.id == _selectedId) return c;
    }
    return null;
  }

  /// Adds a card and selects it. Returns the created [SavedCard].
  SavedCard addCard({
    required String number,
    required String holderName,
    required int expMonth,
    required int expYear,
    required String billingCountry,
  }) {
    final card = SavedCard(
      id: 'card_${_counter++}',
      number: number,
      holderName: holderName,
      expMonth: expMonth,
      expYear: expYear,
      billingCountry: billingCountry,
    );
    _cards.add(card);
    _selectedId = card.id;
    notifyListeners();
    return card;
  }

  void removeCard(String id) {
    _cards.removeWhere((c) => c.id == id);
    if (_selectedId == id) {
      _selectedId = _cards.isNotEmpty ? _cards.first.id : null;
    }
    notifyListeners();
  }

  void select(String id) {
    if (_cards.any((c) => c.id == id)) {
      _selectedId = id;
      notifyListeners();
    }
  }
}
