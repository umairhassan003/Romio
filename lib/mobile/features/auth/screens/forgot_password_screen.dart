import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    try {
      await auth.resetPassword(_emailController.text.trim());
      if (mounted) {
        context.push('/verify-otp?email=${Uri.encodeComponent(_emailController.text.trim())}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ha ocurrido un error. Inténtalo de nuevo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Form content — scrollable so validation errors + keyboard don't overflow.
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 24),
                      Text(
                        l10n?.forgotPasswordTitle ?? 'Restablecer contraseña',
                        style: AppTextStyles.headingXL.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        l10n?.emailLabel ?? 'Email',
                        style: AppTextStyles.labelM.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        hint: 'name@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Ingresa tu correo electrónico';
                          if (!_emailRegex.hasMatch(v.trim())) return 'Correo electrónico no válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n?.forgotPasswordSubtitle ??
                            'Restablece tu contraseña de forma rápida y segura para recuperar el acceso.',
                        style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBurgundy,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            elevation: 0,
                          ),
                          onPressed: auth.isLoading ? null : _requestReset,
                          child: auth.isLoading
                              ? const CircularProgressIndicator(color: AppColors.textOnPrimary)
                              : Text(
                                  l10n?.forgotPasswordSendCode ?? 'Enviar código',
                                  style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Logo centered in whatever space remains below the form.
            Expanded(
              child: Center(
                child: SvgPicture.asset(
                  'images/RomioLogo.svg',
                  height: 40,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textTertiary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
