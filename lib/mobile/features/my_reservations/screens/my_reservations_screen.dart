import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/my_reservations_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../../domain/models/reservation.dart';
import 'package:intl/intl.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});
  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>().profile;
      if (profile != null) {
        context.read<MyReservationsProvider>().loadUserReservations(profile.id);
      } else {
        final user = context.read<AuthProvider>().user;
        if (user != null) {
          // Load profile first, then reservations
          context.read<ProfileProvider>().loadProfile(user.id).then((_) {
            final p = context.read<ProfileProvider>().profile;
            if (p != null) context.read<MyReservationsProvider>().loadUserReservations(p.id);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<MyReservationsProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      appBar: AppBar(
        title: Text(l10n?.myReservationTitle ?? 'Mi Reserva', style: AppTextStyles.headingM),
        backgroundColor: Colors.transparent, elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBurgundy),
          onPressed: () {},
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBurgundy))
          : provider.upcomingReservations.isEmpty
              ? _emptyState(l10n)
              : _reservationsList(context, provider, l10n),
    );
  }

  Widget _emptyState(AppLocalizations? l10n) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.event_busy, size: 80, color: AppColors.textSecondary.withOpacity(0.5)),
      const SizedBox(height: 24),
      Text(l10n?.reservationEmptyTitle ?? 'Nada planeado', style: AppTextStyles.headingM),
      const SizedBox(height: 8),
      Text(l10n?.reservationEmptyBody ?? 'No tiene ninguna reserva próxima',
        style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
    ]),
  );

  Widget _reservationsList(BuildContext context, MyReservationsProvider provider, AppLocalizations? l10n) {
    final reservations = provider.upcomingReservations;
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: reservations.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(l10n?.reservationUpcoming ?? 'Próximamente', style: AppTextStyles.headingS),
          );
        }
        return _ReservationCard(
          reservation: reservations[i - 1],
          provider: provider,
        );
      },
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final MyReservationsProvider provider;
  const _ReservationCard({required this.reservation, required this.provider});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMMM', 'es').format(reservation.reservationDate);
    final timeStr = reservation.checkInTime;
    final roomName = reservation.roomName ?? 'Habitación';
    final hotelName = reservation.hotelName ?? 'Hotel';
    final hotelAddr = reservation.hotelAddress ?? '';
    final reminderOn = provider.isReminderEnabled(reservation.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Top row: date/time + reminder toggle
        Row(children: [
          const Icon(Icons.calendar_today, size: 16, color: AppColors.primaryBurgundy),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dateStr, style: AppTextStyles.labelM),
            Text(timeStr, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Recuérdamelo', style: AppTextStyles.caption.copyWith(color: AppColors.primaryBurgundy)),
            Text(roomName, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          ]),
          const SizedBox(width: 4),
          Switch(
            value: reminderOn,
            activeColor: AppColors.primaryBurgundy,
            onChanged: (v) => provider.toggleReminder(reservation.id, v),
          ),
        ]),
        const Divider(height: 24, color: AppColors.borderLight),
        // Bottom: hotel info + check in/out
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(hotelName, style: AppTextStyles.labelM),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 2),
              Expanded(child: Text(hotelAddr, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Check In', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            Text(reservation.checkInTime, style: AppTextStyles.labelM),
          ]),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Check Out', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            Text(reservation.checkOutTime, style: AppTextStyles.labelM),
          ]),
        ]),
      ]),
    );
  }
}
