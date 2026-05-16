import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate initial delay/auth check
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBurgundy,
      body: Center(
        child: SvgPicture.asset(
          'images/RomioLogo.svg',
          width: 200,
          colorFilter: ColorFilter.mode(Colors.white.withValues(alpha: 1.0), BlendMode.srcIn),
        ),
      ),
    );
  }
}
