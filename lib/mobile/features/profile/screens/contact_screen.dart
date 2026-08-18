import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button Top-Left
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
              const SizedBox(height: 12),

              // Title Centered
              Center(
                child: Text(
                  l10n?.contactTitle ?? 'Contacto',
                  style: AppTextStyles.headingL.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Heading section
              Text(
                l10n?.contactHeading ?? '¿Necesitas contactarte con nosotros?',
                style: AppTextStyles.headingS.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n?.contactSubheading ?? 'Estamos para ayudarte',
                style: AppTextStyles.bodyM.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),

              // Contact Rows (Email & WhatsApp)
              _buildContactRow(
                icon: Icons.mail_outline,
                label: l10n?.contactEmailLabel ?? 'Email: ',
                value: 'info@getromio.app',
              ),
              const SizedBox(height: 16),
              _buildContactRow(
                icon: Icons.chat_bubble_outline,
                label: l10n?.contactWhatsappLabel ?? 'Whatsapp: ',
                value: '+34653379023',
              ),
              const SizedBox(height: 32),

              // Divider Line
              const Divider(
                color: Color(0xFFCCCCCC),
                thickness: 1,
                height: 1,
              ),
              const SizedBox(height: 32),

              // Schedule Section
              Text(
                l10n?.contactHoursTitle ?? 'Horario de atención:',
                style: AppTextStyles.labelM.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.contactDaysText ?? 'Lunes a Viernes',
                style: AppTextStyles.bodyM.copyWith(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n?.contactHoursText ?? '9:00 a. m - 6:00 p.m (Hora de Madrid, España)',
                style: AppTextStyles.bodyM.copyWith(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 56),

              // Social Media Buttons Row Centered
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialBadge(
                    Icons.facebook,
                    'https://www.facebook.com/profile.php?id=61583992976271',
                  ),
                  const SizedBox(width: 20),
                  _buildSocialBadge(
                    Icons.camera_alt_outlined,
                    'https://www.instagram.com/romio.app/',
                  ),
                  const SizedBox(width: 20),
                  _buildSocialBadge(
                    Icons.language,
                    'https://getromio.app',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        // Burgundy Circle Badge with Icon
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primaryBurgundy,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        // Label & Blue Link Text
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialBadge(IconData icon, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.primaryBurgundy,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}
