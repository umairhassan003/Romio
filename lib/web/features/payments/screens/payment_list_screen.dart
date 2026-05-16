import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/romio_data_table.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/error_banner.dart';
import '../providers/payment_admin_provider.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentAdminProvider>().loadPayments();
    });
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}K';
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentAdminProvider>();
    final l = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(l.paymentManagement, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
          SegmentedButton<String?>(
            segments: [
              ButtonSegment(value: null, label: Text(l.paymentFilterAll)),
              ButtonSegment(value: 'completed', label: Text(l.paymentFilterCompleted)),
              ButtonSegment(value: 'pending', label: Text(l.paymentFilterPending)),
              ButtonSegment(value: 'failed', label: Text(l.paymentFilterFailed)),
              ButtonSegment(value: 'refunded', label: Text(l.paymentFilterRefunded)),
            ],
            selected: {provider.filterStatus},
            onSelectionChanged: (s) => provider.setFilterStatus(s.first),
            style: ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ]),
        const SizedBox(height: 16),

        // Summary bar
        LayoutBuilder(builder: (ctx, constraints) {
          return GridView.count(
            crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 2.5,
            children: [
              KpiCard(icon: Icons.check_circle, label: l.paymentCollected, value: _formatCurrency(provider.totalCollected), isLoading: provider.isLoading),
              KpiCard(icon: Icons.pending, label: l.paymentPending, value: _formatCurrency(provider.totalPending), isLoading: provider.isLoading),
              KpiCard(icon: Icons.undo, label: l.paymentRefundedLabel, value: _formatCurrency(provider.totalRefunded), isLoading: provider.isLoading),
            ],
          );
        }),
        const SizedBox(height: 16),

        if (provider.error != null)
          ErrorBanner(message: provider.error!, onRetry: () => provider.loadPayments()),

        Card(
          child: RomioDataTable(
            columns: [
              DataColumn(label: Text(l.paymentColId)),
              DataColumn(label: Text(l.paymentColAmount)),
              DataColumn(label: Text(l.paymentColProvider)),
              DataColumn(label: Text(l.paymentColStatus)),
              DataColumn(label: Text(l.paymentColDate)),
              DataColumn(label: Text(l.paymentColActions)),
            ],
            rows: provider.payments.map((p) => DataRow(cells: [
              DataCell(InkWell(
                onTap: () => context.go('/admin/payments/${p.id}'),
                child: Text(p.id.substring(0, 8), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryBurgundy, decoration: TextDecoration.underline)),
              )),
              DataCell(Text('\$${p.amount.toStringAsFixed(2)}')),
              DataCell(Text(p.provider.isEmpty ? 'N/A' : p.provider)),
              DataCell(StatusBadge(status: p.status)),
              DataCell(Text(p.paidAt?.toString().split('.')[0] ?? '—')),
              DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.visibility, size: 18), onPressed: () => context.go('/admin/payments/${p.id}')),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (status) => provider.updatePaymentStatus(p.id, status),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'completed', child: Text(l.paymentMarkCompleted)),
                    PopupMenuItem(value: 'refunded', child: Text(l.paymentRefund)),
                    PopupMenuItem(value: 'failed', child: Text(l.paymentMarkFailed)),
                  ],
                ),
              ])),
            ])).toList(),
            totalCount: provider.totalCount,
            currentPage: provider.currentPage,
            pageSize: provider.pageSize,
            isLoading: provider.isLoading,
            emptyMessage: l.paymentEmptyMessage,
            emptyIcon: Icons.payment_outlined,
            onPageChanged: (p) => provider.setPage(p),
          ),
        ),
      ]),
    );
  }
}
