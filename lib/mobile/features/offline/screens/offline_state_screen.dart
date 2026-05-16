import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OfflineStateScreen extends StatelessWidget {
  const OfflineStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 100, color: AppColors.textSecondary),
              const SizedBox(height: 32),
              Text(
                l10n?.errorNoInternetTitle ?? 'Sin conexión',
                style: AppTextStyles.headingL,
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.errorNoInternetBody ?? 'Parece que no tienes acceso a internet en este momento',
                style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBurgundy,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                onPressed: () {
                  // Retry logic would go here
                },
                child: Text('Reintentar', style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
