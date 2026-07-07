import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    try {
      await auth.signUp(
        _emailController.text, 
        _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
      );
      if (mounted) {
        _showRegistrationSuccess(context);
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
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: Text(l10n?.signupTitle ?? 'Registrarse', style: AppTextStyles.headingM),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBurgundy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField('Nombre inicial', controller: _firstNameController)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Apellido', controller: _lastNameController)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(l10n?.emailLabel ?? 'Correo electrónico', controller: _emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField('Fecha de nacimiento'), // Could wire up to a date picker if implemented later
            const SizedBox(height: 16),
            _buildTextField('Dirección de facturación'),
            const SizedBox(height: 16),
            _buildTextField('Contraseña', obscureText: true, controller: _passwordController),
            const SizedBox(height: 16),
            _buildTextField('Confirmar contraseña', obscureText: true, controller: _confirmPasswordController),
            const SizedBox(height: 24),
            const Text(
              'Al registrarte, aceptas nuestros Términos y Condiciones.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBurgundy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                onPressed: auth.isLoading ? null : _signup,
                child: auth.isLoading 
                    ? const CircularProgressIndicator(color: AppColors.textOnPrimary)
                    : Text(
                        l10n?.signupTitle ?? 'Registrarse',
                        style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false, TextEditingController? controller, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        filled: true,
        fillColor: AppColors.backgroundWhite,
      ),
    );
  }

  void _showRegistrationSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
        title: const Text('Todo listo', style: AppTextStyles.headingM),
        content: const Text(
          'Tu cuenta se ha creado correctamente.',
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
                context.go('/home'); // Or /login depending on verify requirements
              },
              child: Text(
                'Ir al inicio',
                style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
              ),
            ),
          )
        ],
      ),
    );
  }
}
