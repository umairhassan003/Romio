import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/reservation_flow_provider.dart';

class ReservationScreen extends StatelessWidget {
  final String roomId;
  const ReservationScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ReservationFlowProvider>();

    final times = ['14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00'];

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      appBar: AppBar(
        title: Text(l10n?.reservationTitle ?? 'Reserva', style: AppTextStyles.headingM),
        backgroundColor: Colors.transparent, elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBurgundy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Date picker
          Text(l10n?.reservationSelectDate ?? 'Seleccionar fecha', style: AppTextStyles.headingM),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(16)),
            child: CalendarDatePicker(
              initialDate: provider.selectedDate.isBefore(DateTime.now()) ? DateTime.now() : provider.selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (d) => provider.setDate(d),
            ),
          ),
          const SizedBox(height: 24),

          // Time grid
          Text(l10n?.reservationCheckInLabel ?? 'Hora de entrada', style: AppTextStyles.headingM),
          const SizedBox(height: 16),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 2.5, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: times.length,
            itemBuilder: (_, i) {
              final t = times[i];
              final sel = provider.selectedTime == t;
              return GestureDetector(
                onTap: () => provider.setTime(t),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primaryBurgundy : AppColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? AppColors.primaryBurgundy : AppColors.borderLight),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.access_time, size: 14, color: sel ? AppColors.textOnPrimary : AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(t, style: AppTextStyles.labelM.copyWith(color: sel ? AppColors.textOnPrimary : AppColors.textPrimary)),
                  ]),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Duration
          Text(l10n?.reservationDurationLabel ?? 'Duración (horas)', style: AppTextStyles.headingM),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _circleButton(Icons.remove, provider.duration > 1 ? () => provider.decrementDuration() : null),
            const SizedBox(width: 24),
            Text('${provider.duration} horas', style: AppTextStyles.headingXL),
            const SizedBox(width: 24),
            _circleButton(Icons.add, () => provider.incrementDuration()),
          ]),
          const SizedBox(height: 32),

          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('1 ${l10n?.reservationRoom ?? 'Habitación'}', style: AppTextStyles.labelM),
                Text('\$${provider.totalPrice.toStringAsFixed(0)}', style: AppTextStyles.labelM.copyWith(color: AppColors.primaryBurgundy)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(child: Text(l10n?.reservationCancelNote ?? 'Recuerda que puedes cancelar hasta 24h antes del check in sin compromiso',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary))),
              ]),
            ]),
          ),
          const SizedBox(height: 100),
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
              onPressed: () => context.push('/payment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBurgundy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: Text(l10n?.reservationContinuePayment ?? 'Continuar con el pago',
                style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback? onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(shape: BoxShape.circle, color: onTap != null ? AppColors.primaryBurgundy : AppColors.borderLight),
      child: Icon(icon, color: onTap != null ? AppColors.textOnPrimary : AppColors.textSecondary, size: 24),
    ),
  );
}
