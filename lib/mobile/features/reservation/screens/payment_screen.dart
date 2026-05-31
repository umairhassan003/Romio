import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/reservation_flow_provider.dart';
import '../../profile/providers/profile_provider.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ReservationFlowProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      appBar: AppBar(
        title: Text(l10n?.paymentTitle ?? 'Método de pago', style: AppTextStyles.headingM),
        backgroundColor: Colors.transparent, elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBurgundy),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            l10n?.paymentSubtitle ?? 'Seleccione un método de pago para\ngarantizar su reserva privada.',
            style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          _paymentOption(context, provider, 'credit_card',
            l10n?.paymentMethodCardOption ?? 'Tarjeta de crédito/débito', Icons.credit_card),
          const SizedBox(height: 16),
          _paymentOption(context, provider, 'paypal', 'Paypal', Icons.paypal),
          const SizedBox(height: 16),
          _paymentOption(context, provider, 'chinchin',
            l10n?.paymentChinchin ?? 'Pago Chinchin', Icons.account_balance_wallet),
        ]),
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
                  : Text(l10n?.paymentConfirmBtn ?? 'Pagar y confirmar',
                      style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm(BuildContext context) async {
    final provider = context.read<ReservationFlowProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final profileId = profileProvider.profile?.id;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: perfil no cargado')));
      return;
    }
    final success = await provider.confirmAndPay(profileId);
    if (success && context.mounted) {
      context.go('/confirmation');
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? 'Error al confirmar')));
    }
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
