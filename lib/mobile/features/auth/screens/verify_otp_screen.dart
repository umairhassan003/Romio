import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.email.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/forgot-password');
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.verifyOtpRequired ?? 'Por favor ingresa el código de verificación',
          ),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    try {
      await auth.verifyRecoveryOtp(email: widget.email, token: code);
      if (mounted) {
        context.push('/reset-password');
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_otpErrorMessage(l10n, e.message)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.verifyOtpInvalid ?? 'Código inválido o expirado'),
          ),
        );
      }
    }
  }

  String _otpErrorMessage(AppLocalizations? l10n, String? message) {
    final normalized = message?.toLowerCase() ?? '';
    if (normalized.contains('expired')) {
      return l10n?.verifyOtpExpired ?? 'El código ha expirado. Solicita uno nuevo.';
    }
    return l10n?.verifyOtpInvalid ?? 'Código inválido o expirado';
  }

  Future<void> _resend() async {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    try {
      await auth.resetPassword(widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.verifyOtpResent ?? 'Código reenviado. Revisa tu correo.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.genericError ?? 'Ha ocurrido un error. Inténtalo de nuevo.',
            ),
          ),
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
      appBar: AppBar(
        title: Text(
          l10n?.verifyOtpTitle ?? 'Código de verificación',
          style: AppTextStyles.headingM,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBurgundy),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.verifyOtpSubtitle(widget.email) ??
                  'Ingresa el código de verificación que enviamos a ${widget.email}.',
              style: AppTextStyles.bodyM,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingL,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: l10n?.verifyOtpHint ?? 'Código de verificación',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                filled: true,
                fillColor: AppColors.backgroundWhite,
              ),
              onSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBurgundy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: auth.isLoading ? null : _verify,
                child: auth.isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.textOnPrimary,
                      )
                    : Text(
                        l10n?.verifyOtpValidate ?? 'Validar',
                        style: AppTextStyles.labelM.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n?.verifyOtpResendPrompt ?? '¿No recibiste el código? ',
                  style: AppTextStyles.bodyM,
                ),
                GestureDetector(
                  onTap: auth.isLoading ? null : _resend,
                  child: Text(
                    l10n?.verifyOtpResend ?? 'Reenviar',
                    style: AppTextStyles.labelM.copyWith(
                      color: AppColors.primaryBurgundy,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primaryBurgundy,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
