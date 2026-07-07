import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Center(
                child: SvgPicture.asset(
                  'images/RomioLogo.svg',
                  width: 150,
                  colorFilter: const ColorFilter.mode(AppColors.primaryBurgundy, BlendMode.srcIn),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                l10n?.loginTitle ?? 'Iniciar sesión',
                style: AppTextStyles.headingL,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n?.emailLabel ?? 'Correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundWhite,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: l10n?.passwordLabel ?? 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundWhite,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: AppTextStyles.bodyM.copyWith(color: AppColors.primaryBurgundy),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  onPressed: auth.isLoading ? null : _login,
                  child: auth.isLoading 
                      ? const CircularProgressIndicator(color: AppColors.textOnPrimary)
                      : Text(
                          l10n?.loginTitle ?? 'Iniciar sesión',
                          style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Eres nuevo en Romio? ', style: AppTextStyles.bodyM),
                  GestureDetector(
                    onTap: () => context.push('/signup'),
                    child: Text(
                      'Crea una cuenta.',
                      style: AppTextStyles.labelM.copyWith(color: AppColors.primaryBurgundy),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
