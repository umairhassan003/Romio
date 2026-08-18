import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../../core/constants/smtp_constants.dart';
import 'smtp_credential_store.dart';

/// Sends transactional emails (reservation confirmation + hotel notification)
/// directly via SMTP using the porkbun mail server.
///
/// All sends are non-blocking — failures are logged but never bubble up so
/// they cannot disrupt the booking flow.
class EmailService {
  final SmtpCredentialStore _credentialStore;

  EmailService({SmtpCredentialStore? credentialStore})
      : _credentialStore = credentialStore ?? SmtpCredentialStore();

  // ─── Brand constants ─────────────────────────────────────────────
  static const _brandColor = '#6D0B3E';
  static const _brandLight = '#F2DBE6';
  static const _brandBg = '#FFFFFF';
  static const _brandText = '#1A1A1A';
  static const _brandSecondary = '#6B6B6B';
  static const _logoUrl =
      'https://hjpxiekxyuovzqaffmen.supabase.co/storage/v1/object/public/romio/logo.svg';

  // ─── Public API ───────────────────────────────────────────────────

  Future<void> sendReservationToClient({
    required String clientEmail,
    required String reservationCode,
    required String clientName,
    required String hotelName,
    required String hotelAddress,
    required String roomName,
    required String date,
    required String checkIn,
    required String checkOut,
    required String totalPrice,
    String? roomImageUrl,
  }) async {
    final subject = 'Reserva confirmada – $reservationCode';
    final html = _buildClientEmail(
      reservationCode: reservationCode,
      clientName: clientName,
      hotelName: hotelName,
      hotelAddress: hotelAddress,
      roomName: roomName,
      date: date,
      checkIn: checkIn,
      checkOut: checkOut,
      totalPrice: totalPrice,
      roomImageUrl: roomImageUrl,
    );
    await _send(to: clientEmail, subject: subject, html: html);
  }

  Future<void> sendReservationToHotel({
    required String hotelEmail,
    required String reservationCode,
    required String clientName,
    required String roomName,
    required String date,
    required String checkIn,
    required String checkOut,
  }) async {
    final subject = 'Nueva reserva – $reservationCode';
    final html = _buildHotelEmail(
      reservationCode: reservationCode,
      clientName: clientName,
      roomName: roomName,
      date: date,
      checkIn: checkIn,
      checkOut: checkOut,
    );
    await _send(to: hotelEmail, subject: subject, html: html);
  }

  // ─── SMTP send ────────────────────────────────────────────────────

  Future<void> _send({
    required String to,
    required String subject,
    required String html,
  }) async {
    final password = await _credentialStore.getPassword();
    debugPrint('EmailService: connecting to ${SmtpConstants.host}:${SmtpConstants.port} '
        'as ${SmtpConstants.username} (password set: ${password.isNotEmpty}) → to: $to');

    final message = Message()
      ..from = Address(SmtpConstants.fromAddress, SmtpConstants.fromName)
      ..recipients.add(to)
      ..subject = subject
      ..html = html;

    try {
      final server = SmtpServer(
        SmtpConstants.host,
        port: SmtpConstants.port,
        ssl: false,
        username: SmtpConstants.username,
        password: password,
      );
      await send(message, server);
      debugPrint('EmailService: ✓ email sent to $to');
    } catch (e, stack) {
      debugPrint('EmailService: ✗ SMTP failed → $e');
      debugPrint('EmailService: stack → $stack');
    }
  }

  // ─── HTML templates ───────────────────────────────────────────────

  String _wrapHtml(String body) => '''
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Romio</title>
  <style>
    body { margin: 0; padding: 0; background-color: #F5F5F5; font-family: 'Helvetica Neue', Arial, sans-serif; }
    .container { max-width: 600px; margin: 0 auto; background-color: $_brandBg; }
    .header { background: linear-gradient(135deg, $_brandColor, #8B1A5A); padding: 32px; text-align: center; }
    .content { padding: 40px 32px; color: $_brandText; line-height: 1.6; }
    .content h2 { color: $_brandColor; font-size: 22px; margin-top: 0; }
    .content p { font-size: 15px; margin: 12px 0; }
    .detail-card { background: #FDF0F5; border-radius: 12px; padding: 24px; margin: 24px 0; border-left: 4px solid $_brandColor; }
    .info-box { background: #F7F7F7; border-radius: 12px; padding: 20px; margin: 24px 0; }
    .info-box h3 { color: $_brandColor; font-size: 16px; margin: 0 0 12px 0; }
    .info-box p { font-size: 13px; color: $_brandSecondary; margin: 8px 0; }
    .footer { background: #F7F7F7; padding: 24px 32px; text-align: center; border-top: 1px solid #E8D5DE; }
    .footer p { font-size: 12px; color: $_brandSecondary; margin: 4px 0; }
    .hotel-image { width: 100%; max-height: 250px; object-fit: cover; border-radius: 12px; margin: 16px 0; }
    .reservation-code { background: $_brandColor; color: #FFFFFF; display: inline-block; padding: 8px 20px; border-radius: 8px; font-size: 18px; font-weight: 700; letter-spacing: 1px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <img src="$_logoUrl" alt="Romio" width="160" height="48" />
    </div>
    <div class="content">$body</div>
    <div class="footer">
      <p>Romio App</p>
      <p>Romio protege tus datos personales. Consulta nuestra política de privacidad desde la app.</p>
    </div>
  </div>
</body>
</html>''';

  String _buildHotelEmail({
    required String reservationCode,
    required String clientName,
    required String roomName,
    required String date,
    required String checkIn,
    required String checkOut,
  }) =>
      _wrapHtml('''
    <h2>Nueva reserva recibida</h2>
    <p>Hola,</p>
    <p>Has recibido una nueva reserva a través de <strong>Romio</strong>.</p>
    <div class="detail-card">
      <h3 style="color: $_brandColor; margin-top: 0; margin-bottom: 16px;">Detalles de la reserva</h3>
      <table width="100%" cellpadding="0" cellspacing="0" style="font-size: 14px;">
        <tr>
          <td style="padding: 8px 0; color: $_brandSecondary; border-bottom: 1px solid $_brandLight;">Cliente</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid $_brandLight;">$clientName</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: $_brandSecondary; border-bottom: 1px solid $_brandLight;">Habitación</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid $_brandLight;">$roomName</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: $_brandSecondary; border-bottom: 1px solid $_brandLight;">Fecha</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid $_brandLight;">$date</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: $_brandSecondary;">Horario</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600;">$checkIn – $checkOut</td>
        </tr>
      </table>
    </div>
    <p>Por favor, asegúrate de mantener la habitación disponible según las condiciones acordadas.</p>
    <p style="margin-top: 24px;">Gracias por colaborar con nosotros,<br><strong>Equipo Romio</strong></p>
''');

  String _buildClientEmail({
    required String reservationCode,
    required String clientName,
    required String hotelName,
    required String hotelAddress,
    required String roomName,
    required String date,
    required String checkIn,
    required String checkOut,
    required String totalPrice,
    String? roomImageUrl,
  }) {
    final imageHtml = roomImageUrl != null
        ? '<img src="$roomImageUrl" alt="Hotel" class="hotel-image" />'
        : '';
    return _wrapHtml('''
    <h2>¡Tu reserva está confirmada! 💜</h2>
    <p>Hola $clientName,</p>
    <p>Gracias por elegir <strong>Romio</strong> para tu próxima experiencia.</p>
    <p style="text-align: center; margin: 24px 0;">
      <span class="reservation-code">$reservationCode</span>
    </p>
    $imageHtml
    <div class="detail-card">
      <h3 style="color: $_brandColor; margin-top: 0; margin-bottom: 16px;">Detalles de tu reserva</h3>
      <table width="100%" cellpadding="0" cellspacing="0" style="font-size: 14px;">
        <tr>
          <td style="padding: 8px 0; color: $_brandSecondary; border-bottom: 1px solid $_brandLight;">Hotel</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid $_brandLight;">$hotelName</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: $_brandSecondary; border-bottom: 1px solid $_brandLight;">Dirección</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid $_brandLight;">$hotelAddress</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: $_brandSecondary; border-bottom: 1px solid $_brandLight;">Reserva a nombre de</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid $_brandLight;">$clientName</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: $_brandSecondary; border-bottom: 1px solid $_brandLight;">Habitación</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid $_brandLight;">$roomName</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: $_brandSecondary; border-bottom: 1px solid $_brandLight;">Fecha</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid $_brandLight;">$date</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: $_brandSecondary; border-bottom: 1px solid $_brandLight;">Horario</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; border-bottom: 1px solid $_brandLight;">$checkIn – $checkOut</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: $_brandSecondary;">Precio total</td>
          <td style="padding: 8px 0; text-align: right; font-weight: 600; color: $_brandColor;">\$$totalPrice</td>
        </tr>
      </table>
    </div>
    <div class="info-box">
      <h3>📋 Información importante</h3>
      <p><strong>Hora de llegada</strong><br>Te recomendamos llegar puntualmente a la hora indicada.</p>
      <p><strong>Cancelación</strong><br>Puedes cancelar sin costo hasta 24 horas antes del inicio.</p>
      <p><strong>No show</strong><br>Si no te presentas ni cancelas en plazo, la reserva se considerará utilizada.</p>
      <p><strong>Documento de identidad</strong><br>Presenta un documento de identidad válido en el check-in.</p>
    </div>
    <p>El hotel ya ha sido notificado y te estará esperando.</p>
    <p>¿Dudas? Escríbenos a <a href="mailto:info@getromio.app" style="color: $_brandColor;">info@getromio.app</a></p>
    <p style="margin-top: 24px;">Disfruta el momento. Nosotros nos encargamos del resto. 💜<br><strong>Romio App</strong></p>
''');
  }
}
