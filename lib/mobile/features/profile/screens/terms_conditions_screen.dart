import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
              // Back Button Top-Left
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
              const SizedBox(height: 12),

              // Title Centered
              Center(
                child: Text(
                  l10n?.termsTitle ?? 'Términos y condiciones',
                  style: AppTextStyles.headingL.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Section 1
              _buildSectionTitle(l10n?.termsSection1Title ?? '1. Identificación de la empresa / titular'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.termsSection1Text ?? 'Romio C.A., RIF: V-25754567-9, con domicilio en Av. Ppal de las Palmas, Distrito Capital. Venezuela. Correo de contacto: info@getromio.app'),
              const SizedBox(height: 24),

              // Section 2
              _buildSectionTitle(l10n?.termsSection2Title ?? '2. Aceptación de las condiciones'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.termsSection2Text ?? 'El uso de la aplicación móvil Romio implica la aceptación plena e incondicional de los presentes Términos y Condiciones por parte del usuario. Al acceder o utilizar la plataforma, el usuario confirma que ha leído, entendido y aceptado estas normas. Si el usuario no está de acuerdo con alguno de los términos, deberá abstenerse de utilizar la aplicación.'),
              const SizedBox(height: 24),

              // Section 3
              _buildSectionTitle(l10n?.termsSection3Title ?? '3. Requisitos para ser usuario'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.termsSection3Text ?? 'La reserva de habitaciones a través de la aplicación está estrictamente reservada a personas mayores de edad (18 años o más).\nAl realizar una reserva, el usuario declara y garantiza que cumple con este requisito. Romio se reserva el derecho de cancelar cualquier reserva o suspender el servicio si se detecta que el usuario no cumple con la edad mínima requerida.'),
              const SizedBox(height: 24),

              // Section 4
              _buildSectionTitle(l10n?.termsSection4Title ?? '4. Servicio'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.termsSection4Text ?? 'Romio es una plataforma intermediaria que facilita la reserva de habitaciones de hotel por horas de forma rápida y sencilla.\nRomio no es propietaria ni gestiona directamente los establecimientos hoteleros ofertados en la plataforma. La prestación final del servicio de alojamiento es responsabilidad exclusiva de cada hotel.'),
              const SizedBox(height: 24),

              // Section 5
              _buildSectionTitle(l10n?.termsSection5Title ?? '5. Pagos'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.termsSection5Text ?? 'Al realizar una reserva a través de Romio, el usuario abonará en la aplicación los gastos de gestión correspondientes.\nEl importe restante de la reserva se abonará directamente en el hotel al momento del check-in, utilizando los métodos de pago aceptados por el establecimiento. En aquellos casos donde sea necesario el pago del total de la reserva con carácter previo, dicha condición será informada al usuario antes de confirmar la reserva.'),
              const SizedBox(height: 24),

              // Section 6
              _buildSectionTitle(l10n?.termsSection6Title ?? '6. Cancelaciones y modificaciones'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.termsSection6Text ?? 'Dado que las reservas se gestionan a través de Romio, cualquier modificación o solicitud de cancelación deberá realizarse a través de los canales de contacto oficial de la aplicación.\nLas solicitudes estarán sujetas a la aprobación y políticas del establecimiento hotelero correspondientes, por lo que Romio no puede garantizar la aceptación de modificaciones o reembolsos en todos los casos.'),
              const SizedBox(height: 24),

              // Section 7
              _buildSectionTitle(l10n?.termsSection7Title ?? '7. Uso correcto de la app'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.termsSection7Text ?? 'El usuario se compromete a hacer un uso adecuado y lícito de la aplicación y de sus servicios.\nQueda estrictamente prohibido realizar reservas falsas, fraudulentas o con fines ilícitos, así como interferir en el correcto funcionamiento de la plataforma.'),
              const SizedBox(height: 24),

              // Section 8
              _buildSectionTitle(l10n?.termsSection8Title ?? '8. Propiedad intelectual'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.termsSection8Text ?? 'Todos los contenidos, marcas, logos, textos, imágenes, diseño gráfico y código fuente de la aplicación Romio son propiedad exclusiva de Romio C.A. o de sus licenciantes y están protegidos por las leyes de propiedad intelectual e industrial. Queda prohibida su reproducción, distribución o modificación sin autorización previa y por escrito.'),
              const SizedBox(height: 24),

              // Section 9
              _buildSectionTitle(l10n?.termsSection9Title ?? '9. Modificación de los términos'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.termsSection9Text ?? 'Romio se reserva el derecho de modificar los presentes Términos y Condiciones en cualquier momento. Las modificaciones entrarán en vigor a partir de su publicación en la aplicación. El uso continuado de la plataforma tras la modificación de las condiciones implica la aceptación de las mismas.'),
              const SizedBox(height: 24),

              // Section 10
              _buildSectionTitle(l10n?.termsSection10Title ?? '10. Legislación y jurisdicción'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.termsSection10Text ?? 'Los presentes Términos y Condiciones se regirán e interpretarán de acuerdo con la legislación vigente. Para cualquier controversia que pudiera derivarse del uso de la aplicación, las partes se someterán a los juzgados y tribunales competentes.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.labelM.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyM.copyWith(
        fontSize: 14,
        height: 1.45,
        color: const Color(0xFF333333),
      ),
    );
  }
}
