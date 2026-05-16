import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../data/repositories/supabase_analytics_repository.dart';
import '../../../data/repositories/supabase_hotel_repository.dart';
import '../../../data/repositories/supabase_room_repository.dart';
import '../../../data/repositories/supabase_reservation_repository.dart';
import '../../features/auth/providers/admin_auth_provider.dart';
import '../../features/dashboard/providers/dashboard_provider.dart';
import '../../features/hotels/providers/hotel_admin_provider.dart';
import '../../features/rooms/providers/room_admin_provider.dart';
import '../../features/reservations/providers/reservation_admin_provider.dart';
import '../../features/payments/providers/payment_admin_provider.dart';
import '../../features/users/providers/user_admin_provider.dart';

final List<SingleChildWidget> webProviders = [
  // Auth
  ChangeNotifierProvider(create: (_) => AdminAuthProvider()),

  // Repositories as Providers
  Provider(create: (_) => SupabaseAnalyticsRepository()),
  Provider(create: (_) => SupabaseHotelRepository()),
  Provider(create: (_) => SupabaseRoomRepository()),
  Provider(create: (_) => SupabaseReservationRepository()),

  // Feature Providers
  ChangeNotifierProvider(
    create: (ctx) => DashboardProvider(
      analyticsRepo: ctx.read<SupabaseAnalyticsRepository>(),
    ),
  ),
  ChangeNotifierProvider(
    create: (ctx) => HotelAdminProvider(
      repo: ctx.read<SupabaseHotelRepository>(),
    ),
  ),
  ChangeNotifierProvider(
    create: (ctx) => RoomAdminProvider(
      repo: ctx.read<SupabaseRoomRepository>(),
    ),
  ),
  ChangeNotifierProvider(
    create: (ctx) => ReservationAdminProvider(
      repo: ctx.read<SupabaseReservationRepository>(),
    ),
  ),
  ChangeNotifierProvider(create: (_) => PaymentAdminProvider()),
  ChangeNotifierProvider(create: (_) => UserAdminProvider()),
];
