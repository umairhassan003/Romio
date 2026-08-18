import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../data/services/notification_service.dart';
import '../../profile/providers/profile_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../providers/reservation_flow_provider.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    // Raise the booking-confirmed notification once, right after this screen
    // is reached from any of the booking flows (pay online / pay at property).
    WidgetsBinding.instance.addPostFrameCallback((_) => _raiseNotification());
  }

  /// Adds the confirmed-booking entry to the in-app notification center and
  /// pops a device notification, both in the app's selected language. Fully
  /// best-effort: any failure here must not disturb the confirmation screen.
  void _raiseNotification() {
    if (!mounted) return;
    final provider = context.read<ReservationFlowProvider>();
    final reservation = provider.confirmedReservation;
    final profile = context.read<ProfileProvider>().profile;
    if (reservation == null || profile == null) return;

    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    final code = reservation.reservationCode;
    final hotel = (provider.hotelName?.isNotEmpty == true
            ? provider.hotelName
            : reservation.hotelName) ??
        provider.roomName ??
        reservation.roomName ??
        '';
    final room = provider.roomName ?? reservation.roomName ?? '';
    final checkIn = reservation.checkInTime;
    final dateStr =
        DateFormat.yMMMMd(localeCode).format(reservation.reservationDate);

    // In-app notification (persisted, re-localized when read).
    context.read<NotificationsProvider>().addBookingConfirmed(
          userId: profile.id,
          code: code,
          hotelName: hotel,
          roomName: room,
          reservationDateIso: reservation.reservationDate.toIso8601String(),
          checkInTime: checkIn,
        );

    // Device notification in the current language.
    final title =
        l10n?.notificationBookingConfirmedTitle ?? 'Booking confirmed';
    final body = l10n?.notificationBookingConfirmedBody(
          code,
          hotel,
          dateStr,
          checkIn,
        ) ??
        'Your reservation $code at $hotel is confirmed for $dateStr at $checkIn.';
    NotificationService.instance.show(
      id: code.hashCode & 0x7fffffff,
      title: title,
      body: body,
    );
  }

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
                    if (provider.isPayPartial) ...[
                      const Divider(height: 24, color: AppColors.borderLight),
                      _row(
                        l10n?.paymentDepositNowLabel ?? 'Depósito pagado',
                        '\$${(reservation?.depositAmount ?? provider.amountDueNow).toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      _row(
                        l10n?.paymentBalanceAtPropertyLabel ??
                            'A pagar en la propiedad',
                        '\$${(reservation?.balanceDue ?? provider.balanceDueAtProperty).toStringAsFixed(2)}',
                      ),
                    ] else if (provider.isPayAtProperty) ...[
                      const Divider(height: 24, color: AppColors.borderLight),
                      _row(
                        l10n?.paymentBalanceAtPropertyLabel ??
                            'A pagar en la propiedad',
                        '\$${(reservation?.totalPrice ?? provider.totalPrice).toStringAsFixed(2)}',
                      ),
                    ],
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
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Flexible(
        child: Text(
          label,
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: AppTextStyles.labelM.copyWith(
            color: isId ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
      ),
    ],
  );
}
