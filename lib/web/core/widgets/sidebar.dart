import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../features/auth/providers/admin_auth_provider.dart';

class Sidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const Sidebar({
    super.key,
    this.isCollapsed = false,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthProvider>();
    final currentPath = GoRouterState.of(context).matchedLocation;
    final l = AppLocalizations.of(context)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? 72 : 240,
      color: AppColors.adminSidebarBg,
      child: Column(
        children: [
          // Logo area
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 12 : 20),
            alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
            child: isCollapsed
                ? const Text('R', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
                : SvgPicture.asset(
                    'images/RomioLogo.svg',
                    height: 26,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
          ),
          const Divider(color: Color(0xFF4A3245), height: 1),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavItem(icon: Icons.dashboard_outlined, label: l.sidebarDashboard, path: '/admin/dashboard', currentPath: currentPath, isCollapsed: isCollapsed),
                _NavItem(icon: Icons.hotel_outlined, label: l.sidebarHotels, path: '/admin/hotels', currentPath: currentPath, isCollapsed: isCollapsed),
                _NavItem(icon: Icons.bed_outlined, label: l.sidebarRooms, path: '/admin/rooms', currentPath: currentPath, isCollapsed: isCollapsed),
                _NavItem(icon: Icons.wifi_outlined, label: l.sidebarAmenities, path: '/admin/amenities', currentPath: currentPath, isCollapsed: isCollapsed),
                _NavItem(icon: Icons.calendar_today_outlined, label: l.sidebarReservations, path: '/admin/reservations', currentPath: currentPath, isCollapsed: isCollapsed),
                _NavItem(icon: Icons.payment_outlined, label: l.sidebarPayments, path: '/admin/payments', currentPath: currentPath, isCollapsed: isCollapsed),
                _NavItem(icon: Icons.people_outlined, label: l.sidebarUsers, path: '/admin/users', currentPath: currentPath, isCollapsed: isCollapsed),
                _NavItem(icon: Icons.analytics_outlined, label: l.sidebarAnalytics, path: '/admin/analytics', currentPath: currentPath, isCollapsed: isCollapsed),
                if (auth.isSuperAdmin)
                  _NavItem(icon: Icons.settings_outlined, label: l.sidebarSettings, path: '/admin/settings', currentPath: currentPath, isCollapsed: isCollapsed),
              ],
            ),
          ),

          // Admin user info
          const Divider(color: Color(0xFF4A3245), height: 1),
          Padding(
            padding: EdgeInsets.all(isCollapsed ? 12 : 16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryBurgundy,
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.isSuperAdmin ? l.adminRoleSuperAdmin : l.adminRoleHotelManager,
                          style: const TextStyle(color: AppColors.adminSidebarText, fontSize: 12, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          auth.currentAdmin?.role ?? '',
                          style: TextStyle(color: AppColors.adminSidebarText.withValues(alpha: 0.6), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final String currentPath;
  final bool isCollapsed;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.currentPath,
    required this.isCollapsed,
  });

  bool get isActive => currentPath.startsWith(path);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 12, vertical: 2),
      child: Material(
        color: isActive ? AppColors.adminSidebarActive : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go(path),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 12,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? Colors.white : AppColors.adminSidebarText,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.adminSidebarText,
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
