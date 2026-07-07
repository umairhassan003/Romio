import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/reservation_flow_provider.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<ReservationFlowProvider>();
    final reservation = provider.confirmedReservation;

    final code = reservation?.reservationCode ?? '#RM-0000';
    final roomName = provider.roomName ?? reservation?.roomName ?? 'Habitación';
    final checkIn = reservation?.checkInTime ?? provider.selectedTime;
    final checkOut = reservation?.checkOutTime ?? provider.checkOutTime;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Green check
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                l10n?.confirmationTitle ?? 'Reserva confirmada',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingXL,
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.confirmationSubtitle ?? 'Tu espacio es seguro y privado.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
              ),
              if (reservation?.paymentProvider == 'pay_on_property') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.store_mall_directory_outlined, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n?.confirmationPayOnProperty ?? 'Pagarás en la propiedad al llegar.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (reservation?.paymentStatus == 'completed') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n?.paymentStatusPaid ?? 'Pagado',
                          style: AppTextStyles.caption.copyWith(color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 48),

              // Details card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(children: [
                  _row(l10n?.confirmationIdLabel ?? 'Reservation ID', '#$code'),
                  const Divider(height: 24, color: AppColors.borderLight),
                  _row(l10n?.confirmationRoomLabel ?? 'Habitación', roomName),
                  const SizedBox(height: 12),
                  _row('Check In', checkIn),
                  const SizedBox(height: 12),
                  _row('Check Out', checkOut),
                ]),
              ),
              const Spacer(),

              // Go home button
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    provider.resetFlow();
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(
                    l10n?.confirmationGoHome ?? 'Volver a la página de inicio',
                    style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
      Text(value, style: AppTextStyles.labelM),
    ],
  );
}
