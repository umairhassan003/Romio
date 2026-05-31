import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../../domain/models/reservation.dart';
import '../../../../domain/models/payment.dart';
import '../../../../domain/repositories/reservation_repository.dart';
import '../../../../domain/repositories/payment_repository.dart';

class ReservationFlowProvider extends ChangeNotifier {
  final ReservationRepository _reservationRepository;
  final PaymentRepository _paymentRepository;

  // Flow state
  String? _selectedRoomId;
  String? _roomName;
  String? _hotelName;
  double _roomPricePerHour = 50.0;
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '14:00';
  int _duration = 3;
  String _selectedPaymentMethod = 'credit_card';

  // Results
  Reservation? _confirmedReservation;
  bool _isLoading = false;
  String? _error;

  ReservationFlowProvider({
    required ReservationRepository reservationRepository,
    required PaymentRepository paymentRepository,
  })  : _reservationRepository = reservationRepository,
        _paymentRepository = paymentRepository;

  // Getters
  String? get selectedRoomId => _selectedRoomId;
  String? get roomName => _roomName;
  String? get hotelName => _hotelName;
  double get roomPricePerHour => _roomPricePerHour;
  DateTime get selectedDate => _selectedDate;
  String get selectedTime => _selectedTime;
  int get duration => _duration;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  Reservation? get confirmedReservation => _confirmedReservation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalPrice => _roomPricePerHour * _duration;

  String get checkOutTime {
    final parts = _selectedTime.split(':');
    final hour = int.parse(parts[0]) + _duration;
    return '${hour.toString().padLeft(2, '0')}:${parts[1]}';
  }

  // Setters
  void setRoom({
    required String roomId,
    required String roomName,
    required String hotelName,
    required double pricePerHour,
  }) {
    _selectedRoomId = roomId;
    _roomName = roomName;
    _hotelName = hotelName;
    _roomPricePerHour = pricePerHour;
    _confirmedReservation = null;
    _error = null;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  void setDuration(int d) {
    if (d >= 1 && d <= 12) {
      _duration = d;
      notifyListeners();
    }
  }

  void incrementDuration() => setDuration(_duration + 1);
  void decrementDuration() => setDuration(_duration - 1);

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  /// Generate a reservation code like #RM-XXXX
  String _generateCode() {
    final rng = Random();
    final num = rng.nextInt(9000) + 1000;
    return 'RM-$num';
  }

  /// Creates the reservation + payment in Supabase.
  Future<bool> confirmAndPay(String profileId) async {
    if (_selectedRoomId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final code = _generateCode();

      // 1. Create reservation
      final reservation = Reservation(
        id: '',
        profileId: profileId,
        roomId: _selectedRoomId!,
        reservationCode: code,
        reservationDate: _selectedDate,
        checkInTime: _selectedTime,
        checkOutTime: checkOutTime,
        durationHours: _duration,
        totalPrice: totalPrice,
        status: 'confirmed',
        createdAt: now,
        updatedAt: now,
        roomName: _roomName,
        hotelName: _hotelName,
      );

      _confirmedReservation = await _reservationRepository.createReservation(reservation);

      // 2. Create payment record
      final payment = Payment(
        id: '',
        reservationId: _confirmedReservation!.id,
        amount: totalPrice,
        currency: 'USD',
        provider: _selectedPaymentMethod,
        status: 'completed',
        paidAt: now,
      );

      await _paymentRepository.createPayment(payment);

      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error confirming reservation: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resets the flow for a new reservation.
  void resetFlow() {
    _selectedRoomId = null;
    _roomName = null;
    _hotelName = null;
    _roomPricePerHour = 50.0;
    _selectedDate = DateTime.now();
    _selectedTime = '14:00';
    _duration = 3;
    _selectedPaymentMethod = 'credit_card';
    _confirmedReservation = null;
    _error = null;
    notifyListeners();
  }
}
