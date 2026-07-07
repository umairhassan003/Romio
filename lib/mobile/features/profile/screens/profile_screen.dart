import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
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
    final name = profileProvider.displayName;

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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.primaryBurgundy,
                            ),
                            onPressed: () {},
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(child: Text(name, style: AppTextStyles.headingL)),
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
                        Icons.credit_card_outlined,
                        l10n?.profilePaymentMethod ?? 'Método de pago',
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
                        l10n?.profileSupportSection ?? 'Support',
                        style: AppTextStyles.headingS,
                      ),
                      const SizedBox(height: 12),
                      _menuCard(
                        context,
                        Icons.mail_outline,
                        l10n?.profileContact ?? 'Contacto',
                        null,
                      ),
                      const SizedBox(height: 12),
                      _menuCard(
                        context,
                        Icons.help_outline,
                        l10n?.profileFaq ?? 'FAQ',
                        null,
                      ),
                      const SizedBox(height: 12),
                      _menuCard(
                        context,
                        Icons.gavel_outlined,
                        l10n?.profileTerms ?? 'Términos y Condiciones',
                        null,
                      ),
                      const SizedBox(height: 32),

                      // Logout
                      GestureDetector(
                        onTap: () async {
                          await context.read<AuthProvider>().signOut();
                          if (context.mounted) context.go('/login');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.logout, color: AppColors.error),
                              const SizedBox(width: 16),
                              Text(
                                l10n?.profileLogout ?? 'Cerrar Sesión',
                                style: AppTextStyles.labelM.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
          color: AppColors.backgroundPink,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBurgundy, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.labelM)),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
