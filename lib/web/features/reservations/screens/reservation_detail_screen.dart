import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/kpi_card.dart';
import '../providers/reservation_admin_provider.dart';

class ReservationDetailScreen extends StatefulWidget {
  final String id;
  const ReservationDetailScreen({super.key, required this.id});

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationAdminProvider>().loadReservationById(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservationAdminProvider>();
    final res = provider.selectedReservation;
    final l = AppLocalizations.of(context)!;

    if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primaryBurgundy));
    if (res == null) return Center(child: Text(provider.error ?? l.reservationNotFound));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/admin/reservations')),
          const SizedBox(width: 8),
          Expanded(child: Text('${l.adminReservationsTitle} #${res.reservationCode}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
          StatusBadge(status: res.status, fontSize: 14),
        ]),
        const SizedBox(height: 24),
        LayoutBuilder(builder: (context, constraints) {
          return GridView.count(
            crossAxisCount: constraints.maxWidth > 800 ? 4 : 2,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 2.2,
            children: [
              KpiCard(icon: Icons.calendar_today, label: l.reservationDetailDate, value: res.reservationDate.toString().split(' ')[0]),
              KpiCard(icon: Icons.access_time, label: l.reservationDetailCheckIn, value: res.checkInTime),
              KpiCard(icon: Icons.timelapse, label: l.reservationDetailDuration, value: '${res.durationHours}h'),
              KpiCard(icon: Icons.attach_money, label: l.reservationDetailTotal, value: '\$${res.totalPrice.toStringAsFixed(2)}'),
            ],
          );
        }),
        const SizedBox(height: 24),
        Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(title: l.reservationDetailDetails),
          _InfoRow(label: l.reservationDetailCode, value: res.reservationCode),
          _InfoRow(label: l.reservationDetailRoomId, value: res.roomId),
          _InfoRow(label: l.reservationDetailProfileId, value: res.profileId),
          _InfoRow(label: l.reservationDetailCheckOut, value: res.checkOutTime),
          _InfoRow(label: l.reservationDetailCreated, value: res.createdAt.toString().split('.')[0]),
          if (res.cancelledAt != null) _InfoRow(label: l.reservationDetailCancelled, value: res.cancelledAt.toString().split('.')[0]),
        ]))),
        const SizedBox(height: 16),
        // Status actions
        Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(title: l.reservationChangeStatus),
          Wrap(spacing: 12, children: [
            if (res.status != 'confirmed') ElevatedButton(onPressed: () => provider.updateStatus(res.id, 'confirmed'), child: Text(l.reservationConfirm)),
            if (res.status != 'completed') ElevatedButton(onPressed: () => provider.updateStatus(res.id, 'completed'), child: Text(l.reservationComplete)),
            if (res.status != 'cancelled') OutlinedButton(
              onPressed: () => provider.updateStatus(res.id, 'cancelled'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(l.reservationCancel),
            ),
          ]),
        ]))),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
    ]));
  }
}
