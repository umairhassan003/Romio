import '../../../../core/utils/card_brand.dart';
import '../../../../domain/gateways/payment_gateway.dart';

/// A card the guest added in this session. Held **only in memory** — never
/// written to Supabase. The full [number] lives in RAM so it can be charged at
/// pay time; the CVV is never stored here (it is collected at checkout).
class SavedCard {
  final String id;
  final String number;
  final String holderName;
  final int expMonth;
  final int expYear;
  final String billingCountry;

  const SavedCard({
    required this.id,
    required this.number,
    required this.holderName,
    required this.expMonth,
    required this.expYear,
    required this.billingCountry,
  });

  /// Digits only, spaces/dashes stripped.
  String get sanitizedNumber => number.replaceAll(RegExp(r'\D'), '');

  CardBrand get brand => detectCardBrand(number);

  String get last4 => sanitizedNumber.length >= 4
      ? sanitizedNumber.substring(sanitizedNumber.length - 4)
      : sanitizedNumber;

  /// e.g. "•••• •••• •••• 6789".
  String get maskedLabel => '•••• •••• •••• $last4';

  /// e.g. "04/30".
  String get expiryLabel =>
      '${expMonth.toString().padLeft(2, '0')}/${(expYear % 100).toString().padLeft(2, '0')}';

  /// Builds the [CardDetails] passed to the payment gateway, injecting the CVV
  /// the guest enters at pay time (never persisted on the card itself).
  CardDetails toCardDetails(String cvv) => CardDetails(
        number: number,
        holderName: holderName,
        expiryMonth: expMonth,
        expiryYear: expYear,
        cvv: cvv,
      );
}
