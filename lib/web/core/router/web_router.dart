import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/admin_auth_provider.dart';
import '../../features/auth/screens/admin_login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/hotels/screens/hotel_list_screen.dart';
import '../../features/hotels/screens/hotel_form_screen.dart';
import '../../features/hotels/screens/hotel_detail_screen.dart';
import '../../features/rooms/screens/room_list_screen.dart';
import '../../features/rooms/screens/room_form_screen.dart';
import '../../features/rooms/screens/room_detail_screen.dart';
import '../../features/amenities/screens/amenity_list_screen.dart';
import '../../features/reservations/screens/reservation_list_screen.dart';
import '../../features/reservations/screens/reservation_detail_screen.dart';
import '../../features/payments/screens/payment_list_screen.dart';
import '../../features/payments/screens/payment_detail_screen.dart';
import '../../features/users/screens/user_list_screen.dart';
import '../../features/users/screens/user_detail_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../widgets/admin_scaffold.dart';

final webRouter = GoRouter(
  initialLocation: '/admin/login',
  redirect: (context, state) async {
    final authProvider = context.read<AdminAuthProvider>();
    final isLoginRoute = state.matchedLocation == '/admin/login';

    if (authProvider.isCheckingAuth && !isLoginRoute) {
      await authProvider.checkSession();
    }

    final isLoggedIn = authProvider.isAuthenticated;

    if (!isLoggedIn && !isLoginRoute) return '/admin/login';
    if (isLoggedIn && isLoginRoute) return '/admin/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/admin/login',
      builder: (_, __) => const AdminLoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AdminScaffold(child: child),
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          builder: (_, __) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/admin/hotels',
          builder: (_, __) => const HotelListScreen(),
        ),
        GoRoute(
          path: '/admin/hotels/new',
          builder: (_, __) => const HotelFormScreen(),
        ),
        GoRoute(
          path: '/admin/hotels/:id',
          builder: (_, s) => HotelDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/admin/hotels/:id/edit',
          builder: (_, s) => HotelFormScreen(hotelId: s.pathParameters['id']),
        ),
        GoRoute(
          path: '/admin/rooms',
          builder: (_, __) => const RoomListScreen(),
        ),
        GoRoute(
          path: '/admin/rooms/new',
          builder: (_, __) => const RoomFormScreen(),
        ),
        GoRoute(
          path: '/admin/rooms/:id/edit',
          builder: (_, s) => RoomFormScreen(roomId: s.pathParameters['id']),
        ),
        GoRoute(
          path: '/admin/rooms/:id',
          builder: (_, s) => RoomDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/admin/amenities',
          builder: (_, __) => const AmenityListScreen(),
        ),
        GoRoute(
          path: '/admin/reservations',
          builder: (_, __) => const ReservationListScreen(),
        ),
        GoRoute(
          path: '/admin/reservations/:id',
          builder: (_, s) => ReservationDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/admin/payments',
          builder: (_, __) => const PaymentListScreen(),
        ),
        GoRoute(
          path: '/admin/payments/:id',
          builder: (_, s) => PaymentDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/admin/users',
          builder: (_, __) => const UserListScreen(),
        ),
        GoRoute(
          path: '/admin/users/:id',
          builder: (_, s) => UserDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/admin/analytics',
          builder: (_, __) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: '/admin/settings',
          redirect: (ctx, _) {
            final auth = ctx.read<AdminAuthProvider>();
            if (!auth.isSuperAdmin) return '/admin/dashboard';
            return null;
          },
          builder: (_, __) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
