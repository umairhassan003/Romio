import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // Track expanded state for each FAQ item index
  final Set<int> _expandedIndices = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // List of FAQs (Questions and Answers)
    final faqs = [
      _FaqItem(
        question: l10n?.faqQuestion1 ?? '¿Cuándo se realiza el pago?',
        answer: l10n?.faqAnswer1 ??
            'Al reservar con nosotros, sólo pagarás los gastos de gestión. El resto del importe lo abonarás directamente en el hotel al hacer check-in, con tu método de pago preferido. En algunos hoteles, será necesario pagar el total de la reserva en el momento de la confirmación. Esta información se mostrará antes de finalizar la reserva.',
      ),
      _FaqItem(
        question: l10n?.faqQuestion2 ?? '¿Puedo reservar una habitación siendo menor de edad?',
        answer: l10n?.faqAnswer2 ??
            'No, para reservar una habitación es obligatorio ser mayor de edad. En caso de que te preguntes si tu pareja, siendo mayor de edad, puede realizar la reserva por ti, lamentablemente no es posible. Un menor solo puede acceder a la habitación si va acompañado por un familiar parental o tutor legal. Por seguridad y regulaciones del gobierno, la presentación de un documento de identificación válido es estrictamente obligatoria para todas las personas que se registren en el hotel.',
      ),
      _FaqItem(
        question: l10n?.faqQuestion3 ?? '¿Es posible alojarse con más de dos personas en la misma reserva?',
        answer: l10n?.faqAnswer3 ??
            'Por lo general, nuestras habitaciones dobles tienen una capacidad máxima de dos personas, y el precio indicado en la web corresponde al total de la estancia por habitación. En cualquier caso, puedes hacer una solicitud (que deberá ser aprobada por el hotel).',
      ),
      _FaqItem(
        question: l10n?.faqQuestion4 ?? '¿Tengo que presentar mi identificación?',
        answer: l10n?.faqAnswer4 ??
            'Sí, es obligatorio presentar un documento de identificación válido para todas las personas que se registren en el hotel. En caso de no presentar un documento válido, el hotel se reserva el derecho de cobrar la reserva.',
      ),
      _FaqItem(
        question: l10n?.faqQuestion5 ?? 'Quiero modificar mi reserva',
        answer: l10n?.faqAnswer5 ??
            'Dado que tu reserva ha sido gestionada con Romio, solo nosotros podemos modificarla. Estamos mejorando este proceso para hacerlo más fácil, pero de momento por favor contáctanos indicando qué dato de la reserva querrías modificar y nos pondremos en contacto con el hotel para hacerles llegar tu solicitud. Recuerda que esta decisión depende totalmente del hotel por lo que no podemos garantizar que la modificación sea siempre posible.',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar with Back Button
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
              const SizedBox(height: 12),

              // Title
              Text(
                l10n?.faqTitle ?? 'FAQ',
                style: AppTextStyles.headingL.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),

              // FAQ List Items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faqs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final isExpanded = _expandedIndices.contains(index);
                  final faq = faqs[index];

                  return _buildFaqCard(
                    faq: faq,
                    isExpanded: isExpanded,
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedIndices.remove(index);
                        } else {
                          _expandedIndices.add(index);
                        }
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqCard({
    required _FaqItem faq,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: 22,
          vertical: isExpanded ? 20 : 18,
        ),
        decoration: BoxDecoration(
          color: isExpanded ? const Color(0xFFF5F5F5) : const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.circular(isExpanded ? 24 : 30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    faq.question,
                    style: AppTextStyles.labelM.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isExpanded ? Icons.remove : Icons.add,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              Text(
                faq.answer,
                style: AppTextStyles.bodyM.copyWith(
                  fontSize: 14,
                  height: 1.45,
                  color: const Color(0xFF333333),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}
