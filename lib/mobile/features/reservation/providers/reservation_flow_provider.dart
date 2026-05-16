import 'package:flutter/foundation.dart';
import '../../../../domain/models/reservation.dart';
import '../../../../domain/repositories/reservation_repository.dart';

class ReservationFlowProvider extends ChangeNotifier {
  final ReservationRepository _reservationRepository;

  // Track draft state
  Reservation? _draftReservation;
  bool _isLoading = false;

  ReservationFlowProvider({
    required ReservationRepository reservationRepository,
  }) : _reservationRepository = reservationRepository;

  Reservation? get draftReservation => _draftReservation;
  bool get isLoading => _isLoading;

  void setDraft(Reservation reservation) {
    _draftReservation = reservation;
    notifyListeners();
  }

  Future<Reservation?> confirmReservation() async {
    if (_draftReservation == null) return null;
    
    _isLoading = true;
    notifyListeners();

    try {
      final newRes = await _reservationRepository.createReservation(_draftReservation!);
      _draftReservation = null; // Clear draft on success
      return newRes;
    } catch (e) {
      debugPrint('Error confirming reservation: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
