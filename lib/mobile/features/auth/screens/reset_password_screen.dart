import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../widgets/app_text_field.dart';

/// Shown after the user verifies the recovery OTP from their email.
/// Supabase creates a recovery session once the OTP is validated.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (!auth.canResetPassword && mounted) {
        context.go('/forgot-password');
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    try {
      await auth.updatePassword(_passwordController.text);
      await auth.signOut();
      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ha ocurrido un error. Inténtalo de nuevo.')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
        title: Text(
          l10n?.resetPasswordSuccessTitle ?? 'Contraseña actualizada',
          style: AppTextStyles.headingM,
        ),
        content: Text(
          l10n?.resetPasswordSuccessBody ??
              'Tu contraseña se ha actualizado correctamente. Ya puedes iniciar sesión con tu nueva contraseña.',
          style: AppTextStyles.bodyM,
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBurgundy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/login');
              },
              child: Text(
                l10n?.resetPasswordGoLogin ?? 'Iniciar sesión',
                style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
                  l10n?.resetPasswordTitle ?? 'Restablecer contraseña',
                  style: AppTextStyles.headingXL.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.resetPasswordSubtitle ?? 'Ingresa tu nueva contraseña a continuación.',
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  hint: l10n?.resetPasswordNewLabel ?? 'Nueva contraseña',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                    if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  hint: l10n?.resetPasswordConfirmLabel ?? 'Confirmar contraseña',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    child: Icon(
                      _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                    if (v != _passwordController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
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
                    onPressed: auth.isLoading ? null : _updatePassword,
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: AppColors.textOnPrimary)
                        : Text(
                            l10n?.resetPasswordSave ?? 'Guardar nueva contraseña',
                            style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
