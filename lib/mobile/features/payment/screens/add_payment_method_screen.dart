import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/card_brand.dart';
import '../providers/card_wallet_provider.dart';

/// "Añadir una forma de pago" — the full-screen add-card form used from the
/// Profile → payment methods flow. Collects the card number, cardholder name,
/// expiry and an optional nickname, then saves the card to
/// [CardWalletProvider]. (The checkout flow uses the lighter bottom-sheet form;
/// this screen additionally captures the cardholder name and nickname.)
class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  final _holderCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();

  @override
  void dispose() {
    _numberCtrl.dispose();
    _holderCtrl.dispose();
    _expiryCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryBurgundy,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n?.addPaymentMethodTitle ?? 'Añadir una forma de pago',
                style: AppTextStyles.headingXL.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Card number + card icon box
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _field(
                        label: l10n?.paymentCardNumber ?? 'Número de tarjeta',
                        controller: _numberCtrl,
                        hint: '0000 0000 0000 0000',
                        keyboardType: TextInputType.number,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(19),
                          _CardNumberFormatter(),
                        ],
                        validator: (v) => _validateNumber(l10n, v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'images/creditcard.png',
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Cardholder name
              _field(
                label: l10n?.cardHolderLabel ?? 'Titular de la tarjeta',
                controller: _holderCtrl,
                hint: 'Hanna Reyes',
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? (l10n?.paymentCardRequired ?? 'Requerido')
                            : null,
              ),
              const SizedBox(height: 12),

              // Expiry
              _field(
                label: l10n?.cardExpiryLabel ?? 'Fecha de caducidad',
                controller: _expiryCtrl,
                hint: l10n?.addCardExpiryHint ?? 'MM/AA',
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryFormatter(),
                ],
                validator: (v) => _validateExpiry(l10n, v),
              ),
              const SizedBox(height: 12),

              // Optional nickname
              _field(
                label: l10n?.cardNicknameLabel ?? 'Nombre de la tarjeta',
                controller: _nicknameCtrl,
                hint: l10n?.cardNicknameHint ?? 'Opcional',
                formatters: [
                  LengthLimitingTextInputFormatter(25),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.cardNicknameHelper ??
                    'Letras o números y 25 caracteres máximo.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 36),

              // Data storage link
              Center(
                child: GestureDetector(
                  onTap: () => context.push('/profile/data-storage'),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info, size: 14, color: AppColors.info),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n?.paymentMethodDataStorage ??
                              'Conocer  más sobre el almacenamiento de datos',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyS.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n?.addCardButton ?? 'Añadir tarjeta',
                    style: AppTextStyles.labelM.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A filled grey field with a small label above the input (design style).
  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    List<TextInputFormatter>? formatters,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            inputFormatters: formatters,
            validator: validator,
            style: AppTextStyles.bodyM.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              hintText: hint,
              hintStyle: AppTextStyles.bodyM.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateNumber(AppLocalizations? l10n, String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return l10n?.paymentCardRequired ?? 'Requerido';
    if (digits.length < 13 || !_passesLuhn(digits)) {
      return l10n?.paymentCardNumberInvalid ?? 'Número de tarjeta inválido';
    }
    if (!detectCardBrand(digits).isSupported) {
      return l10n?.cardUnsupportedBrand ?? 'Solo se aceptan Visa y Mastercard';
    }
    return null;
  }

  String? _validateExpiry(AppLocalizations? l10n, String? value) {
    final parts = (value ?? '').split('/');
    if (parts.length != 2) {
      return l10n?.paymentCardExpiryInvalid ?? 'Fecha inválida';
    }
    final month = int.tryParse(parts[0]);
    final yy = int.tryParse(parts[1]);
    if (month == null || yy == null || month < 1 || month > 12) {
      return l10n?.paymentCardExpiryInvalid ?? 'Fecha inválida';
    }
    final now = DateTime.now();
    final expiry = DateTime(2000 + yy, month + 1, 1);
    if (!expiry.isAfter(DateTime(now.year, now.month, 1))) {
      return l10n?.paymentCardExpired ?? 'Tarjeta vencida';
    }
    return null;
  }

  void _onConfirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final parts = _expiryCtrl.text.split('/');
    final month = int.parse(parts[0].trim());
    final yy = int.parse(parts[1].trim());
    final nickname = _nicknameCtrl.text.trim();

    context.read<CardWalletProvider>().addCard(
      number: _numberCtrl.text,
      holderName: _holderCtrl.text.trim(),
      expMonth: month,
      expYear: 2000 + yy,
      label: nickname.isEmpty ? null : nickname,
    );

    Navigator.of(context).pop();
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
    final formatted =
        digits.length <= 2
            ? digits
            : '${digits.substring(0, 2)}/${digits.substring(2)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
