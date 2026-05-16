import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/error_banner.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final l = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.dashboardWelcome,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  l.dashboardSummary,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          if (dash.error != null)
            ErrorBanner(
              message: dash.error!,
              onRetry: () => dash.loadDashboard(),
            ),

          // KPI Cards Row
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200
                  ? 4
                  : constraints.maxWidth > 800
                      ? 3
                      : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.0,
                children: [
                  KpiCard(
                    icon: Icons.hotel,
                    label: l.dashboardTotalHotels,
                    value: '${dash.totalHotels}',
                    isLoading: dash.isLoading,
                  ),
                  KpiCard(
                    icon: Icons.bed,
                    label: l.dashboardTotalRooms,
                    value: '${dash.totalRooms}',
                    isLoading: dash.isLoading,
                  ),
                  KpiCard(
                    icon: Icons.calendar_today,
                    label: l.dashboardTotalReservations,
                    value: '${dash.totalReservations}',
                    deltaLabel: l.dashboardRecentReservations(dash.recentReservations),
                    deltaPositive: true,
                    isLoading: dash.isLoading,
                  ),
                  KpiCard(
                    icon: Icons.attach_money,
                    label: l.dashboardTotalRevenue,
                    value: _formatCurrency(dash.totalRevenue),
                    isLoading: dash.isLoading,
                  ),
                  KpiCard(
                    icon: Icons.people,
                    label: l.dashboardRegisteredUsers,
                    value: '${dash.totalUsers}',
                    isLoading: dash.isLoading,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Quick links
          Text(
            l.dashboardQuickActions,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _QuickAction(
                icon: Icons.add_business,
                label: l.dashboardNewHotel,
                onTap: () => context.go('/admin/hotels/new'),
              ),
              _QuickAction(
                icon: Icons.add,
                label: l.dashboardNewRoom,
                onTap: () => context.go('/admin/rooms/new'),
              ),
              _QuickAction(
                icon: Icons.analytics,
                label: l.dashboardViewAnalytics,
                onTap: () => context.go('/admin/analytics'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.primaryBurgundy),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
