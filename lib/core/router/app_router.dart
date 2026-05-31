
import 'package:go_router/go_router.dart';

import '../../mobile/features/onboarding/screens/splash_screen.dart';
import '../../mobile/features/onboarding/screens/onboarding_screen.dart';
import '../../mobile/features/auth/screens/login_screen.dart';
import '../../mobile/features/auth/screens/signup_screen.dart';
import '../../mobile/features/home/screens/hotel_detail_screen.dart';
import '../../mobile/features/home/screens/room_detail_screen.dart';
import '../../mobile/features/reservation/screens/reservation_screen.dart';
import '../../mobile/features/reservation/screens/payment_screen.dart';
import '../../mobile/features/reservation/screens/confirmation_screen.dart';
import '../../mobile/features/profile/screens/personal_info_screen.dart';
import '../../mobile/features/profile/screens/payment_methods_screen.dart';
import '../../mobile/features/profile/screens/language_screen.dart';
import '../../mobile/features/offline/screens/offline_state_screen.dart';
import '../../mobile/widgets/main_tab_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Pre-auth routes ──────────────────────────────────────────
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),

    // ── Main tab shell (Home / Reservations / Profile) ───────────
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainTabShell(),
    ),

    // ── Detail / flow screens (pushed on top of tabs) ────────────
    GoRoute(
      path: '/hotel/:hotelId',
      builder: (context, state) => HotelDetailScreen(
        hotelId: state.pathParameters['hotelId']!,
      ),
    ),
    GoRoute(
      path: '/hotel/:hotelId/room/:roomId',
      builder: (context, state) => RoomDetailScreen(
        hotelId: state.pathParameters['hotelId']!,
        roomId: state.pathParameters['roomId']!,
      ),
    ),
    GoRoute(
      path: '/reservation/:roomId',
      builder: (context, state) => ReservationScreen(
        roomId: state.pathParameters['roomId']!,
      ),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) => const PaymentScreen(),
    ),
    GoRoute(
      path: '/confirmation',
      builder: (context, state) => const ConfirmationScreen(),
    ),

    // ── Profile sub-screens ──────────────────────────────────────
    GoRoute(
      path: '/profile/personal-info',
      builder: (context, state) => const PersonalInfoScreen(),
    ),
    GoRoute(
      path: '/profile/payment-method',
      builder: (context, state) => const PaymentMethodScreen(),
    ),
    GoRoute(
      path: '/profile/language',
      builder: (context, state) => const LanguageScreen(),
    ),

    // ── Offline ──────────────────────────────────────────────────
    GoRoute(
      path: '/offline',
      builder: (context, state) => const OfflineStateScreen(),
    ),
  ],
  redirect: (context, state) {
    // Implement redirect logic based on auth state if needed.
    // For now, allow navigation since screens handle their own logic.
    return null;
  },
);
