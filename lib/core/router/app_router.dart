
import 'package:go_router/go_router.dart';

import '../../mobile/features/onboarding/screens/splash_screen.dart';
import '../../mobile/features/onboarding/screens/onboarding_screen.dart';
import '../../mobile/features/auth/screens/login_screen.dart';
import '../../mobile/features/auth/screens/signup_screen.dart';
import '../../mobile/features/home/screens/home_screen.dart';
import '../../mobile/features/profile/screens/profile_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    // Additional screens can be mapped here as needed
  ],
  redirect: (context, state) {
    // Implement redirect logic based on auth state if needed.
    // For now, allow navigation since screens handle their own logic.
    return null;
  },
);
