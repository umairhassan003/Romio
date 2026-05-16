import 'package:flutter/foundation.dart';
import '../../../../domain/models/reservation.dart';
import '../../../../domain/repositories/reservation_repository.dart';

class MyReservationsProvider extends ChangeNotifier {
  final ReservationRepository _reservationRepository;

  List<Reservation> _reservations = [];
  bool _isLoading = false;

  MyReservationsProvider({
    required ReservationRepository reservationRepository,
  }) : _reservationRepository = reservationRepository;

  List<Reservation> get reservations => _reservations;
  bool get isLoading => _isLoading;

  Future<void> loadUserReservations(String profileId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _reservations = await _reservationRepository.getUserReservations(profileId);
    } catch (e) {
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
