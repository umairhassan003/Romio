import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../domain/models/payment.dart';

class PaymentAdminProvider extends ChangeNotifier {
  List<Payment> payments = [];
  Payment? selectedPayment;
  int totalCount = 0;
  int currentPage = 0;
  int pageSize = 25;
  String? filterStatus;
  String? filterProvider;

  bool isLoading = false;
  String? error;

  double totalCollected = 0;
  double totalPending = 0;
  double totalRefunded = 0;

  Future<void> loadPayments() async {
    isLoading = true; error = null; notifyListeners();
    try {
      final client = Supabase.instance.client;
      var query = client
          .from('payments')
          .select('*, reservations(reservation_code, profiles(first_name, last_name))');

      if (filterStatus != null) query = query.eq('status', filterStatus!);
      if (filterProvider != null) query = query.eq('provider', filterProvider!);

      // Count query
      try {
        var countQ = client.from('payments').select('id');
        if (filterStatus != null) countQ = countQ.eq('status', filterStatus!);
        final countResult = await countQ.count(CountOption.exact);
        totalCount = countResult.count;
      } catch (_) {
        totalCount = 0;
      }

      final response = await query
          .range(currentPage * pageSize, (currentPage + 1) * pageSize - 1)
          .order('created_at', ascending: false);

      payments = [];
      for (final j in (response as List)) {
        try {
          payments.add(Payment.fromJson(j));
        } catch (_) {
          // Skip malformed rows
        }
      }

      // Summary calculations
      try {
        final allPayments = await client.from('payments').select('amount, status');
        totalCollected = 0; totalPending = 0; totalRefunded = 0;
        for (final p in allPayments) {
          final amount = (p['amount'] as num?)?.toDouble() ?? 0;
          switch (p['status']) {
            case 'completed': totalCollected += amount;
            case 'pending': totalPending += amount;
            case 'refunded': totalRefunded += amount;
          }
        }
      } catch (_) {
        // Summary calc failure shouldn't block the page
      }
    } catch (e) {
      error = 'Error al cargar pagos: $e';
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> loadPaymentById(String id) async {
    isLoading = true; error = null; notifyListeners();
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('payments')
          .select('*, reservations(*, profiles(first_name, last_name), rooms(name, hotels(name)))')
          .eq('id', id)
          .maybeSingle();
      if (response != null) {
        selectedPayment = Payment.fromJson(response);
      }
    } catch (e) {
      error = 'Error al cargar pago: $e';
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> updatePaymentStatus(String id, String status) async {
    try {
      final client = Supabase.instance.client;
      await client.from('payments').update({'status': status}).eq('id', id);
      await loadPayments();
    } catch (e) {
      error = 'Error al actualizar estado: $e';
      notifyListeners();
    }
  }

  void setPage(int p) { currentPage = p; loadPayments(); }
  void setFilterStatus(String? s) { filterStatus = s; currentPage = 0; loadPayments(); }
  void setFilterProvider(String? p) { filterProvider = p; currentPage = 0; loadPayments(); }
}
