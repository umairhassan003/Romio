import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_calendar.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dateController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _termsAccepted = false;
  bool _termsError = false;
  DateTime? _dob;

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  /// Opens the shared calendar restricted so the user must be at least 18.
  Future<void> _pickDob() async {
    final now = DateTime.now();
    // Latest allowed birth date that still makes the user 18 today.
    final latest = DateTime(now.year - 18, now.month, now.day);
    final earliest = DateTime(now.year - 100, now.month, now.day);
    final picked = await showAppDatePicker(
      context: context,
      firstDate: earliest,
      lastDate: latest,
      initialDate: _dob ?? latest,
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('user already registered') ||
        msg.contains('already registered')) {
      return 'Este correo ya tiene una cuenta registrada.';
    }
    if (msg.contains('password should be at least') ||
        msg.contains('weak password')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (msg.contains('invalid email') ||
        msg.contains('unable to validate email')) {
      return 'El correo electrónico no es válido.';
    }
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
    }
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection')) {
      return 'Error de conexión. Verifica tu internet e intenta de nuevo.';
    }
    return 'Algo salió mal. Por favor intenta de nuevo.';
  }

  Future<void> _signup() async {
    final formValid = _formKey.currentState!.validate();
    if (!_termsAccepted) setState(() => _termsError = true);
    if (!formValid || !_termsAccepted) return;

    final auth = context.read<AuthProvider>();
    try {
      await auth.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        city: _addressController.text.trim(),
      );
      if (mounted) _showRegistrationSuccess(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_friendlyError(e))));
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
    _dateController.dispose();
    _addressController.dispose();
    super.dispose();
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
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
                ),
                const SizedBox(height: 16),
                Text(
                  l10n?.signupCreateAccountTitle ?? 'Create Account',
                  style: AppTextStyles.headingL.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        hint: l10n?.signupFirstNameHint ?? 'First name',
                        controller: _firstNameController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n?.signupFirstNameRequired ?? 'Enter your first name'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        hint: l10n?.signupLastNameHint ?? 'Last name',
                        controller: _lastNameController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n?.signupLastNameRequired ?? 'Enter your last name'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  hint: l10n?.signupEmailHint ?? 'Email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textSecondary, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n?.signupEmailRequired ?? 'Enter your email address';
                    }
                    if (!_emailRegex.hasMatch(v.trim())) {
                      return l10n?.signupEmailInvalid ?? 'Invalid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  hint: l10n?.signupPasswordHint ?? 'At least 6 characters',
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
                    if (v == null || v.isEmpty) {
                      return l10n?.signupPasswordRequired ?? 'Enter a password';
                    }
                    if (v.length < 6) {
                      return l10n?.passwordMinLength ?? 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  hint: l10n?.signupConfirmPasswordHint ?? 'Confirm password',
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
                    if (v == null || v.isEmpty) {
                      return l10n?.signupConfirmPasswordRequired ?? 'Confirm your password';
                    }
                    if (v != _passwordController.text) {
                      return l10n?.passwordMismatch ?? 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        hint: l10n?.signupDateHint ?? 'dd/mm/yyyy',
                        controller: _dateController,
                        readOnly: true,
                        onTap: _pickDob,
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n?.signupDateRequired ?? 'Enter your date of birth'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        hint: l10n?.signupAddressHint ?? 'Billing address',
                        controller: _addressController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n?.signupAddressRequired ?? 'Enter your address'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _termsAccepted,
                        onChanged: (val) => setState(() {
                          _termsAccepted = val ?? false;
                          if (_termsAccepted) _termsError = false;
                        }),
                        activeColor: AppColors.primaryBurgundy,
                        side: BorderSide(
                          color: _termsError ? AppColors.error : AppColors.borderLight,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.signupTermsText ??
                                'By registering, you accept our Terms and Conditions.\nNote: We strictly protect the privacy of your billing information.',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                          if (_termsError)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                l10n?.signupTermsError ?? 'You must accept the terms to continue',
                                style: AppTextStyles.caption.copyWith(color: AppColors.error),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBurgundy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      elevation: 0,
                    ),
                    onPressed: auth.isLoading ? null : _signup,
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: AppColors.textOnPrimary)
                        : Text(
                            l10n?.signupButton ?? 'Register',
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

  void _showRegistrationSuccess(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                l10n?.signupSuccessTitle ?? 'All done!',
                style: AppTextStyles.headingM,
              ),
              const SizedBox(height: 10),
              Text(
                l10n?.signupSuccessBody ?? 'Your account has been created successfully',
                style: AppTextStyles.bodyM,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/login');
                  },
                  child: Text(
                    l10n?.loginTitle ?? 'Sign In',
                    style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary),
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
