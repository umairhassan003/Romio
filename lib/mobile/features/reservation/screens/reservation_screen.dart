import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/reservation_flow_provider.dart';
import '../../profile/providers/profile_provider.dart';

class ReservationScreen extends StatelessWidget {
  final String roomId;
  const ReservationScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ReservationFlowProvider>();

    final times = provider.availableTimes;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
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
            decoration: BoxDecoration(color: AppColors.backgroundPink, borderRadius: BorderRadius.circular(16)),
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
                    color: sel ? AppColors.primaryBurgundy : AppColors.backgroundPink,
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

          // Duration slots — only show slots configured by the hotel admin
          Text(l10n?.reservationDurationLabel ?? 'Duración', style: AppTextStyles.headingM),
          const SizedBox(height: 16),
          Builder(builder: (ctx) {
            final slots = provider.availableSlots;
            if (slots.isEmpty) {
              return Text(
                'No hay opciones de reserva disponibles.',
                style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
              );
            }
            return Row(
              children: [
                for (int i = 0; i < slots.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: _slotCard(ctx, provider, slots[i])),
                ],
              ],
            );
          }),
          const SizedBox(height: 32),

          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.backgroundPink, borderRadius: BorderRadius.circular(16)),
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
              if (provider.payOnProperty) ...[
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.store_mall_directory_outlined, size: 14, color: AppColors.success),
                  const SizedBox(width: 6),
                  Expanded(child: Text(
                    l10n?.reservationPayOnPropertyNote ?? 'Este hotel permite pagar en la propiedad. No se requiere pago por adelantado.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.success))),
                ]),
              ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (provider.payOnProperty) ...[
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : () => context.push('/payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBurgundy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: Text(
                      l10n?.payOnlineOption ?? 'Pagar en línea',
                      style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton(
                    onPressed: provider.isLoading ? null : () => _reserveOnProperty(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBurgundy,
                      side: const BorderSide(color: AppColors.primaryBurgundy, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBurgundy))
                        : Text(
                            l10n?.payOnPropertyOption ?? 'Pagar en la propiedad',
                            style: AppTextStyles.labelM.copyWith(color: AppColors.primaryBurgundy),
                          ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : () => context.push('/payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBurgundy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(
                            l10n?.reservationContinuePayment ?? 'Continuar con el pago',
                            style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _reserveOnProperty(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<ReservationFlowProvider>();
    final profileId = context.read<ProfileProvider>().profile?.id;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.paymentProfileError ?? 'Error: perfil no cargado')));
      return;
    }
    final success = await provider.reserveOnProperty(profileId);
    if (success && context.mounted) {
      context.go('/confirmation');
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? (l10n?.paymentGenericError ?? 'Error al confirmar'))));
    }
  }

  Widget _slotCard(BuildContext context, ReservationFlowProvider provider, int hours) {
    final sel = provider.duration == hours;
    return GestureDetector(
      onTap: () => provider.selectSlot(hours),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: sel ? AppColors.primaryBurgundy : AppColors.backgroundPink,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? AppColors.primaryBurgundy : AppColors.borderLight),
        ),
        child: Column(children: [
          Text('${hours}h',
            style: AppTextStyles.headingS.copyWith(color: sel ? AppColors.textOnPrimary : AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('\$${provider.priceForSlot(hours).toStringAsFixed(0)}',
            style: AppTextStyles.labelM.copyWith(color: sel ? AppColors.textOnPrimary : AppColors.primaryBurgundy)),
        ]),
      ),
    );
  }
}
