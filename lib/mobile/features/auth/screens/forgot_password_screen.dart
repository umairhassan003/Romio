import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: Text(l10n?.forgotPasswordTitle ?? 'Recupera tu contraseña', style: AppTextStyles.headingM),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBurgundy),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ingresa tu correo electrónico para recibir un código de recuperación.',
              style: AppTextStyles.bodyM,
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                labelText: l10n?.emailLabel ?? 'Correo electrónico',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                filled: true,
                fillColor: AppColors.backgroundWhite,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBurgundy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                onPressed: () => context.push('/verify-otp'),
                child: Text(
                  'Solicitar código',
                  style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
