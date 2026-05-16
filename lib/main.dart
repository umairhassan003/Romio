import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_constants.dart';
import 'core/router/app_router.dart';

// Repositories
import 'data/repositories/supabase_auth_repository.dart';
import 'data/repositories/supabase_profile_repository.dart';
import 'data/repositories/supabase_hotel_repository.dart';
import 'data/repositories/supabase_room_repository.dart';
import 'data/repositories/supabase_reservation_repository.dart';

// Feature Providers
import 'mobile/features/auth/providers/auth_provider.dart';
import 'mobile/features/profile/providers/profile_provider.dart';
import 'mobile/features/home/providers/home_provider.dart';
import 'mobile/features/my_reservations/providers/my_reservations_provider.dart';
import 'mobile/features/reservation/providers/reservation_flow_provider.dart';

/* 
 * Romio - Hotel Booking App
 */

import 'package:flutter/foundation.dart' show kIsWeb;
import 'web/core/providers/web_providers.dart';
import 'web/app_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  if (kIsWeb) {
    runApp(
      MultiProvider(
        providers: webProviders,
        child: const RomioAdminApp(),
      ),
    );
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Inject Repositories
        Provider(create: (_) => SupabaseAuthRepository()),
        Provider(create: (_) => SupabaseProfileRepository()),
        Provider(create: (_) => SupabaseHotelRepository()),
        Provider(create: (_) => SupabaseRoomRepository()),
        Provider(create: (_) => SupabaseReservationRepository()),

        // Inject Feature Providers (State Management)
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authRepository: context.read<SupabaseAuthRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(
            profileRepository: context.read<SupabaseProfileRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeProvider(
            hotelRepository: context.read<SupabaseHotelRepository>(),
            roomRepository: context.read<SupabaseRoomRepository>(),
          )..loadHotels(),
        ),
        // MyReservations needs the user profile ID to load, so it could optionally be ProxyProvider.
        // For simplicity now, we initialize it and components will call `.loadUserReservations(id)`.
        ChangeNotifierProvider(
          create: (context) => MyReservationsProvider(
            reservationRepository: context.read<SupabaseReservationRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ReservationFlowProvider(
            reservationRepository: context.read<SupabaseReservationRepository>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Romio',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
