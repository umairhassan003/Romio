import 'package:flutter/foundation.dart';
import '../../../../domain/models/reservation.dart';
import '../../../../domain/repositories/reservation_repository.dart';

class MyReservationsProvider extends ChangeNotifier {
  final ReservationRepository _reservationRepository;

  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String? _error;

  // Track reminder state per reservation ID
  final Map<String, bool> _reminders = {};

  MyReservationsProvider({
    required ReservationRepository reservationRepository,
  }) : _reservationRepository = reservationRepository;

  List<Reservation> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Only upcoming/active reservations.
  List<Reservation> get upcomingReservations =>
      _reservations.where((r) => r.status != 'cancelled' && r.status != 'completed').toList();

  bool isReminderEnabled(String reservationId) => _reminders[reservationId] ?? true;

  void toggleReminder(String reservationId, bool enabled) {
    _reminders[reservationId] = enabled;
    notifyListeners();
  }

  Future<void> loadUserReservations(String profileId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await _reservationRepository.getUserReservations(profileId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading reservations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelReservation(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedStr = await _reservationRepository.updateReservationStatus(id, 'cancelled');
      final index = _reservations.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reservations[index] = updatedStr;
      }
      return true;
    } catch (e) {
      debugPrint('Error cancelling reservation: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
