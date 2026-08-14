import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login credentials') || msg.contains('invalid credentials')) {
      return 'Correo o contraseña incorrectos. Verifica tus datos e intenta de nuevo.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Debes confirmar tu correo electrónico antes de iniciar sesión.';
    }
    if (msg.contains('too many requests') || msg.contains('rate limit')) {
      return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
    }
    if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
      return 'Error de conexión. Verifica tu internet e intenta de nuevo.';
    }
    return 'Algo salió mal. Por favor intenta de nuevo.';
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    try {
      await auth.signIn(_emailController.text.trim(), _passwordController.text);
      if (auth.isAuthenticated && mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyError(e))),
        );
      }
    }
  }

  Widget _labeledField({required String label, required Widget field}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelM.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form content at its natural height.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        l10n?.loginTitle ?? 'Iniciar sesión',
                        style: AppTextStyles.headingXL.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n?.loginSubtitle ?? 'Inicie sesión para continuar',
                        style: AppTextStyles.bodyL.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 40),
                      _labeledField(
                        label: l10n?.emailLabel ?? 'Email',
                        field: AppTextField(
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
                      ),
                      const SizedBox(height: 16),
                      _labeledField(
                        label: l10n?.passwordLabel ?? 'Contraseña',
                        field: AppTextField(
                          hint: 'Al menos 6 caracteres',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                            if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => context.push('/forgot-password'),
                          child: Text(
                            l10n?.loginForgotPassword ?? '¿Olvidó su contraseña?',
                            style: AppTextStyles.bodyM.copyWith(
                              color: AppColors.primaryBurgundy,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primaryBurgundy,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _login,
                          child: auth.isLoading
                              ? const CircularProgressIndicator(color: AppColors.textOnPrimary)
                              : Text(l10n?.loginTitle ?? 'Iniciar sesión'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              '${l10n?.loginNewUser ?? '¿Eres nuevo en Romio?'} ',
                              style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/signup'),
                              child: Text(
                                l10n?.loginCreateAccount ?? 'Crea una cuenta.',
                                style: AppTextStyles.bodyM.copyWith(
                                  color: AppColors.primaryBurgundy,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primaryBurgundy,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
