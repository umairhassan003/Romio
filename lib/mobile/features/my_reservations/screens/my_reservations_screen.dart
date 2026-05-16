import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/my_reservations_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../../domain/models/reservation.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  bool _reminderEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<MyReservationsProvider>().loadUserReservations(auth.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reservationProvider = context.watch<MyReservationsProvider>();
    final auth = context.watch<AuthProvider>();
    
    final bool hasReservations = reservationProvider.reservations.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      appBar: AppBar(
        title: const Text('Mi Reserva', style: AppTextStyles.headingM),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: auth.user == null || reservationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (hasReservations ? _buildReservationsList(reservationProvider.reservations) : _buildEmptyState()),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 24),
          const Text('Nada planeado', style: AppTextStyles.headingM),
          const SizedBox(height: 8),
          Text(
            'No tiene ninguna reserva próxima',
            style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList(List<Reservation> reservations) {
    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final res = reservations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${res.reservationDate.day}/${res.reservationDate.month}/${res.reservationDate.year}', 
                      style: AppTextStyles.labelM
                    ),
                    Row(
                      children: [
                        Text('Recuérdamelo', style: AppTextStyles.bodyS.copyWith(color: AppColors.primaryBurgundy)),
                        Switch(
                          value: _reminderEnabled,
                          activeColor: AppColors.primaryBurgundy,
                          onChanged: (val) => setState(() => _reminderEnabled = val),
                        ),
                      ],
                    )
                  ],
                ),
                const Divider(color: AppColors.borderLight, height: 24),
                // Normally we map the hotel name by joining models, we assume room_id is valid
                const Text('Hotel Ejemplo (ID)', style: AppTextStyles.headingS),
                const SizedBox(height: 4),
                Text('Habitación: ${res.roomId}', style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Text('Status: ${res.status}', style: AppTextStyles.labelM.copyWith(color: AppColors.primaryBurgundy)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Check In', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          Text(res.checkInTime, style: AppTextStyles.labelM),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Check Out', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          Text(res.checkOutTime, style: AppTextStyles.labelM),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
