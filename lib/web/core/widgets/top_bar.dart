import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../features/auth/providers/admin_auth_provider.dart';
import '../../app_web.dart';

class TopBar extends StatelessWidget {
  final VoidCallback? onToggleSidebar;

  const TopBar({super.key, this.onToggleSidebar});

  String _getPageTitle(BuildContext context, String path) {
    final l = AppLocalizations.of(context)!;
    if (path.startsWith('/admin/dashboard')) return l.adminDashboardTitle;
    if (path.startsWith('/admin/hotels/new')) return l.topBarNewHotel;
    if (path.contains('/edit')) return l.topBarEditHotel;
    if (path.startsWith('/admin/hotels/')) return l.topBarHotelDetail;
    if (path.startsWith('/admin/hotels')) return l.adminHotelsTitle;
    if (path.startsWith('/admin/rooms/new')) return l.topBarNewRoom;
    if (path.startsWith('/admin/rooms')) return l.adminRoomsTitle;
    if (path.startsWith('/admin/amenities')) return l.adminAmenitiesTitle;
    if (path.startsWith('/admin/reservations/')) return l.topBarReservationDetail;
    if (path.startsWith('/admin/reservations')) return l.adminReservationsTitle;
    if (path.startsWith('/admin/payments/')) return l.topBarPaymentDetail;
    if (path.startsWith('/admin/payments')) return l.adminPaymentsTitle;
    if (path.startsWith('/admin/users/')) return l.topBarUserProfile;
    if (path.startsWith('/admin/users')) return l.adminUsersTitle;
    if (path.startsWith('/admin/analytics')) return l.adminAnalyticsTitle;
    if (path.startsWith('/admin/settings')) return l.adminSettingsTitle;
    return l.topBarAdmin;
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final appState = context.watch<RomioAdminAppState>();
    final l = AppLocalizations.of(context)!;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          if (onToggleSidebar != null)
            IconButton(
              icon: const Icon(Icons.menu, size: 20),
              onPressed: onToggleSidebar,
            ),
          Text(
            _getPageTitle(context, currentPath),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),

          // Language toggle
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'es', label: Text('ES', style: TextStyle(fontSize: 12))),
              ButtonSegment(value: 'en', label: Text('EN', style: TextStyle(fontSize: 12))),
            ],
            selected: {appState.locale.languageCode},
            onSelectionChanged: (selected) {
              appState.setLocale(Locale(selected.first));
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),

          // Theme toggle
          IconButton(
            icon: Icon(
              appState.themeMode == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              size: 20,
            ),
            onPressed: appState.toggleTheme,
            tooltip: l.topBarChangeTheme,
          ),
          const SizedBox(width: 4),

          // Logout
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () {
              context.read<AdminAuthProvider>().signOut();
              context.go('/admin/login');
            },
            tooltip: l.topBarLogout,
          ),
        ],
      ),
    );
  }
}
