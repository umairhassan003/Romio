import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service that invokes the `send-email` Supabase Edge Function to deliver
/// transactional emails (reservation notifications and confirmations).
///
/// Email sending is non-blocking — failures are logged but never bubble up
/// to the caller so they don't disrupt the booking flow.
class EmailService {
  final SupabaseClient _supabaseClient;

  EmailService({SupabaseClient? client})
    : _supabaseClient = client ?? Supabase.instance.client;

  /// Send a reservation notification email to the hotel.
  Future<void> sendReservationToHotel({
    required String hotelEmail,
    required String reservationCode,
    required String clientName,
    required String roomName,
    required String date,
    required String checkIn,
    required String checkOut,
  }) async {
    await _invoke(
      type: 'reservation_hotel',
      to: hotelEmail,
      data: {
        'reservation_code': reservationCode,
        'client_name': clientName,
        'room_name': roomName,
        'date': date,
        'check_in': checkIn,
        'check_out': checkOut,
      },
    );
  }

  /// Send a reservation confirmation email to the client.
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
    await _invoke(
      type: 'reservation_client',
      to: clientEmail,
      data: {
        'reservation_code': reservationCode,
        'client_name': clientName,
        'hotel_name': hotelName,
        'hotel_address': hotelAddress,
        'room_name': roomName,
        'date': date,
        'check_in': checkIn,
        'check_out': checkOut,
        'total_price': totalPrice,
        if (roomImageUrl != null) 'room_image_url': roomImageUrl,
      },
    );
  }

  /// Internal helper to invoke the Edge Function.
  Future<void> _invoke({
    required String type,
    required String to,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'send-email',
        body: {'type': type, 'to': to, 'data': data},
      );

      if (response.status != 200) {
        debugPrint('EmailService: Edge function returned ${response.status}');
      } else {
        debugPrint('EmailService: $type email sent to $to');
      }
    } catch (e) {
      // Non-blocking — log the error but don't rethrow.
      debugPrint('EmailService: Failed to send $type email to $to: $e');
    }
  }
}
