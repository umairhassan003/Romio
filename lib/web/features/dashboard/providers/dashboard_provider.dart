import 'package:flutter/material.dart';
import '../../../../data/repositories/supabase_analytics_repository.dart';
import '../../../../domain/models/reservation.dart';
import '../../../../domain/models/profile.dart';

class DashboardProvider extends ChangeNotifier {
  final SupabaseAnalyticsRepository _analyticsRepo;

  DashboardProvider({required SupabaseAnalyticsRepository analyticsRepo})
      : _analyticsRepo = analyticsRepo;

  // KPI data
  int totalHotels = 0;
  int totalRooms = 0;
  int totalReservations = 0;
  int totalUsers = 0;
  double totalRevenue = 0;
  int recentReservations = 0;

  // Recent records (fetched separately for the tables)
  List<Reservation> recentReservationsList = [];
  List<Profile> recentUsersList = [];

  bool isLoading = false;
  String? error;

  Future<void> loadDashboard() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final stats = await _analyticsRepo.getDashboardStats();
      totalHotels = stats['total_hotels'] ?? 0;
      totalRooms = stats['total_rooms'] ?? 0;
      totalReservations = stats['total_reservations'] ?? 0;
      totalUsers = stats['total_users'] ?? 0;
      totalRevenue = (stats['total_revenue'] ?? 0).toDouble();
      recentReservations = stats['recent_reservations'] ?? 0;
    } catch (e) {
      error = 'Error al cargar el dashboard: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
