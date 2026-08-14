import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/card_brand.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/saved_card.dart';
import '../providers/card_wallet_provider.dart';
import '../widgets/card_brand_logo.dart';

/// "Añadir tarjeta" — collects a card (number, expiry, billing country) and
/// adds it to the in-memory [CardWalletProvider]. Per product rules the CVV is
/// NOT collected here (only at pay time), and nothing is written to Supabase.
class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();

  CardBrand _brand = CardBrand.unknown;
  String _country = 'Venezuela';

  @override
  void initState() {
    super.initState();
    _numberCtrl.addListener(() {
      final b = detectCardBrand(_numberCtrl.text);
      if (b != _brand) setState(() => _brand = b);
    });
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back,
                        color: AppColors.primaryBurgundy, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  l10n?.addCardTitle ?? 'Añadir tarjeta',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingXL.copyWith(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 24),

              // ── Card information ──────────────────────────────────
              Text(
                l10n?.addCardInfoSection ?? 'Información de la tarjeta',
                style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              _fieldCard(
                child: Column(
                  children: [
                    // Card number + live brand row
                    TextFormField(
                      controller: _numberCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(19),
                        _CardNumberFormatter(),
                      ],
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: l10n?.paymentCardNumber ?? 'Número de tarjeta',
                        hintStyle: AppTextStyles.bodyM
                            .copyWith(color: AppColors.textTertiary),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: AcceptedBrandsRow(
                            highlight: _brand == CardBrand.unknown ? null : _brand,
                          ),
                        ),
                        suffixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                      validator: _validateNumber,
                    ),
                    const Divider(height: 1, color: AppColors.borderLight),
                    const SizedBox(height: 4),
                    // Expiry (no CVC on save — collected only at pay time)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              _ExpiryFormatter(),
                            ],
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: l10n?.addCardExpiryHint ?? 'MM/AA',
                              hintStyle: AppTextStyles.bodyM
                                  .copyWith(color: AppColors.textTertiary),
                            ),
                            validator: _validateExpiry,
                          ),
                        ),
                        const Icon(Icons.credit_card,
                            color: AppColors.textSecondary, size: 22),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Billing address ──────────────────────────────────
              Text(
                l10n?.addCardBillingSection ?? 'Dirección de facturación',
                style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              _fieldCard(
                child: InkWell(
                  onTap: _pickCountry,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.addCardCountryLabel ?? 'País o región',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(_country, style: AppTextStyles.labelM),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                l10n?.addCardDisclaimer ??
                    'Al facilitarnos los datos de la tarjeta, permites que Romio '
                        'cargue en tu tarjeta futuros pagos conforme a las condiciones estipuladas.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n?.addCardConfirm ?? 'Confirmar',
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

  Widget _fieldCard({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderField),
        ),
        child: child,
      );

  String? _validateNumber(String? value) {
    final l10n = AppLocalizations.of(context);
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

  String? _validateExpiry(String? value) {
    final l10n = AppLocalizations.of(context);
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

  Future<void> _pickCountry() async {
    const countries = [
      'Venezuela', 'Colombia', 'México', 'Argentina', 'Chile', 'Perú',
      'España', 'Estados Unidos', 'Ecuador', 'Panamá',
    ];
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n?.countryPickerTitle ?? 'País o región',
                  style: AppTextStyles.headingS),
            ),
            const Divider(height: 1, color: AppColors.borderLight),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final c in countries)
                    ListTile(
                      title: Text(c, style: AppTextStyles.bodyM),
                      trailing: c == _country
                          ? const Icon(Icons.check,
                              color: AppColors.primaryBurgundy, size: 20)
                          : null,
                      onTap: () => Navigator.pop(ctx, c),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _country = picked);
  }

  void _onConfirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final parts = _expiryCtrl.text.split('/');
    final month = int.parse(parts[0].trim());
    final yy = int.parse(parts[1].trim());

    final profile = context.read<ProfileProvider>().profile;
    final holder = [profile?.firstName, profile?.lastName]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(' ')
        .trim();

    final SavedCard card = context.read<CardWalletProvider>().addCard(
          number: _numberCtrl.text,
          holderName: holder,
          expMonth: month,
          expYear: 2000 + yy,
          billingCountry: _country,
        );

    context.pop(card);
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
      TextEditingValue oldValue, TextEditingValue newValue) {
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
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final formatted = digits.length <= 2
        ? digits
        : '${digits.substring(0, 2)}/${digits.substring(2)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
