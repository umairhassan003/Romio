import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class PaymentScreen extends StatefulWidget {
  final String reservationId;
  const PaymentScreen({super.key, required this.reservationId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'credit_card';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      appBar: AppBar(
        title: const Text('Método de pago', style: AppTextStyles.headingM),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBurgundy),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccione un método de pago para garantizar su reserva privada.',
              style: AppTextStyles.bodyM,
            ),
            const SizedBox(height: 32),
            _buildPaymentOption('credit_card', 'Tarjeta de crédito/débito', Icons.credit_card),
            const SizedBox(height: 16),
            _buildPaymentOption('paypal', 'Paypal', Icons.paypal),
            const SizedBox(height: 16),
            _buildPaymentOption('chinchin', 'Pago Chinchin', Icons.account_balance_wallet),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24.0),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: ElevatedButton(
          onPressed: () => context.go('/confirmation'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBurgundy,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
          child: Text('Pagar y confirmar', style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary)),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primaryBurgundy : AppColors.borderLight, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBurgundy, size: 32),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.labelM)),
            Radio<String>(
              value: value,
              groupValue: _selectedMethod,
              activeColor: AppColors.primaryBurgundy,
              onChanged: (val) {
                if (val != null) setState(() => _selectedMethod = val);
              },
            )
          ],
        ),
      ),
    );
  }
}
