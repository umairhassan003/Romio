import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/main_tab_shell.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null && context.read<ProfileProvider>().profile == null) {
        context.read<ProfileProvider>().loadProfile(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileProvider = context.watch<ProfileProvider>();
    final authProvider = context.watch<AuthProvider>();
    final firstName = profileProvider.profile?.firstName;
    final isLoggedIn = authProvider.isAuthenticated;

    final String titleText;
    if (firstName != null && firstName.isNotEmpty) {
      titleText = '${l10n?.profileGreetingHola ?? 'Hola'}, $firstName';
    } else {
      titleText = l10n?.profileWelcome ?? 'Bienvenidos';
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,

      body:
          profileProvider.isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBurgundy,
                ),
              )
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 72),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header back button row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => TabSwitcher.switchTo(context, 0),
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

                      // Title greeting
                      Center(
                        child: Text(titleText, style: AppTextStyles.headingL),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          l10n?.profileManageAccount ?? 'Gestiona tu cuenta',
                          style: AppTextStyles.bodyM.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Account section
                      Text(
                        l10n?.profileAccountSection ?? 'Cuenta',
                        style: AppTextStyles.headingS,
                      ),
                      const SizedBox(height: 12),
                      _menuCard(
                        context,
                        Icons.person_outline,
                        l10n?.profilePersonalInfo ?? 'Información personal',
                        '/profile/personal-info',
                      ),
                      const SizedBox(height: 12),
                      _menuCard(
                        context,
                        Icons.lock_outline,
                        l10n?.profileChangePassword ?? 'Cambiar contraseña',
                        '/profile/change-password',
                      ),
                      const SizedBox(height: 12),

                      const SizedBox(height: 12),
                      _menuCard(
                        context,
                        Icons.credit_card_outlined,
                        l10n?.profilePaymentMethod ?? 'Añadir método de pago',
                        '/profile/payment-method',
                      ),
                      const SizedBox(height: 12),
                      _menuCard(
                        context,
                        Icons.language,
                        l10n?.profileLanguageTitle ?? 'Idioma',
                        '/profile/language',
                      ),
                      const SizedBox(height: 32),

                      // Support section
                      Text(
                        l10n?.profileSupportSection ?? 'Soporte',
                        style: AppTextStyles.headingS,
                      ),
                      const SizedBox(height: 12),
                      _menuCard(
                        context,
                        Icons.mail_outline,
                        l10n?.profileContact ?? 'Contacto',
                        '/profile/contact',
                      ),
                      const SizedBox(height: 12),
                      _menuCard(
                        context,
                        Icons.help_outline,
                        l10n?.profileFaq ?? 'Preguntas frecuentes',
                        '/profile/faq',
                      ),
                      const SizedBox(height: 12),
                      _menuCard(
                        context,
                        Icons.gavel_outlined,
                        l10n?.profileTerms ?? 'Términos y condiciones',
                        '/profile/terms',
                      ),
                      const SizedBox(height: 12),
                      _menuCard(
                        context,
                        Icons.privacy_tip_outlined,
                        l10n?.profilePrivacyPolicy ?? 'Políticas de Privacidad',
                        '/profile/privacy-policy',
                      ),
                      const SizedBox(height: 32),

                      // Logout (only when authenticated)
                      if (isLoggedIn) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              await context.read<AuthProvider>().signOut();
                              if (context.mounted) context.go('/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              l10n?.profileLogout ?? 'Cerrar sesión',
                              style: AppTextStyles.labelM.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _menuCard(
    BuildContext context,
    IconData icon,
    String title,
    String? route,
  ) {
    return GestureDetector(
      onTap: route != null ? () => context.push(route) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.labelM)),
            const Icon(
              Icons.chevron_right,
              color: AppColors.primaryBurgundy,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
