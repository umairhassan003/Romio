import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                  l10n?.privacyTitle ?? 'Políticas de privacidad',
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
              _buildSectionTitle(l10n?.privacySection1Title ?? '1. Responsable del tratamiento Romio C.A., RIF:'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.privacySection1Text ?? 'V-25754567-9, con domicilio fiscal en Av. Ppal de las Palmas, Distrito Capital. Venezuela. Correo de contacto: info@getromio.app'),
              const SizedBox(height: 24),

              // Section 2
              _buildSectionTitle(l10n?.privacySection2Title ?? '2. Qué datos recopilamos'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.privacySection2Text1 ?? 'Romio recopila los datos personales que el usuario facilita voluntariamente al registrarse, realizar una reserva o contactar con nuestro equipo de atención al cliente. Los datos recopilados pueden incluir, entre otros:'),
              const SizedBox(height: 8),
              _buildBulletItem(l10n?.privacySection2Bullet1 ?? 'Nombre y apellidos.'),
              _buildBulletItem(l10n?.privacySection2Bullet2 ?? 'Dirección de correo electrónico.'),
              _buildBulletItem(l10n?.privacySection2Bullet3 ?? 'Número de teléfono.'),
              _buildBulletItem(
                  l10n?.privacySection2Bullet4 ?? 'Información relacionada con las reservas realizadas, incluyendo horas, fechas, importes, tipo de habitación, estancia y estado de la reserva.'),
              _buildBulletItem(
                  l10n?.privacySection2Bullet5 ?? 'Cualquier otra información que el usuario facilite voluntariamente para la correcta prestación del servicio.'),
              const SizedBox(height: 12),
              _buildBodyText(
                  l10n?.privacySection2Text2 ?? 'Asimismo, Romio podrá recopilar información técnica y estadística sobre el uso de la aplicación, como el tipo de dispositivo, sistema operativo, versión de la aplicación, horarios de uso, número de reservas realizadas e interacciones con la plataforma, con el fin de mejorar nuestros servicios y optimizar la experiencia del usuario.'),
              const SizedBox(height: 24),

              // Section 3
              _buildSectionTitle(
                  l10n?.privacySection3Title ?? '3. Para qué usamos los datos. Los datos personales serán utilizados para las siguientes finalidades:'),
              const SizedBox(height: 8),
              _buildBulletItem(l10n?.privacySection3Bullet1 ?? 'Gestionar las reservas realizadas por el usuario.'),
              _buildBulletItem(
                  l10n?.privacySection3Bullet2 ?? 'Facilitar la prestación del servicio por parte del establecimiento hotelero seleccionado. Comunicarnos con el usuario en relación con sus reservas, incidencias o consultas.'),
              _buildBulletItem(
                  l10n?.privacySection3Bullet3 ?? 'Prestar asistencia y soporte al usuario. Mejorar el funcionamiento, rendimiento y seguridad de la aplicación.'),
              _buildBulletItem(
                  l10n?.privacySection3Bullet4 ?? 'Elaborar estadísticas e informes internos para mejorar nuestros servicios.'),
              _buildBulletItem(l10n?.privacySection3Bullet5 ?? 'Cumplir con las obligaciones legales que resulten aplicables.'),
              const SizedBox(height: 24),

              // Section 4
              _buildSectionTitle(l10n?.privacySection4Title ?? '4. Destinatarios de los datos'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.privacySection4Text1 ?? 'Romio no vende, alquila ni cede los datos personales de sus usuarios con fines comerciales.'),
              const SizedBox(height: 12),
              _buildBodyText(
                  l10n?.privacySection4Text2 ?? 'No obstante, para gestionar correctamente una reserva, Romio podrá comunicar al establecimiento hotelero correspondiente aquellos datos estrictamente necesarios para la correcta prestación del servicio contratado por el usuario. Asimismo, Romio podrá compartir información con proveedores tecnológicos o de servicios cuando sea estrictamente necesario para el funcionamiento de la plataforma, siempre bajo las correspondientes obligaciones de confidencialidad.'),
              const SizedBox(height: 24),

              // Section 5
              _buildSectionTitle(l10n?.privacySection5Title ?? '5. Seguridad de los datos'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.privacySection5Text1 ?? 'Romio adopta medidas técnicas y organizativas razonables para proteger los datos personales frente al acceso no autorizado, pérdida, alteración, divulgación o cualquier otro tratamiento no autorizado.'),
              const SizedBox(height: 12),
              _buildBodyText(
                  l10n?.privacySection5Text2 ?? 'No obstante, ningún sistema de transmisión o almacenamiento electrónico puede garantizar una seguridad absoluta, por lo que Romio no puede asegurar la inexistencia total de riesgos derivados del uso de Internet.'),
              const SizedBox(height: 24),

              // Section 6
              _buildSectionTitle(l10n?.privacySection6Title ?? '6. Conservación de los datos'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.privacySection6Text ?? 'Los datos personales se conservarán durante el tiempo necesario para gestionar la relación con el usuario, tramitar las reservas realizadas y cumplir con las obligaciones legales que resulten aplicables. Una vez finalizadas dichas finalidades, los datos podrán conservarse únicamente de forma anonimizada para fines estadísticos o de mejora de los servicios.'),
              const SizedBox(height: 24),

              // Section 7
              _buildSectionTitle(l10n?.privacySection7Title ?? '7. Derechos del usuario'),
              const SizedBox(height: 6),
              _buildBodyText(l10n?.privacySection7Text1 ?? 'El usuario podrá solicitar en cualquier momento:'),
              const SizedBox(height: 8),
              _buildBulletItem(l10n?.privacySection7Bullet1 ?? 'Acceder a sus datos personales.'),
              _buildBulletItem(l10n?.privacySection7Bullet2 ?? 'Rectificar los datos que sean inexactos.'),
              _buildBulletItem(l10n?.privacySection7Bullet3 ?? 'Solicitar la eliminación de sus datos cuando resulte procedente.'),
              _buildBulletItem(l10n?.privacySection7Bullet4 ?? 'Actualizar la información facilitada.'),
              _buildBulletItem(l10n?.privacySection7Bullet5 ?? 'Formular cualquier consulta relacionada con el tratamiento de sus datos.'),
              const SizedBox(height: 12),
              _buildBodyText(l10n?.privacySection7Text2 ?? 'Las solicitudes podrán realizarse mediante correo electrónico a info@getromio.app'),
              const SizedBox(height: 24),

              // Section 8
              _buildSectionTitle(l10n?.privacySection8Title ?? '8. Cookies y tecnologías similares'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.privacySection8Text ?? 'La aplicación podrá utilizar tecnologías similares a las cookies o identificadores del dispositivo con la finalidad de mejorar la experiencia de uso, analizar el funcionamiento de la plataforma y optimizar el rendimiento de la aplicación.'),
              const SizedBox(height: 24),

              // Section 9
              _buildSectionTitle(l10n?.privacySection9Title ?? '9. Cambios en la Política de Privacidad'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.privacySection9Text ?? 'Romio podrá modificar la presente Política de Privacidad en cualquier momento para adaptarla a cambios legales, técnicos o en el funcionamiento de la plataforma. Las modificaciones serán publicadas en la aplicación y entrarán en vigor desde el momento de su publicación, salvo que se indique expresamente una fecha distinta.'),
              const SizedBox(height: 24),

              // Section 10
              _buildSectionTitle(l10n?.privacySection10Title ?? '10. Contacto'),
              const SizedBox(height: 6),
              _buildBodyText(
                  l10n?.privacySection10Text ?? 'Si el usuario tiene cualquier duda sobre esta Política de Privacidad o sobre el tratamiento de sus datos personales, podrá contactar con Romio a través del correo electrónico: info@getromio.app'),
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

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyM.copyWith(
                fontSize: 14,
                height: 1.4,
                color: const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
