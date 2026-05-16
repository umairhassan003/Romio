import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../domain/models/reservation.dart';
import '../../../../data/repositories/supabase_reservation_repository.dart';

class ReservationAdminProvider extends ChangeNotifier {
  final SupabaseReservationRepository _repo;

  ReservationAdminProvider({required SupabaseReservationRepository repo}) : _repo = repo;

  List<Reservation> reservations = [];
  Reservation? selectedReservation;
  int totalCount = 0;
  int currentPage = 0;
  int pageSize = 25;
  String? filterStatus;
  DateTime? filterStartDate;
  DateTime? filterEndDate;

  bool isLoading = false;
  String? error;

  Future<void> loadReservations() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final client = Supabase.instance.client;
      var query = client
          .from('reservations')
          .select('*, rooms(name, hotels(name)), profiles(first_name, last_name)');

      if (filterStatus != null) query = query.eq('status', filterStatus!);
      if (filterStartDate != null) {
        query = query.gte('reservation_date', filterStartDate!.toIso8601String().split('T')[0]);
      }
      if (filterEndDate != null) {
        query = query.lte('reservation_date', filterEndDate!.toIso8601String().split('T')[0]);
      }

      final countQuery = client.from('reservations').select('id');
      final countResult = await (filterStatus != null ? countQuery.eq('status', filterStatus!) : countQuery).count(CountOption.exact);
      totalCount = countResult.count;

      final response = await query
          .range(currentPage * pageSize, (currentPage + 1) * pageSize - 1)
          .order('created_at', ascending: false);

      reservations = (response as List).map((j) => Reservation.fromJson(j)).toList();
    } catch (e) {
      error = 'Error al cargar reservas: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReservationById(String id) async {
    isLoading = true; error = null; notifyListeners();
    try {
      selectedReservation = await _repo.getReservationById(id);
    } catch (e) {
      error = 'Error al cargar reserva: $e';
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _repo.updateReservationStatus(id, status);
      await loadReservations();
    } catch (e) {
      error = 'Error al actualizar estado: $e';
      notifyListeners();
    }
  }

  void setPage(int p) { currentPage = p; loadReservations(); }
  void setFilterStatus(String? s) { filterStatus = s; currentPage = 0; loadReservations(); }
  void setDateRange(DateTime? start, DateTime? end) {
    filterStartDate = start; filterEndDate = end; currentPage = 0; loadReservations();
  }
}
