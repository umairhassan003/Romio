import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../widgets/app_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    try {
      await auth.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.changePasswordSuccess ?? 'Contraseña actualizada correctamente'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().toLowerCase().contains('invalid')
            ? (l10n?.changePasswordWrongCurrent ?? 'La contraseña actual no es correcta')
            : (l10n?.genericError ?? 'Ha ocurrido un error. Inténtalo de nuevo.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
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
                  l10n?.changePasswordTitle ?? 'Cambiar contraseña',
                  style: AppTextStyles.headingXL.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  hint: l10n?.changePasswordCurrentLabel ?? 'Contraseña actual',
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrent,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    child: Icon(
                      _obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu contraseña actual';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  hint: l10n?.changePasswordNewLabel ?? 'Nueva contraseña',
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscureNew = !_obscureNew),
                    child: Icon(
                      _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa la nueva contraseña';
                    if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                    if (v == _currentPasswordController.text) {
                      return 'La nueva contraseña debe ser diferente a la actual';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  hint: l10n?.changePasswordConfirmLabel ?? 'Confirmar nueva contraseña',
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
                    if (v == null || v.isEmpty) return 'Confirma tu nueva contraseña';
                    if (v != _newPasswordController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBurgundy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      elevation: 0,
                    ),
                    child: auth.isLoading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textOnPrimary,
                          )
                        : Text(
                            l10n?.changePasswordSave ?? 'Guardar contraseña',
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
