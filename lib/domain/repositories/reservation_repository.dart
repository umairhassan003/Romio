import '../models/reservation.dart';

abstract class ReservationRepository {
  Future<Reservation> createReservation(Reservation reservation);
  Future<List<Reservation>> getUserReservations(String profileId);
  Future<Reservation?> getReservationById(String id);
  Future<Reservation> updateReservationStatus(String id, String status);
}
