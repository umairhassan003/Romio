import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/payment_constants.dart';
import '../../domain/gateways/payment_gateway.dart';

/// PayPal-backed [PaymentGateway]. Both PayPal-account payments and
/// credit/debit cards are settled through the same PayPal merchant account.
///
/// The PayPal Client Secret never lives in the app. When live charging is
/// enabled this gateway calls the `paypal-charge` Supabase Edge Function, which
/// holds the credentials server-side and performs the OAuth → create order →
/// capture against PayPal. The app only ever sends/receives non-secret data.
///
/// Modes (see [PaymentConstants]):
///   * [PaymentConstants.liveChargingEnabled] == false → record-only (dev): no
///     money moves, the booking flow still completes.
///   * == true → calls the edge function and charges real money.
class PayPalPaymentGateway implements PaymentGateway {
  final Random _random;
  final SupabaseClient _supabase;

  PayPalPaymentGateway({Random? random, SupabaseClient? client})
      : _random = random ?? Random(),
        _supabase = client ?? Supabase.instance.client;

  @override
  Future<PaymentResult> charge(PaymentChargeRequest request) async {
    // Validate inputs up front for both methods.
    if (request.amount <= 0) {
      return const PaymentResult(
        status: 'failed',
        errorMessage: 'Invalid payment amount.',
      );
    }

    if (request.method == PaymentMethodType.card) {
      final card = request.card;
      if (card == null) {
        return const PaymentResult(
          status: 'failed',
          errorMessage: 'Missing card details.',
        );
      }
      final validationError = _validateCard(card);
      if (validationError != null) {
        return PaymentResult(status: 'failed', errorMessage: validationError);
      }
    }

    final displayLabel = request.method == PaymentMethodType.card
        ? request.card!.maskedLabel
        : 'PayPal · ${PaymentConstants.paypalReceiverEmail}';

    if (PaymentConstants.liveChargingEnabled) {
      // ── LIVE PATH — charge via the secure Supabase Edge Function ──
      return _chargeViaEdgeFunction(request, displayLabel);
    }

    // ── RECORD-ONLY PATH (live charging disabled) ──
    await Future<void>.delayed(const Duration(milliseconds: 600));
    debugPrint(
      '[PayPalPaymentGateway] Recorded ${request.method.providerKey} '
      'payment of ${request.amount} ${request.currency} for '
      'reservation ${request.reservationCode} (live charging disabled — '
      'deploy the paypal-charge function and flip liveChargingEnabled to go live).',
    );

    return PaymentResult(
      status: 'completed',
      providerReference: _syntheticReference(),
      displayLabel: displayLabel,
    );
  }

  /// Calls the `paypal-charge` Edge Function. Only non-secret data crosses the
  /// wire; the PayPal secret stays on the server.
  ///
  /// Card: a single `create` call captures inline → completed.
  /// PayPal wallet: `create` returns an approval URL → the UI opens it for the
  /// buyer to approve → a `capture` call finalises the payment.
  Future<PaymentResult> _chargeViaEdgeFunction(
    PaymentChargeRequest request,
    String displayLabel,
  ) async {
    try {
      final card = request.card;
      final createBody = <String, dynamic>{
        'action': 'create',
        'method': request.method.providerKey,
        'amount': request.amount.toStringAsFixed(2),
        'currency': request.currency,
        'reservation_code': request.reservationCode,
        'descriptor': PaymentConstants.statementDescriptor,
        'brand_name': PaymentConstants.brandName,
        'return_url': PaymentConstants.paypalReturnUrl,
        'cancel_url': PaymentConstants.paypalCancelUrl,
        if (request.method == PaymentMethodType.card && card != null)
          'card': {
            'number': card.sanitizedNumber,
            'expiry':
                '${card.expiryYear.toString().padLeft(4, '0')}-${card.expiryMonth.toString().padLeft(2, '0')}',
            'cvv': card.cvv,
            'name': card.holderName,
          },
      };

      final createMap = await _invoke(createBody);
      final status = createMap['status']?.toString();

      // Card path (and any inline-completed order).
      if (status == 'completed') {
        return PaymentResult(
          status: 'completed',
          providerReference: createMap['reference']?.toString(),
          displayLabel: displayLabel,
        );
      }

      // PayPal-wallet path: needs buyer approval, then capture.
      if (status == 'requires_approval') {
        final approvalUrl = createMap['approval_url']?.toString();
        final orderId = createMap['order_id']?.toString();
        final approve = request.onApprovalRequired;
        if (approvalUrl == null || orderId == null || approve == null) {
          return const PaymentResult(
            status: 'failed',
            errorMessage: 'Could not start PayPal approval.',
          );
        }

        final approved = await approve(approvalUrl);
        if (!approved) {
          return const PaymentResult(
            status: 'failed',
            errorMessage: 'Payment was cancelled.',
          );
        }

        final captureMap = await _invoke({
          'action': 'capture',
          'order_id': orderId,
        });
        if (captureMap['status']?.toString() == 'completed') {
          return PaymentResult(
            status: 'completed',
            providerReference: captureMap['reference']?.toString() ?? orderId,
            displayLabel: displayLabel,
          );
        }
        return PaymentResult(
          status: 'failed',
          errorMessage:
              captureMap['error']?.toString() ?? 'Payment was not completed.',
        );
      }

      return PaymentResult(
        status: 'failed',
        errorMessage:
            createMap['error']?.toString() ?? 'Payment was not completed.',
      );
    } on FunctionException catch (e) {
      // Non-2xx from the function (e.g. unauthenticated, function error).
      final details = e.details;
      final message = (details is Map ? details['error']?.toString() : null) ??
          'Payment service error (${e.status}).';
      debugPrint('[PayPalPaymentGateway] FunctionException: ${e.status} $details');
      return PaymentResult(status: 'failed', errorMessage: message);
    } catch (e) {
      debugPrint('[PayPalPaymentGateway] Live charge error: $e');
      return PaymentResult(status: 'failed', errorMessage: 'Payment error: $e');
    }
  }

  /// Invokes the edge function and returns its JSON body as a map.
  Future<Map<String, dynamic>> _invoke(Map<String, dynamic> body) async {
    final res = await _supabase.functions.invoke(
      PaymentConstants.paymentFunctionName,
      body: body,
    );
    final data = res.data;
    return data is Map ? data.cast<String, dynamic>() : <String, dynamic>{};
  }

  // ─── Helpers ───────────────────────────────────────────────────────────

  /// A PayPal-style 17-char uppercase alphanumeric reference for record-only
  /// mode.
  String _syntheticReference() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final buffer = StringBuffer();
    for (var i = 0; i < 17; i++) {
      buffer.write(chars[_random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  /// Returns an error string, or `null` if the card looks valid.
  String? _validateCard(CardDetails card) {
    final number = card.sanitizedNumber;
    if (number.length < 13 || number.length > 19) {
      return 'Card number must be between 13 and 19 digits.';
    }
    if (!_passesLuhn(number)) {
      return 'Invalid card number.';
    }
    if (card.holderName.trim().isEmpty) {
      return 'Cardholder name is required.';
    }
    if (card.expiryMonth < 1 || card.expiryMonth > 12) {
      return 'Invalid expiry month.';
    }
    if (card.cvv.length < 3 || card.cvv.length > 4) {
      return 'Invalid security code.';
    }
    return null;
  }

  /// Luhn checksum used by all major card networks.
  bool _passesLuhn(String number) {
    var sum = 0;
    var alternate = false;
    for (var i = number.length - 1; i >= 0; i--) {
      var digit = int.parse(number[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }
}
