import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/payment.dart';
import '../../domain/repositories/payment_repository.dart';

class SupabasePaymentRepository implements PaymentRepository {
  final SupabaseClient _supabaseClient;
  static const String tableName = 'payments';

  SupabasePaymentRepository({SupabaseClient? client})
      : _supabaseClient = client ?? Supabase.instance.client;

  @override
  Future<Payment> createPayment(Payment payment) async {
    final json = payment.toJson();
    // Let DB generate the id
    if (json['id'] == '' || json['id'] == null) {
      json.remove('id');
    }

    final response = await _supabaseClient
        .from(tableName)
        .insert(json)
        .select()
        .single();

    return Payment.fromJson(response);
  }

  @override
  Future<Payment?> getPaymentByReservation(String reservationId) async {
    final response = await _supabaseClient
        .from(tableName)
        .select()
        .eq('reservation_id', reservationId)
        .maybeSingle();

    if (response == null) return null;
    return Payment.fromJson(response);
  }
}
