import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/card_brand.dart';
import '../../payment/models/saved_card.dart';
import '../../payment/providers/card_wallet_provider.dart';
import '../../payment/widgets/card_brand_logo.dart';
import '../../../widgets/success_sheet.dart';

/// Displays the guest's saved cards (from the in-memory [CardWalletProvider])
/// with options to delete them and add new ones. When no card is saved it shows
/// the "other payment types" state (PayPal + add card).
class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wallet = context.watch<CardWalletProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  l10n?.profilePaymentMethodTitle ?? 'Método de pago',
                  style: AppTextStyles.headingL,
                ),
              ),
              const SizedBox(height: 24),

              if (wallet.hasCards)
                ..._buildSavedCards(context, l10n, wallet)
              else
                ..._buildEmptyState(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSavedCards(
    BuildContext context,
    AppLocalizations? l10n,
    CardWalletProvider wallet,
  ) {
    return [
      for (final card in wallet.cards) ...[
        _CardWidget(card: card),
        const SizedBox(height: 16),
      ],
      const SizedBox(height: 8),
      const Divider(color: AppColors.borderLight),
      const SizedBox(height: 16),

      // Ajustes section — one delete action per saved card.
      Text(
        l10n?.paymentMethodAjustes ?? 'Ajustes',
        style: AppTextStyles.headingS,
      ),
      const SizedBox(height: 12),
      for (final card in wallet.cards) ...[
        GestureDetector(
          onTap: () => _confirmDeleteCard(context, l10n, card),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              wallet.cards.length > 1
                  ? '${l10n?.paymentMethodDeleteCard ?? 'Eliminar su tarjeta'} · ${card.maskedLabel}'
                  : l10n?.paymentMethodDeleteCard ?? 'Eliminar su tarjeta',
              style: AppTextStyles.labelM.copyWith(color: AppColors.error),
            ),
          ),
        ),
      ],
      const SizedBox(height: 8),

      // Add another card
      GestureDetector(
        onTap: () => context.push('/profile/add-payment-method'),
        child: Row(
          children: [
            const Icon(Icons.add, color: AppColors.primaryBurgundy, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n?.paymentMethodAddCard ?? 'Agregar método de pago',
              style: AppTextStyles.labelM.copyWith(
                color: AppColors.primaryBurgundy,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _DataStorageLink(l10n: l10n),
    ];
  }

  List<Widget> _buildEmptyState(BuildContext context, AppLocalizations? l10n) {
    return [
      const Divider(color: AppColors.borderLight),
      _PaymentOption(
        logo: const Icon(
          Icons.credit_card,
          color: AppColors.textSecondary,
          size: 28,
        ),
        title: l10n?.paymentMethodAddCard ?? 'Agregar método de pago',
        subtitle: null,
        onTap: () => context.push('/profile/add-payment-method'),
        showArrow: true,
      ),
      const SizedBox(height: 24),
      _DataStorageLink(l10n: l10n),
    ];
  }

  void _confirmDeleteCard(
    BuildContext context,
    AppLocalizations? l10n,
    SavedCard card,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    l10n?.deleteCardConfirmTitle ??
                        '¿Estás seguro que quiere eliminar su tarjeta?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingS,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _dialogBtn(
                        label: l10n?.confirmSI ?? 'SI',
                        onTap: () {
                          Navigator.pop(ctx);
                          context.read<CardWalletProvider>().removeCard(
                            card.id,
                          );
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder:
                                (_) => SuccessSheet(
                                  title:
                                      l10n?.cardDeletedTitle ??
                                      'Tarjeta eliminada',
                                  badgeTitle:
                                      l10n?.cardDeletedBadgeTitle ??
                                      'Tarjeta eliminada',
                                  badgeBody:
                                      l10n?.cardDeletedBadgeBody ??
                                      'Has eliminado tu tarjeta',
                                  buttonLabel:
                                      l10n?.cardReturnMainMenu ??
                                      'Volver al menú principal',
                                ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      _dialogBtn(
                        label: l10n?.confirmNO ?? 'NO',
                        onTap: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _dialogBtn({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: 110,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBurgundy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelM.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

// ─── Dark card widget ─────────────────────────────────────────────────────────

class _CardWidget extends StatelessWidget {
  final SavedCard card;
  const _CardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Brand mark in white for contrast on the burgundy card.
    final Widget brandMark =
        card.brand == CardBrand.visa
            ? const VisaLogo(color: Colors.white, plain: true)
            : card.brand == CardBrand.mastercard
            ? const MastercardLogo()
            : const Icon(Icons.credit_card, color: Colors.white);

    final brandName =
        card.brand == CardBrand.visa
            ? 'Visa'
            : card.brand == CardBrand.mastercard
            ? 'Mastercard'
            : (l10n?.cardGenericLabel ?? 'Tarjeta');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryBurgundy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [brandMark]),
          const SizedBox(height: 64),
          if (card.holderName.isNotEmpty) ...[
            Text(
              card.holderName.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            '$brandName - XXXX${card.last4}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            '${l10n?.cardExpiryShort ?? 'Exp...'} ${card.expiryLabel}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Payment option row ───────────────────────────────────────────────────────

class _PaymentOption extends StatelessWidget {
  final Widget logo;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showArrow;

  const _PaymentOption({
    required this.logo,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 36, child: logo),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelM),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            subtitle!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              const Icon(Icons.chevron_right, color: AppColors.primaryBurgundy),
          ],
        ),
      ),
    );
  }
}

// ─── Data storage info link ───────────────────────────────────────────────────

class _DataStorageLink extends StatelessWidget {
  final AppLocalizations? l10n;
  const _DataStorageLink({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.push('/profile/data-storage'),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 14, color: AppColors.info),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                l10n?.paymentMethodDataStorage ??
                    'Conocer  más sobre el almacenamiento de datos',
                style: AppTextStyles.bodyS.copyWith(color: AppColors.info),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
