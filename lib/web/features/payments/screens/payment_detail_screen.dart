import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/kpi_card.dart';
import '../providers/payment_admin_provider.dart';

class PaymentDetailScreen extends StatefulWidget {
  final String id;
  const PaymentDetailScreen({super.key, required this.id});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentAdminProvider>().loadPaymentById(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentAdminProvider>();
    final payment = provider.selectedPayment;
    final l = AppLocalizations.of(context)!;

    if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primaryBurgundy));
    if (payment == null) return Center(child: Text(provider.error ?? l.paymentNotFound));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/admin/payments')),
          const SizedBox(width: 8),
          Expanded(child: Text('${l.adminPaymentsTitle} #${payment.id.substring(0, 8)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
          StatusBadge(status: payment.status, fontSize: 14),
        ]),
        const SizedBox(height: 24),
        LayoutBuilder(builder: (ctx, constraints) {
          return GridView.count(
            crossAxisCount: constraints.maxWidth > 800 ? 3 : 2,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 2.2,
            children: [
              KpiCard(icon: Icons.attach_money, label: l.paymentDetailAmount, value: '\$${payment.amount.toStringAsFixed(2)}'),
              KpiCard(icon: Icons.storefront, label: l.paymentDetailProvider, value: payment.provider),
              KpiCard(icon: Icons.monetization_on, label: l.paymentDetailCurrency, value: payment.currency),
            ],
          );
        }),
        const SizedBox(height: 24),
        Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(title: l.paymentDetailTitle),
          _InfoRow(label: l.paymentDetailReservationId, value: payment.reservationId),
          if (payment.paymentMethodId != null) _InfoRow(label: l.paymentDetailMethod, value: payment.paymentMethodId!),
          if (payment.providerReference != null) _InfoRow(label: l.paymentDetailProviderRef, value: payment.providerReference!),
          if (payment.paidAt != null) _InfoRow(label: l.paymentDetailDate, value: payment.paidAt.toString().split('.')[0]),
        ]))),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(title: l.paymentDetailActions),
          Wrap(spacing: 12, children: [
            if (payment.status != 'completed') ElevatedButton(onPressed: () => provider.updatePaymentStatus(payment.id, 'completed'), child: Text(l.paymentMarkCompletedBtn)),
            if (payment.status == 'completed') OutlinedButton(onPressed: () => provider.updatePaymentStatus(payment.id, 'refunded'), child: Text(l.paymentRefundBtn)),
            if (payment.status != 'failed') OutlinedButton(
              onPressed: () => provider.updatePaymentStatus(payment.id, 'failed'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(l.paymentMarkFailedBtn),
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
      SizedBox(width: 140, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
    ]));
  }
}
