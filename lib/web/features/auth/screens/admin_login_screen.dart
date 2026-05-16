import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/login_card.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: Center(
        child: SingleChildScrollView(
          child: LoginCard(),
        ),
      ),
    );
  }
}
