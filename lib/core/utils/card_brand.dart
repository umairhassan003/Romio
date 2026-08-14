/// Card networks Romio accepts. Cards are processed through PayPal, which
/// supports both Visa and Mastercard; anything else is [CardBrand.unknown] and
/// rejected by the add-card form.
enum CardBrand { visa, mastercard, unknown }

extension CardBrandX on CardBrand {
  bool get isSupported => this == CardBrand.visa || this == CardBrand.mastercard;
}

/// Detects the card network from a (possibly formatted) card number using the
/// leading digits (IIN ranges). Only Visa and Mastercard are recognised.
CardBrand detectCardBrand(String rawNumber) {
  final digits = rawNumber.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return CardBrand.unknown;

  // Visa: starts with 4.
  if (digits.startsWith('4')) return CardBrand.visa;

  // Mastercard: 51–55, or the 2221–2720 range.
  if (digits.length >= 2) {
    final twoDigits = int.tryParse(digits.substring(0, 2)) ?? 0;
    if (twoDigits >= 51 && twoDigits <= 55) return CardBrand.mastercard;
  }
  if (digits.length >= 4) {
    final fourDigits = int.tryParse(digits.substring(0, 4)) ?? 0;
    if (fourDigits >= 2221 && fourDigits <= 2720) return CardBrand.mastercard;
  }

  return CardBrand.unknown;
}
