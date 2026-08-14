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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    provider.resetFlow();
                    context.go('/home');
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

              // Green check circle
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 52),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                l10n?.confirmationTitle ?? 'Reserva confirmada',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingXL,
              ),

              const SizedBox(height: 48),

              // Details card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _row(
                      'Reservation ID',
                      '#${code.replaceAll('#', '')}',
                      isId: true,
                    ),
                    const Divider(height: 24, color: AppColors.borderLight),
                    _row(
                      l10n?.confirmationRoomLabel ?? 'Habitación',
                      roomName,
                    ),
                    const SizedBox(height: 12),
                    _row('Check In', checkIn),
                    const SizedBox(height: 12),
                    _row('Check Out', checkOut),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Notification banner
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
                            l10n?.confirmationNotificationTitle ??
                                'Reserva confirmada',
                            style: AppTextStyles.labelM,
                          ),
                          Text(
                            l10n?.confirmationNotificationBody ??
                                'Tienes una reserva activa',
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

              // Primary button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    provider.resetFlow();
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n?.confirmationViewReservation ?? 'Ver mi reservacion',
                    style: AppTextStyles.labelM.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isId = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
      ),
      Text(
        value,
        style: AppTextStyles.labelM.copyWith(
          color: isId ? AppColors.textSecondary : AppColors.textPrimary,
        ),
      ),
    ],
  );
}
