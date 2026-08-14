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
  final List<TextEditingController> _controllers = List.generate(
    8,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(8, (_) => FocusNode());

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
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);
    final code = _code.trim();

    if (code.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.verifyOtpRequired ??
                'Por favor ingresa el código de verificación',
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
          SnackBar(content: Text(_otpErrorMessage(l10n, e.message))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.verifyOtpInvalid ?? 'Código inválido o expirado',
            ),
          ),
        );
      }
    }
  }

  String _otpErrorMessage(AppLocalizations? l10n, String? message) {
    final normalized = message?.toLowerCase() ?? '';
    if (normalized.contains('expired')) {
      return l10n?.verifyOtpExpired ??
          'El código ha expirado. Solicita uno nuevo.';
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

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 7) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
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
              // Back button
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
                l10n?.verifyOtpTitle ?? 'Código de verificación',
                style: AppTextStyles.headingXL.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),

              // 8-digit boxes — SizedBox gaps between Expanded children so
              // every box receives exactly the same width.
              Row(
                children: [
                  for (int i = 0; i < 8; i++) ...[
                    if (i > 0) const SizedBox(width: 5),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: KeyboardListener(
                          focusNode: FocusNode(),
                          onKeyEvent: (e) => _onKeyEvent(i, e),
                          child: TextField(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: AppTextStyles.headingS,
                            decoration: InputDecoration(
                              counterText: '',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                            ),
                            onChanged: (v) => _onDigitEntered(i, v),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              Text(
                l10n?.verifyOtpSubtitleSimple ??
                    'Introduce el código de verificación para confirmar tu identificación.',
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  onPressed: auth.isLoading ? null : _verify,
                  child:
                      auth.isLoading
                          ? const CircularProgressIndicator(
                            color: AppColors.textOnPrimary,
                          )
                          : Text(
                            l10n?.verifyOtpValidate ?? 'Enviar código',
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
      ),
    );
  }
}
