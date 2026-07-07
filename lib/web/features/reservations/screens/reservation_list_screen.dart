import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/romio_data_table.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../../domain/models/reservation.dart';
import '../providers/reservation_admin_provider.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationAdminProvider>().loadReservations();
    });
  }

  String _getPaymentBadgeStatus(Reservation r) {
    if (r.paymentProvider == 'pay_on_property') {
      return 'pay_at_property';
    } else if (r.paymentStatus == 'completed') {
      return 'paid';
    } else {
      return 'payment_pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservationAdminProvider>();
    final l = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(l.reservationManagement, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
          SegmentedButton<String?>(
            segments: [
              ButtonSegment(value: null, label: Text(l.reservationFilterAll)),
              ButtonSegment(value: 'pending', label: Text(l.reservationFilterPending)),
              ButtonSegment(value: 'confirmed', label: Text(l.reservationFilterConfirmed)),
              ButtonSegment(value: 'completed', label: Text(l.reservationFilterCompleted)),
              ButtonSegment(value: 'cancelled', label: Text(l.reservationFilterCancelled)),
            ],
            selected: {provider.filterStatus},
            onSelectionChanged: (s) => provider.setFilterStatus(s.first),
            style: ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ]),
        const SizedBox(height: 16),
        if (provider.error != null)
          ErrorBanner(message: provider.error!, onRetry: () => provider.loadReservations()),
        Card(
          child: RomioDataTable(
            columns: [
              DataColumn(label: Text(l.reservationColCode)),
              DataColumn(label: Text(l.reservationColDate)),
              DataColumn(label: Text(l.reservationColCheckIn)),
              DataColumn(label: Text(l.reservationColHours)),
              DataColumn(label: Text(l.reservationColTotal)),
              DataColumn(label: Text(l.reservationColPayment)),
              DataColumn(label: Text(l.reservationColStatus)),
              DataColumn(label: Text(l.reservationColActions)),
            ],
            rows: provider.reservations.map((r) => DataRow(cells: [
              DataCell(InkWell(
                onTap: () => context.go('/admin/reservations/${r.id}'),
                child: Text(r.reservationCode, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryBurgundy, decoration: TextDecoration.underline)),
              )),
              DataCell(Text(r.reservationDate.toString().split(' ')[0])),
              DataCell(Text(r.checkInTime)),
              DataCell(Text('${r.durationHours}h')),
              DataCell(Text('\$${r.totalPrice.toStringAsFixed(2)}')),
              DataCell(StatusBadge(status: _getPaymentBadgeStatus(r))),
              DataCell(StatusBadge(status: r.status)),
              DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.visibility, size: 18), onPressed: () => context.go('/admin/reservations/${r.id}'), tooltip: l.reservationViewDetail),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (status) => provider.updateStatus(r.id, status),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'confirmed', child: Text(l.reservationConfirm)),
                    PopupMenuItem(value: 'completed', child: Text(l.reservationComplete)),
                    PopupMenuItem(value: 'cancelled', child: Text(l.reservationCancel)),
                  ],
                ),
              ])),
            ])).toList(),
            totalCount: provider.totalCount,
            currentPage: provider.currentPage,
            pageSize: provider.pageSize,
            isLoading: provider.isLoading,
            emptyMessage: l.reservationEmptyMessage,
            emptyIcon: Icons.calendar_today_outlined,
            onPageChanged: (p) => provider.setPage(p),
          ),
        ),
      ]),
    );
  }
}
