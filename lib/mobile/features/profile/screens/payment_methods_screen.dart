import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Displays the saved payment method (card or empty state) with options
/// to delete and add new methods (PayPal or card).
class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  // Holds whichever saved card mock is shown.  In production this would come
  // from a Supabase query; for now we show a placeholder that disappears after
  // the user deletes it.
  bool _hasCard = true;

  void _confirmDeleteCard(AppLocalizations? l10n) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      _deleteCard(l10n);
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

  void _deleteCard(AppLocalizations? l10n) {
    setState(() => _hasCard = false);
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => _CardDeletedOverlay(l10n: l10n),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                l10n?.profilePaymentMethod ?? 'Método de pago',
                style: AppTextStyles.headingL,
              ),
            ),
            const SizedBox(height: 24),
            if (_hasCard) ...[
              _CardWidget(),
              const SizedBox(height: 24),
              const Divider(color: AppColors.borderLight),
              const SizedBox(height: 16),

              // Ajustes section
              Text(
                l10n?.paymentMethodAjustes ?? 'Ajustes',
                style: AppTextStyles.headingS,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _confirmDeleteCard(l10n),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n?.paymentMethodDeleteCard ?? 'Eliminar su tarjeta',
                    style: AppTextStyles.labelM.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _DataStorageLink(l10n: l10n),
            ] else ...[
              // No card saved – show payment options
              Text(
                l10n?.paymentMethodOther ?? 'Otros tipos de pago',
                style: AppTextStyles.headingS,
              ),
              const SizedBox(height: 16),
              _PaymentOption(
                logo: _PaypalLogo(),
                title: 'Paypal',
                subtitle: l10n?.paymentPaypalInfo ??
                    'Serás redirigido al sitio de PayPal. Una vez realizada la transacción, volverás a nuestro sitio web para finalizar la reserva.',
                onTap: () {},
              ),
              const Divider(color: AppColors.borderLight),
              _PaymentOption(
                logo: const Icon(
                  Icons.credit_card,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
                title: l10n?.paymentMethodAddCard ?? 'Agregar método de pago',
                subtitle: null,
                onTap: () => context.push('/profile/add-card'),
                showArrow: true,
              ),
              const SizedBox(height: 24),
              _DataStorageLink(l10n: l10n),
            ],
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
  @override
  Widget build(BuildContext context) {
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
          // Brand logo area
          Row(
            children: [
              _VisaLogo(),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Ana López',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Visa - XXXX6789',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 2),
          const Text(
            'Exp... 04/30',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Logos ────────────────────────────────────────────────────────────────────

class _VisaLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'VISA',
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        letterSpacing: 2,
      ),
    );
  }
}

class _PaypalLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'PayPal',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF003087),
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
              const Icon(
                Icons.chevron_right,
                color: AppColors.primaryBurgundy,
              ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, size: 14, color: AppColors.info),
          const SizedBox(width: 6),
          Text(
            l10n?.paymentMethodDataStorage ??
                'Conocer  más sobre el almacenamiento de datos',
            style: AppTextStyles.bodyS.copyWith(color: AppColors.info),
          ),
        ],
      ),
    );
  }
}

// ─── Card deleted success overlay ────────────────────────────────────────────

class _CardDeletedOverlay extends StatelessWidget {
  final AppLocalizations? l10n;
  const _CardDeletedOverlay({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
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
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 52),
              ),
              const SizedBox(height: 24),
              Text(
                l10n?.cardDeletedTitle ?? 'Tarjeta eliminada',
                style: AppTextStyles.headingXL,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.cardDeletedBadgeTitle ?? 'Tarjeta eliminada',
                            style: AppTextStyles.labelM,
                          ),
                          Text(
                            l10n?.cardDeletedBadgeBody ??
                                'Has eliminado tu tarjeta',
                            style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Volver al menú principal',
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
}
