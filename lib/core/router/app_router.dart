import 'package:go_router/go_router.dart';

import '../../mobile/features/onboarding/screens/splash_screen.dart';
import '../../mobile/features/onboarding/screens/onboarding_screen.dart';
import '../../mobile/features/auth/screens/login_screen.dart';
import '../../mobile/features/auth/screens/signup_screen.dart';
import '../../mobile/features/auth/screens/forgot_password_screen.dart';
import '../../mobile/features/auth/screens/verify_otp_screen.dart';
import '../../mobile/features/auth/screens/reset_password_screen.dart';
import '../../mobile/features/home/screens/hotel_detail_screen.dart';
import '../../mobile/features/home/screens/room_detail_screen.dart';
import '../../mobile/features/reservation/screens/reservation_screen.dart';
import '../../mobile/features/reservation/screens/payment_screen.dart';
import '../../mobile/features/reservation/screens/confirmation_screen.dart';
import '../../mobile/features/profile/screens/personal_info_screen.dart';
import '../../mobile/features/profile/screens/change_password_screen.dart';
import '../../mobile/features/profile/screens/payment_methods_screen.dart';
import '../../mobile/features/payment/screens/add_payment_method_screen.dart';
import '../../mobile/features/payment/screens/data_storage_info_screen.dart';
import '../../mobile/features/profile/screens/language_screen.dart';
import '../../mobile/features/profile/screens/faq_screen.dart';
import '../../mobile/features/profile/screens/contact_screen.dart';
import '../../mobile/features/profile/screens/terms_conditions_screen.dart';
import '../../mobile/features/profile/screens/privacy_policy_screen.dart';
import '../../mobile/features/offline/screens/offline_state_screen.dart';
import '../../mobile/features/notifications/screens/notifications_screen.dart';

import '../../mobile/widgets/main_tab_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Pre-auth routes ──────────────────────────────────────────
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return VerifyOtpScreen(email: email);
      },
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),

    // ── Main tab shell (Home / Reservations / Profile) ───────────
    GoRoute(path: '/home', builder: (context, state) => const MainTabShell()),

    // ── Notifications ────────────────────────────────────────────
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // ── Detail / flow screens (pushed on top of tabs) ────────────
    GoRoute(
      path: '/hotel/:hotelId',
      builder:
          (context, state) =>
              HotelDetailScreen(hotelId: state.pathParameters['hotelId']!),
    ),
    GoRoute(
      path: '/hotel/:hotelId/room/:roomId',
      builder:
          (context, state) => RoomDetailScreen(
            hotelId: state.pathParameters['hotelId']!,
            roomId: state.pathParameters['roomId']!,
          ),
    ),
    GoRoute(
      path: '/reservation/:roomId',
      builder:
          (context, state) =>
              ReservationScreen(roomId: state.pathParameters['roomId']!),
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
      path: '/profile/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/profile/payment-method',
      builder: (context, state) => const PaymentMethodScreen(),
    ),
    GoRoute(
      path: '/profile/add-payment-method',
      builder: (context, state) => const AddPaymentMethodScreen(),
    ),
    GoRoute(
      path: '/profile/data-storage',
      builder: (context, state) => const DataStorageInfoScreen(),
    ),
    GoRoute(
      path: '/profile/language',
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(
      path: '/profile/contact',
      builder: (context, state) => const ContactScreen(),
    ),
    GoRoute(
      path: '/profile/faq',
      builder: (context, state) => const FaqScreen(),
    ),
    GoRoute(
      path: '/profile/terms',
      builder: (context, state) => const TermsConditionsScreen(),
    ),
    GoRoute(
      path: '/profile/privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
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
