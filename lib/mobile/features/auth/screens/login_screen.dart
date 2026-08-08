import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    try {
      await auth.signIn(_emailController.text, _passwordController.text);
      if (auth.isAuthenticated && mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  InputDecoration _fieldDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryBurgundy,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: AppColors.backgroundWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  Widget _labeledField({required String label, required Widget field}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelM.copyWith(color: AppColors.textPrimary),
        ),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.loginTitle ?? 'Iniciar sesión',
                style: AppTextStyles.headingXL.copyWith(
                  color: AppColors.primaryBurgundy,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                l10n?.loginSubtitle ?? 'Inicie sesión para continuar',
                style: AppTextStyles.bodyL.copyWith(
                  color: AppColors.primaryBurgundyLight,
                ),
              ),

              const SizedBox(height: 40),

              _labeledField(
                label: l10n?.emailLabel ?? 'Email',
                field: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _fieldDecoration(hint: 'name@example.com'),
                ),
              ),

              const SizedBox(height: 20),

              _labeledField(
                label: l10n?.passwordLabel ?? 'Contraseña',
                field: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,

                  decoration: InputDecoration(
                    labelText: l10n?.passwordLabel ?? 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundWhite,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.push('/forgot-password'),
                  child: Text(
                    l10n?.loginForgotPassword ?? '¿Olvidaste tu contraseña?',
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _login,
                  child: Text(l10n?.loginTitle ?? 'Iniciar sesión'),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text('${l10n?.loginNewUser ?? '¿Eres nuevo en Romio?'} '),
                    GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: Text(
                        l10n?.loginCreateAccount ?? 'Crea una cuenta.',
                      ),
                    ),
                  ],
                ),
              ),

              // This takes all remaining space
              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    'images/RomioLogo.svg',
                    height: 40,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryBurgundyVeryLight,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
