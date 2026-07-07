/// Abstraction over a payment provider. The reservation flow depends only on
/// this interface, so swapping the local "record-only" implementation for a
/// live backend-backed one later is a single-line change in DI.
///
/// Romio currently supports two user-facing methods, both settled through the
/// same PayPal account:
///   * [PaymentMethodType.paypal] — pay with a PayPal balance/account.
///   * [PaymentMethodType.card]   — credit/debit card processed via PayPal.
library;

/// The payment method chosen by the guest.
enum PaymentMethodType {
  paypal,
  card;

  /// Stable string stored in the `payments.provider` column.
  String get providerKey {
    switch (this) {
      case PaymentMethodType.paypal:
        return 'paypal';
      case PaymentMethodType.card:
        return 'card';
    }
  }

  static PaymentMethodType fromKey(String key) {
    switch (key) {
      case 'paypal':
        return PaymentMethodType.paypal;
      case 'card':
      case 'credit_card':
        return PaymentMethodType.card;
      default:
        return PaymentMethodType.card;
    }
  }
}

/// Minimal card details collected from the in-app card form. Only the last 4
/// digits are ever persisted (as a display label); the full PAN/CVV are passed
/// to the gateway and never stored.
class CardDetails {
  final String number;
  final String holderName;
  final int expiryMonth;
  final int expiryYear;
  final String cvv;

  const CardDetails({
    required this.number,
    required this.holderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
  });

  /// Digits only, spaces/dashes stripped.
  String get sanitizedNumber => number.replaceAll(RegExp(r'\D'), '');

  String get last4 => sanitizedNumber.length >= 4
      ? sanitizedNumber.substring(sanitizedNumber.length - 4)
      : sanitizedNumber;

  String get maskedLabel => '•••• •••• •••• $last4';
}

/// Called when a PayPal-wallet payment needs buyer approval. The UI opens the
/// [approvalUrl] (in an in-app browser), waits for the buyer to approve or
/// cancel, and returns `true` if approved. Cards never trigger this.
typedef PayPalApprovalCallback = Future<bool> Function(String approvalUrl);

/// A request to charge the guest for a reservation.
class PaymentChargeRequest {
  final double amount;
  final String currency;
  final PaymentMethodType method;

  /// Present only when [method] is [PaymentMethodType.card].
  final CardDetails? card;

  /// For traceability / idempotency on the provider side.
  final String reservationCode;

  /// Supplied by the UI for the PayPal-wallet approval round-trip. Optional —
  /// when null, a wallet payment that requires approval fails cleanly.
  final PayPalApprovalCallback? onApprovalRequired;

  const PaymentChargeRequest({
    required this.amount,
    required this.currency,
    required this.method,
    required this.reservationCode,
    this.card,
    this.onApprovalRequired,
  });
}

/// The outcome of a charge attempt.
class PaymentResult {
  /// Maps to `payments.status`: 'completed' | 'pending' | 'failed'.
  final String status;

  /// Provider transaction reference (e.g. a PayPal capture id) when available.
  final String? providerReference;

  /// Human-readable label persisted for the saved method, e.g. "•••• 4242"
  /// or "PayPal".
  final String? displayLabel;

  /// Populated when [status] == 'failed'.
  final String? errorMessage;

  const PaymentResult({
    required this.status,
    this.providerReference,
    this.displayLabel,
    this.errorMessage,
  });

  bool get isSuccess => status == 'completed' || status == 'pending';
}

abstract class PaymentGateway {
  /// Attempts to charge the guest. Implementations must not throw for ordinary
  /// decline/validation failures — return a [PaymentResult] with
  /// `status == 'failed'` instead. Throwing is reserved for unexpected errors
  /// (network/transport).
  Future<PaymentResult> charge(PaymentChargeRequest request);
}
