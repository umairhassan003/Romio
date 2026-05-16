import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/supabase_analytics_repository.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/error_banner.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _revenueByHotel = [];
  List<Map<String, dynamic>> _paymentMethods = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final repo = context.read<SupabaseAnalyticsRepository>();
      _stats = await repo.getDashboardStats();
      _revenueByHotel = await repo.getRevenueByHotel();
      _paymentMethods = await repo.getPaymentMethodBreakdown();
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      _error = '${l.analyticsLoadError}: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}K';
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.analyticsPlatformTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(l.analyticsSummary, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 24),

        if (_error != null)
          ErrorBanner(message: _error!, onRetry: _loadData),

        // KPI summary
        LayoutBuilder(builder: (ctx, c) {
          final cols = c.maxWidth > 1200 ? 5 : (c.maxWidth > 800 ? 3 : 2);
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 2.0,
            children: [
              KpiCard(icon: Icons.hotel, label: l.analyticsHotels, value: '${_stats['total_hotels'] ?? 0}', isLoading: _isLoading),
              KpiCard(icon: Icons.bed, label: l.analyticsRooms, value: '${_stats['total_rooms'] ?? 0}', isLoading: _isLoading),
              KpiCard(icon: Icons.calendar_today, label: l.analyticsReservations, value: '${_stats['total_reservations'] ?? 0}', isLoading: _isLoading),
              KpiCard(icon: Icons.people, label: l.analyticsUsers, value: '${_stats['total_users'] ?? 0}', isLoading: _isLoading),
              KpiCard(icon: Icons.attach_money, label: l.analyticsRevenue, value: _formatCurrency((_stats['total_revenue'] ?? 0).toDouble()), isLoading: _isLoading),
            ],
          );
        }),
        const SizedBox(height: 32),

        // Revenue by Hotel
        if (_revenueByHotel.isNotEmpty) ...[
          SectionHeader(title: l.analyticsRevenueByHotel),
          Card(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: _revenueByHotel.map((h) {
              final name = h['hotel_name'] ?? 'Unknown';
              final revenue = (h['total_revenue'] ?? 0).toDouble();
              final maxRevenue = _revenueByHotel.isNotEmpty
                  ? _revenueByHotel.map((e) => (e['total_revenue'] ?? 0).toDouble()).reduce((a, b) => a > b ? a : b)
                  : 1.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.w500))),
                    Text(_formatCurrency(revenue), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryBurgundy)),
                  ]),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: maxRevenue > 0 ? revenue / maxRevenue : 0,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.primaryBurgundy,
                    backgroundColor: AppColors.surfaceLight,
                  ),
                ]),
              );
            }).toList()),
          )),
          const SizedBox(height: 32),
        ],

        // Payment methods breakdown
        if (_paymentMethods.isNotEmpty) ...[
          SectionHeader(title: l.analyticsPaymentMethods),
          Card(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: () {
              // Aggregate by provider
              final Map<String, double> byProvider = {};
              for (final p in _paymentMethods) {
                final provider = p['provider'] ?? 'unknown';
                byProvider[provider] = (byProvider[provider] ?? 0) + (p['amount'] as num).toDouble();
              }
              final total = byProvider.values.fold(0.0, (a, b) => a + b);
              return byProvider.entries.map((e) {
                final pct = total > 0 ? (e.value / total * 100).toStringAsFixed(1) : '0';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                      Text('$pct% (${_formatCurrency(e.value)})', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: total > 0 ? e.value / total : 0,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                      color: AppColors.primaryBurgundyLight,
                      backgroundColor: AppColors.surfaceLight,
                    ),
                  ]),
                );
              }).toList();
            }()),
          )),
        ],
      ]),
    );
  }
}
