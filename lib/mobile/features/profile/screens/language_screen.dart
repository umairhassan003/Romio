import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/profile_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final selected = localeProvider.languageCode;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryBurgundy,
                        size: 20,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  l10n?.profileLanguageTitle ?? 'Idioma',
                  style: AppTextStyles.headingL,
                ),
              ),
              const SizedBox(height: 32),
              _langOption(context, localeProvider, profileProvider, 'es', 'Español', selected == 'es'),
              const SizedBox(height: 16),
              _langOption(context, localeProvider, profileProvider, 'en', 'Inglés', selected == 'en'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langOption(BuildContext context, LocaleProvider locale, ProfileProvider profile, String code, String name, bool sel) {
    return GestureDetector(
      onTap: () {
        locale.setLocale(code);
        profile.updateLanguage(code);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? AppColors.primaryBurgundy : AppColors.borderLight, width: 2),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(name, style: AppTextStyles.labelM),
          if (sel) const Icon(Icons.check_circle, color: AppColors.primaryBurgundy),
        ]),
      ),
    );
  }
}
