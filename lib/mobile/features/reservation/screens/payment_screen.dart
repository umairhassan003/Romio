import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/card_brand.dart';
import '../../../../domain/gateways/payment_gateway.dart';
import '../providers/reservation_flow_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../payment/models/saved_card.dart';
import '../../payment/providers/card_wallet_provider.dart';
import '../../payment/widgets/card_brand_logo.dart';
import '../../payment/screens/add_card_screen.dart';
import '../widgets/paypal_approval_screen.dart';

enum _PayMode { card, paypal }

/// Checkout payment screen. Shows the reservation total, the guest's saved
/// (in-memory) cards to pay from, a PayPal option, and an "add method" action.
/// The CVV is collected here (never on save), and a real charge runs through
/// [ReservationFlowProvider.confirmAndPay]; the booking is created only on
/// success.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cvvCtrl = TextEditingController();
  _PayMode _mode = _PayMode.card;
  bool _acceptedTerms = false;
  bool _initialised = false;

  // Tap handlers for the bold links inside the terms text (kept as fields so
  // they can be disposed).
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  /// The reserve button is only enabled once a payment method is ready. When
  /// paying by card the CVV must be entered; PayPal has no such requirement.
  bool get _canConfirm =>
      _mode != _PayMode.card || _cvvCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _termsRecognizer =
        TapGestureRecognizer()..onTap = () => context.push('/profile/terms');
    _privacyRecognizer =
        TapGestureRecognizer()
          ..onTap = () => context.push('/profile/privacy-policy');
  }

  @override
  void dispose() {
    _cvvCtrl.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  /// Builds the terms-acceptance sentence with "Terms and Conditions" and
  /// "Privacy Policy" rendered bold + tappable (links to their pages). The link
  /// phrases are matched inside the localized sentence so it stays translatable.
  Widget _buildTermsText(AppLocalizations? l10n) {
    final full =
        l10n?.paymentTermsAccept ??
        'He leído y acepto los Términos y Condiciones y las Políticas de Privacidad.';
    final termsLabel = l10n?.termsLinkLabel ?? 'Términos y Condiciones';
    final privacyLabel = l10n?.privacyLinkLabel ?? 'Políticas de Privacidad';

    final base = AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary);
    final linkStyle = base.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    );

    final links = <(int, String, TapGestureRecognizer)>[];
    final ti = full.indexOf(termsLabel);
    if (ti >= 0) links.add((ti, termsLabel, _termsRecognizer));
    final pi = full.indexOf(privacyLabel);
    if (pi >= 0) links.add((pi, privacyLabel, _privacyRecognizer));
    links.sort((a, b) => a.$1.compareTo(b.$1));

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final (start, label, recognizer) in links) {
      if (start > cursor) {
        spans.add(TextSpan(text: full.substring(cursor, start), style: base));
      }
      spans.add(
        TextSpan(text: label, style: linkStyle, recognizer: recognizer),
      );
      cursor = start + label.length;
    }
    if (cursor < full.length) {
      spans.add(TextSpan(text: full.substring(cursor), style: base));
    }

    return Text.rich(TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ReservationFlowProvider>();
    final wallet = context.watch<CardWalletProvider>();

    // Default to card when the guest has one saved, else PayPal.
    if (!_initialised) {
      _mode = wallet.hasCards ? _PayMode.card : _PayMode.paypal;
      _initialised = true;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 160),
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => context.pop(),
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
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    l10n?.paymentSummaryTitle ?? 'Resumen de reserva',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingXL.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          _bookingSummary(context, provider, l10n),
          const SizedBox(height: 8),
          const Divider(
            color: AppColors.textSecondary,
            thickness: 3,
            height: 32,
          ),
          const SizedBox(height: 8),

          Text(
            l10n?.paymentInfoTitle ?? 'Información de pago',
            style: AppTextStyles.headingS,
          ),
          const SizedBox(height: 24),

          // ── Saved cards ──────────────────────────────────────────
          for (final card in wallet.cards)
            _savedCardTile(context, wallet, card, l10n),

          const SizedBox(height: 20),
          Text(
            l10n?.paymentMethodOther ?? 'Otros tipos de pago',
            style: AppTextStyles.headingS,
          ),
          const SizedBox(height: 8),

          // ── PayPal ───────────────────────────────────────────────
          _optionTile(
            selected: _mode == _PayMode.paypal,
            onTap: () => setState(() => _mode = _PayMode.paypal),
            leading: const SizedBox(width: 40, child: PaypalLogo()),
            title: 'PayPal',
            subtitle:
                l10n?.paymentPaypalInfo ??
                'Serás redirigido al sitio de PayPal para completar el pago de forma segura.',
          ),
          const Divider(color: AppColors.textSecondary, height: 1),

          // ── Choose / add another payment method ──────────────────
          InkWell(
            onTap: _addCard,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.add, color: AppColors.textPrimary, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n?.paymentChooseOtherMethod ??
                          'Elegir otro método de pago',
                      style: AppTextStyles.labelM.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Accepted brands ──────────────────────────────────────
          const Center(child: AcceptedBrandsRow()),
          const SizedBox(height: 16),

          // ── Terms & conditions ───────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _acceptedTerms,
                  activeColor: AppColors.primaryBurgundy,
                  onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildTermsText(l10n)),
            ],
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  (provider.isLoading || !_acceptedTerms || !_canConfirm)
                      ? null
                      : () => _onConfirm(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBurgundy,
                disabledBackgroundColor: AppColors.primaryBurgundy.withValues(
                  alpha: 0.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child:
                  provider.isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Text(
                        l10n?.paymentReserveButton ?? 'Reservar',
                        style: AppTextStyles.labelM.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }

  /// The "Resumen de reserva" card: room, the reservation fee (charged now),
  /// and the split between what's paid now and what's settled at the hotel.
  Widget _bookingSummary(
    BuildContext context,
    ReservationFlowProvider provider,
    AppLocalizations? l10n,
  ) {
    final payAtHotel = provider.balanceDueAtProperty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.confirmationRoomLabel ?? 'Habitación',
          style: AppTextStyles.headingS,
        ),
        const SizedBox(height: 4),
        Text(
          provider.roomName ?? '',
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 24),

        // ── Line items ──────────────────────────────────────────────
        _summaryRow(label: '1 ${l10n?.reservationRoom ?? 'Habitación'}'),
        const SizedBox(height: 10),
        _summaryRow(
          label: l10n?.summaryReservationFee ?? 'Tasa de reserva',
          value: _money(provider.amountDueNow),
        ),
        const Divider(color: AppColors.textSecondary, height: 32),

        // ── Payment split ───────────────────────────────────────────
        if (payAtHotel > 0) ...[
          _summaryRow(
            label: l10n?.summaryPayAtHotel ?? 'En el hotel pagas',
            value: _money(payAtHotel),
          ),
          const SizedBox(height: 10),
        ],
        _summaryRow(
          label: l10n?.summaryPayNow ?? 'Ahora solo pagas',
          value: _money(provider.amountDueNow),
        ),
        const SizedBox(height: 12),
        _summaryRow(
          label: (l10n?.paymentTotalLabel ?? 'Total').toUpperCase(),
          value: _money(provider.totalPrice),
          emphasize: true,
        ),
        const SizedBox(height: 16),
        Text(
          l10n?.summaryVatIncluded ??
              'El IVA está ya incluido en nuestros precios',
          style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _summaryRow({
    required String label,
    String? value,
    bool emphasize = false,
  }) {
    final style =
        emphasize
            ? AppTextStyles.labelM.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            )
            : AppTextStyles.bodyM.copyWith(color: AppColors.textPrimary);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        if (value != null) Text(value, style: style),
      ],
    );
  }

  /// Formats an amount to match the mockup: trailing zeros trimmed, comma
  /// decimal separator, currency symbol as a suffix (e.g. 53.2 -> "53,2$").
  String _money(double amount) {
    var s = amount.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '');
      s = s.replaceAll(RegExp(r'\.$'), '');
    }
    return '${s.replaceAll('.', ',')}\$';
  }

  /// A selectable saved card. Tapping selects it; the active card reveals the
  /// CVV ("CSV") field below (the CVV is required only at pay time). Styled to
  /// match the booking mockup: brand logo, "MC-0000" title, masked number +
  /// expiry, then a divider and the CSV field with its helper text.
  Widget _savedCardTile(
    BuildContext context,
    CardWalletProvider wallet,
    SavedCard card,
    AppLocalizations? l10n,
  ) {
    final isActive = _mode == _PayMode.card && wallet.selected?.id == card.id;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        wallet.select(card.id);
        setState(() => _mode = _PayMode.card);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 56,
                child: CardBrandLogo(brand: card.brand, height: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cardTitle(card),
                      style: AppTextStyles.headingS.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _cardMaskedLine(card),
                      style: AppTextStyles.bodyM.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.textSecondary, height: 32),
          if (isActive) ...[
            Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    l10n?.paymentCardCvv ?? 'CSV',
                    style: AppTextStyles.headingS.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _cvvCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    style: AppTextStyles.bodyM,
                    // Rebuild so the reserve button enables/disables as the CVV
                    // is typed or cleared.
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      isDense: true,
                      counterText: '',
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      hintText: l10n?.paymentCvvRequiredHint ?? 'Obligatorio',
                      hintStyle: AppTextStyles.bodyM.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.paymentCvvSectionHelp ??
                  'Para usar una tarjeta de pago, escriba su código de verificación de tres dígitos visible en el reverso de la tarjeta',
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  /// Short card identifier shown as the tile title, e.g. "MC-0000".
  String _cardTitle(SavedCard card) {
    final short =
        card.brand == CardBrand.mastercard
            ? 'MC'
            : card.brand == CardBrand.visa
            ? 'VISA'
            : 'CARD';
    return '$short-${card.last4}';
  }

  /// Masked number + expiry, e.g. "***********0000 - 1/2031".
  String _cardMaskedLine(SavedCard card) {
    final len = card.sanitizedNumber.length;
    final hidden = len > 4 ? len - 4 : 11;
    return '${'*' * hidden}${card.last4} - ${card.expMonth}/${card.expYear}';
  }

  Widget _optionTile({
    required bool selected,
    required VoidCallback onTap,
    required Widget leading,
    required String title,
    String? subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelM),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: selected,
              activeColor: AppColors.primaryBurgundy,
              onChanged: (_) => onTap(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCard() async {
    // Present the add-card form as a modal bottom sheet (slides up on this
    // screen) instead of navigating to a separate page.
    final card = await showModalBottomSheet<SavedCard>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddCardScreen(isBottomSheet: true),
    );
    if (card != null && mounted) {
      setState(() => _mode = _PayMode.card);
    }
  }

  Future<void> _onConfirm(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<ReservationFlowProvider>();
    final wallet = context.read<CardWalletProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final profileId = profileProvider.profile?.id;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.paymentProfileError ?? 'Error: perfil no cargado',
          ),
        ),
      );
      return;
    }

    CardDetails? card;
    if (_mode == _PayMode.card) {
      final selected = wallet.selected;
      if (selected == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.paymentSelectCardError ?? 'Selecciona una tarjeta',
            ),
          ),
        );
        return;
      }
      final cvv = _cvvCtrl.text.trim();
      if (cvv.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.paymentCardCvvInvalid ?? 'Código de seguridad inválido',
            ),
          ),
        );
        return;
      }
      provider.setPaymentMethod(PaymentMethodType.card.providerKey);
      card = selected.toCardDetails(cvv);
    } else {
      provider.setPaymentMethod(PaymentMethodType.paypal.providerKey);
    }

    final profile = profileProvider.profile;
    final clientEmail = context.read<AuthProvider>().user?.email ?? '';
    final clientName =
        [profile?.firstName, profile?.lastName]
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .join(' ')
            .trim();

    final success = await provider.confirmAndPay(
      profileId,
      clientEmail: clientEmail,
      clientName: clientName,
      card: card,
      onApprovalRequired:
          (approvalUrl) => _openPaypalApproval(context, approvalUrl),
    );

    if (success && context.mounted) {
      context.go('/confirmation');
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ??
                (l10n?.paymentGenericError ?? 'Error al confirmar'),
          ),
        ),
      );
    }
  }

  Future<bool> _openPaypalApproval(
    BuildContext context,
    String approvalUrl,
  ) async {
    final approved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PayPalApprovalScreen(approvalUrl: approvalUrl),
      ),
    );
    return approved ?? false;
  }
}
