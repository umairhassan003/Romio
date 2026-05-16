import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Reserva confirmada',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingXL,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu espacio es seguro y privado.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyM,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Column(
                  children: [
                    _DetailRow(label: 'Reservation ID:', value: '#RM-4092'),
                    SizedBox(height: 12),
                    _DetailRow(label: 'Habitación:', value: 'Habitación VIP'),
                    SizedBox(height: 12),
                    _DetailRow(label: 'Check In:', value: '14:00, 12 Dic'),
                    SizedBox(height: 12),
                    _DetailRow(label: 'Check Out:', value: '17:00, 12 Dic'),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBurgundy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: Text(
                  'Volver a la página de inicio',
                  style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.labelM),
      ],
    );
  }
}
