import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/payment_constants.dart';
import '../../../../domain/gateways/payment_gateway.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/reservation_flow_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../widgets/card_payment_form.dart';
import '../widgets/paypal_approval_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _cardExpiryCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ReservationFlowProvider>();
    final cardKey = PaymentMethodType.card.providerKey;
    final paypalKey = PaymentMethodType.paypal.providerKey;
    final isCard = provider.selectedPaymentMethod == cardKey;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: Text(l10n?.paymentTitle ?? 'Método de pago', style: AppTextStyles.headingM),
        backgroundColor: Colors.transparent, elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBurgundy),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
          children: [
            Text(
              l10n?.paymentSubtitle ?? 'Seleccione un método de pago para\ngarantizar su reserva privada.',
              style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Total summary
            _totalRow(context, provider, l10n),
            const SizedBox(height: 24),

            _paymentOption(context, provider, cardKey,
                l10n?.paymentMethodCardOption ?? 'Tarjeta de crédito/débito', Icons.credit_card),
            if (isCard) ...[
              const SizedBox(height: 12),
              CardPaymentForm(
                numberController: _cardNumberCtrl,
                nameController: _cardNameCtrl,
                expiryController: _cardExpiryCtrl,
                cvvController: _cardCvvCtrl,
              ),
            ],
            const SizedBox(height: 16),
            _paymentOption(context, provider, paypalKey, 'PayPal', Icons.paypal),
            if (!isCard) ...[
              const SizedBox(height: 12),
              _paypalInfo(context, l10n),
            ],
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24), width: double.infinity,
        decoration: const BoxDecoration(color: AppColors.backgroundWhite,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: provider.isLoading ? null : () => _onConfirm(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBurgundy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: provider.isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('${l10n?.paymentConfirmBtn ?? 'Pagar y confirmar'} · \$${provider.totalPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _totalRow(BuildContext context, ReservationFlowProvider provider, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(16),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l10n?.paymentTotalLabel ?? 'Total', style: AppTextStyles.labelM),
        Text('\$${provider.totalPrice.toStringAsFixed(2)} ${PaymentConstants.currency}',
            style: AppTextStyles.headingS.copyWith(color: AppColors.primaryBurgundy)),
      ]),
    );
  }

  Widget _paypalInfo(BuildContext context, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            l10n?.paymentPaypalInfo ??
                'Serás dirigido a PayPal para completar el pago de forma segura.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ]),
    );
  }

  Future<void> _onConfirm(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<ReservationFlowProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final profileId = profileProvider.profile?.id;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.paymentProfileError ?? 'Error: perfil no cargado')));
      return;
    }

    CardDetails? card;
    if (provider.selectedPaymentMethod == PaymentMethodType.card.providerKey) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      card = CardPaymentForm.buildCardDetails(
        numberController: _cardNumberCtrl,
        nameController: _cardNameCtrl,
        expiryController: _cardExpiryCtrl,
        cvvController: _cardCvvCtrl,
      );
    }

    final success = await provider.confirmAndPay(
      profileId,
      card: card,
      onApprovalRequired: (approvalUrl) => _openPaypalApproval(context, approvalUrl),
    );
    if (success && context.mounted) {
      context.go('/confirmation');
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? (l10n?.paymentGenericError ?? 'Error al confirmar'))));
    }
  }

  /// Opens PayPal's approval page in an in-app browser and resolves to whether
  /// the buyer approved. Used as the [PayPalApprovalCallback] for wallet flows.
  Future<bool> _openPaypalApproval(BuildContext context, String approvalUrl) async {
    final approved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PayPalApprovalScreen(approvalUrl: approvalUrl),
      ),
    );
    return approved ?? false;
  }

  Widget _paymentOption(BuildContext context, ReservationFlowProvider provider, String value, String title, IconData icon) {
    final sel = provider.selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => provider.setPaymentMethod(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? AppColors.primaryBurgundy : AppColors.borderLight, width: 2),
        ),
        child: Row(children: [
          Icon(icon, color: sel ? AppColors.primaryBurgundy : AppColors.textSecondary, size: 28),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: AppTextStyles.labelM)),
          Radio<String>(
            value: value, groupValue: provider.selectedPaymentMethod,
            activeColor: AppColors.primaryBurgundy,
            onChanged: (v) { if (v != null) provider.setPaymentMethod(v); },
          ),
        ]),
      ),
    );
  }
}
