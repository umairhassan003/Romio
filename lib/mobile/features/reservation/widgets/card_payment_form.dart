import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/gateways/payment_gateway.dart';

/// Inline credit/debit card entry form shown on the payment screen when the
/// "card" method is selected. Validation lives here; the resulting
/// [CardDetails] is read by the parent via the supplied [GlobalKey<FormState>]
/// + controllers. Cards are processed through PayPal (no raw PAN is stored).
class CardPaymentForm extends StatefulWidget {
  final TextEditingController numberController;
  final TextEditingController nameController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;

  const CardPaymentForm({
    super.key,
    required this.numberController,
    required this.nameController,
    required this.expiryController,
    required this.cvvController,
  });

  /// Builds a [CardDetails] from the given controllers. Returns null if the
  /// expiry field isn't in the expected MM/YY shape.
  static CardDetails? buildCardDetails({
    required TextEditingController numberController,
    required TextEditingController nameController,
    required TextEditingController expiryController,
    required TextEditingController cvvController,
  }) {
    final parts = expiryController.text.split('/');
    if (parts.length != 2) return null;
    final month = int.tryParse(parts[0].trim());
    final yy = int.tryParse(parts[1].trim());
    if (month == null || yy == null) return null;
    return CardDetails(
      number: numberController.text,
      holderName: nameController.text.trim(),
      expiryMonth: month,
      expiryYear: 2000 + yy,
      cvv: cvvController.text.trim(),
    );
  }

  @override
  State<CardPaymentForm> createState() => _CardPaymentFormState();
}

class _CardPaymentFormState extends State<CardPaymentForm> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.paymentCardDetailsTitle ?? 'Card details',
            style: AppTextStyles.labelM,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.numberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(19),
              _CardNumberFormatter(),
            ],
            decoration: InputDecoration(
              labelText: l10n?.paymentCardNumber ?? 'Card number',
              hintText: '1234 5678 9012 3456',
              prefixIcon: const Icon(Icons.credit_card),
            ),
            validator: (v) => _validateNumber(context, v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n?.paymentCardHolder ?? 'Cardholder name',
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? (l10n?.paymentCardRequired ?? 'Required')
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: widget.expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n?.paymentCardExpiry ?? 'Expiry (MM/YY)',
                    hintText: 'MM/YY',
                  ),
                  validator: (v) => _validateExpiry(context, v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: widget.cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n?.paymentCardCvv ?? 'CVV',
                    hintText: '123',
                  ),
                  validator: (v) => (v == null || v.length < 3)
                      ? (l10n?.paymentCardCvvInvalid ?? 'Invalid')
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _validateNumber(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context);
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return l10n?.paymentCardRequired ?? 'Required';
    if (digits.length < 13 || !_passesLuhn(digits)) {
      return l10n?.paymentCardNumberInvalid ?? 'Invalid card number';
    }
    return null;
  }

  String? _validateExpiry(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context);
    final text = value ?? '';
    final parts = text.split('/');
    if (parts.length != 2) {
      return l10n?.paymentCardExpiryInvalid ?? 'Invalid expiry';
    }
    final month = int.tryParse(parts[0]);
    final yy = int.tryParse(parts[1]);
    if (month == null || yy == null || month < 1 || month > 12) {
      return l10n?.paymentCardExpiryInvalid ?? 'Invalid expiry';
    }
    // Reject already-expired cards (compare against end of expiry month).
    final now = DateTime.now();
    final expiry = DateTime(2000 + yy, month + 1, 1);
    if (!expiry.isAfter(DateTime(now.year, now.month, 1))) {
      return l10n?.paymentCardExpired ?? 'Card expired';
    }
    return null;
  }

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

/// Groups card digits into blocks of four: "1234 5678 9012 3456".
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Inserts a "/" after the month: "1225" -> "12/25".
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formatted;
    if (digits.length <= 2) {
      formatted = digits;
    } else {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
