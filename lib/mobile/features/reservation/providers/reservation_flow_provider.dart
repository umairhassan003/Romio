import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/payment_constants.dart';
import '../../../../domain/models/reservation.dart';
import '../../../../domain/models/payment.dart';
import '../../../../domain/gateways/payment_gateway.dart';
import '../../../../domain/repositories/reservation_repository.dart';
import '../../../../domain/repositories/payment_repository.dart';

class ReservationFlowProvider extends ChangeNotifier {
  final ReservationRepository _reservationRepository;
  final PaymentRepository _paymentRepository;
  final PaymentGateway _paymentGateway;

  /// Bookable duration slots, in hours.
  static const List<int> slots = [3, 6, 24];

  // Flow state
  String? _selectedRoomId;
  String? _roomName;
  String? _hotelName;
  double _price3h = 0;
  double _price6h = 0;
  double _price24h = 0;
  bool _payOnProperty = false;
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '14:00';
  int _duration = 3;
  // 'card' (credit/debit via PayPal) or 'paypal'.
  String _selectedPaymentMethod = PaymentMethodType.card.providerKey;

  // Results
  Reservation? _confirmedReservation;
  bool _isLoading = false;
  String? _error;

  ReservationFlowProvider({
    required ReservationRepository reservationRepository,
    required PaymentRepository paymentRepository,
    required PaymentGateway paymentGateway,
  })  : _reservationRepository = reservationRepository,
        _paymentRepository = paymentRepository,
        _paymentGateway = paymentGateway;

  // Getters
  String? get selectedRoomId => _selectedRoomId;
  String? get roomName => _roomName;
  String? get hotelName => _hotelName;

  /// Whether the selected room's hotel allows reserving without upfront payment.
  bool get payOnProperty => _payOnProperty;
  DateTime get selectedDate => _selectedDate;
  String get selectedTime => _selectedTime;
  int get duration => _duration;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  Reservation? get confirmedReservation => _confirmedReservation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Price for a given booking slot (3h / 6h / 24h).
  double priceForSlot(int hours) {
    switch (hours) {
      case 3:
        return _price3h;
      case 6:
        return _price6h;
      case 24:
        return _price24h;
      default:
        return _price3h;
    }
  }

  double get totalPrice => priceForSlot(_duration);

  String get checkOutTime {
    final parts = _selectedTime.split(':');
    // Wrap around midnight (e.g. a 24h slot ends at the same clock time).
    final hour = (int.parse(parts[0]) + _duration) % 24;
    return '${hour.toString().padLeft(2, '0')}:${parts[1]}';
  }

  // Setters
  void setRoom({
    required String roomId,
    required String roomName,
    required String hotelName,
    required double price3h,
    required double price6h,
    required double price24h,
    bool payOnProperty = false,
  }) {
    _selectedRoomId = roomId;
    _roomName = roomName;
    _hotelName = hotelName;
    _price3h = price3h;
    _price6h = price6h;
    _price24h = price24h;
    _duration = 3;
    _payOnProperty = payOnProperty;
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

  /// Select one of the fixed booking slots (3h / 6h / 24h).
  void selectSlot(int hours) {
    if (slots.contains(hours)) {
      _duration = hours;
      notifyListeners();
    }
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  /// Generate a reservation code like RM-XXXX
  String _generateCode() {
    final rng = Random();
    final num = rng.nextInt(9000) + 1000;
    return 'RM-$num';
  }

  /// Charges the guest via the payment gateway, then persists the reservation
  /// and a matching payment record. Charging happens *before* the reservation
  /// is written, so a declined/failed payment never leaves an orphan booking.
  ///
  /// [card] is required when the selected method is 'card'. [onApprovalRequired]
  /// is supplied by the UI to handle the PayPal-wallet approval round-trip.
  Future<bool> confirmAndPay(
    String profileId, {
    CardDetails? card,
    PayPalApprovalCallback? onApprovalRequired,
  }) async {
    if (_selectedRoomId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final code = _generateCode();
      final method = PaymentMethodType.fromKey(_selectedPaymentMethod);

      // 1. Attempt the charge first.
      final result = await _paymentGateway.charge(
        PaymentChargeRequest(
          amount: totalPrice,
          currency: PaymentConstants.currency,
          method: method,
          reservationCode: code,
          card: method == PaymentMethodType.card ? card : null,
          onApprovalRequired: onApprovalRequired,
        ),
      );

      if (!result.isSuccess) {
        _error = result.errorMessage ?? 'Payment failed. Please try again.';
        return false;
      }

      // 2. Persist the booking + payment now that the charge succeeded.
      await _persistBooking(
        profileId: profileId,
        code: code,
        provider: method.providerKey,
        paymentStatus: result.status,
        providerReference: result.providerReference,
        paidAt: result.status == 'completed' ? DateTime.now() : null,
      );

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

  /// Creates the reservation without taking payment upfront. Only valid when
  /// the room's hotel has "Pay on Property" enabled. The payment row is
  /// recorded as pending, to be collected at the property.
  Future<bool> reserveOnProperty(String profileId) async {
    if (_selectedRoomId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _persistBooking(
        profileId: profileId,
        code: _generateCode(),
        provider: 'pay_on_property',
        paymentStatus: 'pending',
        providerReference: null,
        paidAt: null,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error reserving (pay on property): $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistBooking({
    required String profileId,
    required String code,
    required String provider,
    required String paymentStatus,
    String? providerReference,
    DateTime? paidAt,
  }) async {
    final now = DateTime.now();

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

    final createdRes =
        await _reservationRepository.createReservation(reservation);

    final payment = Payment(
      id: '',
      reservationId: createdRes.id,
      amount: totalPrice,
      currency: PaymentConstants.currency,
      provider: provider,
      status: paymentStatus,
      providerReference: providerReference,
      paidAt: paidAt,
    );

    await _paymentRepository.createPayment(payment);

    _confirmedReservation = createdRes.copyWith(
      paymentProvider: provider,
      paymentStatus: paymentStatus,
      paidAt: paidAt,
    );
  }

  /// Resets the flow for a new reservation.
  void resetFlow() {
    _selectedRoomId = null;
    _roomName = null;
    _hotelName = null;
    _price3h = 0;
    _price6h = 0;
    _price24h = 0;
    _payOnProperty = false;
    _selectedDate = DateTime.now();
    _selectedTime = '14:00';
    _duration = 3;
    _selectedPaymentMethod = PaymentMethodType.card.providerKey;
    _confirmedReservation = null;
    _error = null;
    notifyListeners();
  }
}
