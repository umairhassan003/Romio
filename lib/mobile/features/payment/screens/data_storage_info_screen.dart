import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Informational screen shown when the guest taps "Conocer más sobre el
/// almacenamiento de datos" on the payment-methods screen. Explains how Romio
/// handles saved card data (and that the CVV is never stored).
class DataStorageInfoScreen extends StatelessWidget {
  const DataStorageInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  child: const Icon(Icons.arrow_back,
                      color: AppColors.primaryBurgundy, size: 20),
                ),
              ),
              const SizedBox(height: 24),

              _body(
                l10n?.dataStorageIntro1 ??
                    'Romio ofrece la posibilidad de guardar sus datos bancarios '
                        'para simplificar futuras reservas.',
              ),
              const SizedBox(height: 16),
              _body(
                l10n?.dataStorageIntro2 ??
                    'Este servicio se ha diseñado para ofrecer un nivel de '
                        'seguridad muy elevado.',
              ),
              const SizedBox(height: 16),

              _bullet(
                l10n?.dataStorageBullet1 ??
                    'Sus datos bancarios y sus transacciones están protegidos.',
              ),
              _bullet(
                l10n?.dataStorageBullet2 ??
                    'Nuestro servicio de pago en línea garantiza que sus datos '
                        'permanezcan seguros y se traten con total confidencialidad.',
              ),
              _bullet(
                l10n?.dataStorageBullet3 ??
                    'Se le solicitará que introduzca el código de seguridad (los '
                        'tres dígitos situados en la parte posterior de su tarjeta de '
                        'crédito) durante cada transacción, con el fin de comprobar la '
                        'validez de la tarjeta y evitar su uso fraudulento. Esta '
                        'información nunca se almacena.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(String text) => Text(
        text,
        textAlign: TextAlign.justify,
        style: AppTextStyles.bodyL.copyWith(
          height: 1.5,
          color: AppColors.textPrimary,
        ),
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 10),
              child: Text('•',
                  style: AppTextStyles.bodyL.copyWith(color: AppColors.textPrimary)),
            ),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.justify,
                style: AppTextStyles.bodyL.copyWith(
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
}
