import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/payment_constants.dart';
import '../../../../core/constants/notification_constants.dart';
import '../../../../data/services/email_service.dart';
import '../../../../domain/models/hotel.dart';
import '../../../../domain/models/reservation.dart';
import '../../../../domain/models/payment.dart';
import '../../../../domain/gateways/payment_gateway.dart';
import '../../../../domain/repositories/reservation_repository.dart';
import '../../../../domain/repositories/payment_repository.dart';

class ReservationFlowProvider extends ChangeNotifier {
  final ReservationRepository _reservationRepository;
  final PaymentRepository _paymentRepository;
  final PaymentGateway _paymentGateway;
  final EmailService _emailService;

  static const List<String> _allTimes = [
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
  ];

  // Flow state
  String? _selectedRoomId;
  String? _roomName;
  String? _hotelName;
  String? _hotelAddress;
  String? _roomImageUrl;
  double? _price3h;
  double? _price6h;
  double? _price24h;
  HotelPaymentMode _paymentMode = HotelPaymentMode.payAtApp;
  double? _partialPercent3h;
  double? _partialPercent6h;
  double? _partialPercent24h;
  String? _checkInTime;
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '14:00';
  int _duration = 3;
  String _selectedPaymentMethod = PaymentMethodType.card.providerKey;

  // Results
  Reservation? _confirmedReservation;
  bool _isLoading = false;
  String? _error;

  ReservationFlowProvider({
    required ReservationRepository reservationRepository,
    required PaymentRepository paymentRepository,
    required PaymentGateway paymentGateway,
    required EmailService emailService,
  }) : _reservationRepository = reservationRepository,
       _paymentRepository = paymentRepository,
       _paymentGateway = paymentGateway,
       _emailService = emailService;

  // Getters
  String? get selectedRoomId => _selectedRoomId;
  String? get roomName => _roomName;
  String? get hotelName => _hotelName;
  HotelPaymentMode get paymentMode => _paymentMode;

  /// Whether the guest settles the full amount at the property (no online pay).
  bool get isPayAtProperty => _paymentMode == HotelPaymentMode.payAtProperty;

  /// Whether the guest must pay the full amount online up front.
  bool get isPayAtApp => _paymentMode == HotelPaymentMode.payAtApp;

  /// Whether the guest pays a deposit online and the rest at the property.
  bool get isPayPartial => _paymentMode == HotelPaymentMode.payPartial;

  DateTime get selectedDate => _selectedDate;
  String get selectedTime => _selectedTime;
  int get duration => _duration;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  Reservation? get confirmedReservation => _confirmedReservation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Slots (in hours) that have a configured price — only these are shown in the UI.
  List<int> get availableSlots {
    final result = <int>[];
    if (_price3h != null) result.add(3);
    if (_price6h != null) result.add(6);
    if (_price24h != null) result.add(24);
    return result;
  }

  /// Times the guest can select, filtered by the hotel's check-in start time.
  /// The stored check-in time may include seconds ('HH:mm:ss'); normalize it
  /// to 'HH:mm' so the boundary slot (equal to check-in) is kept.
  List<String> get availableTimes {
    if (_checkInTime == null || _checkInTime!.isEmpty) return _allTimes;
    final normalized =
        _checkInTime!.length >= 5 ? _checkInTime!.substring(0, 5) : _checkInTime!;
    return _allTimes.where((t) => t.compareTo(normalized) >= 0).toList();
  }

  /// Price for a given booking slot (3h / 6h / 24h). Returns 0 for unconfigured slots.
  double priceForSlot(int hours) {
    switch (hours) {
      case 3:
        return _price3h ?? 0;
      case 6:
        return _price6h ?? 0;
      case 24:
        return _price24h ?? 0;
      default:
        return _price3h ?? 0;
    }
  }

  double get totalPrice => priceForSlot(_duration);

  /// Deposit percentage (0–100) configured for the currently selected slot when
  /// the hotel uses partial payment. Returns 0 when not applicable/configured.
  double get partialPercentForSlot {
    switch (_duration) {
      case 3:
        return _partialPercent3h ?? 0;
      case 6:
        return _partialPercent6h ?? 0;
      case 24:
        return _partialPercent24h ?? 0;
      default:
        return _partialPercent3h ?? 0;
    }
  }

  /// Amount the guest pays online now:
  /// - pay at property → 0 (nothing charged online)
  /// - pay at app      → the full price
  /// - pay partial     → the deposit (price × slot percentage)
  double get amountDueNow {
    switch (_paymentMode) {
      case HotelPaymentMode.payAtProperty:
        return 0;
      case HotelPaymentMode.payAtApp:
        return totalPrice;
      case HotelPaymentMode.payPartial:
        return _round2(totalPrice * partialPercentForSlot / 100);
    }
  }

  /// Amount still to be collected at the property (full price for pay at
  /// property, the remainder for pay partial, 0 for pay at app).
  double get balanceDueAtProperty => _round2(totalPrice - amountDueNow);

  double _round2(double v) => (v * 100).roundToDouble() / 100;

  String get checkOutTime {
    final parts = _selectedTime.split(':');
    final hour = (int.parse(parts[0]) + _duration) % 24;
    return '${hour.toString().padLeft(2, '0')}:${parts[1]}';
  }

  // Setters
  void setRoom({
    required String roomId,
    required String roomName,
    required String hotelName,
    String? hotelAddress,
    String? roomImageUrl,
    double? price3h,
    double? price6h,
    double? price24h,
    HotelPaymentMode paymentMode = HotelPaymentMode.payAtApp,
    double? partialPercent3h,
    double? partialPercent6h,
    double? partialPercent24h,
    String? checkInTime,
  }) {
    _selectedRoomId = roomId;
    _roomName = roomName;
    _hotelName = hotelName;
    _hotelAddress = hotelAddress;
    _roomImageUrl = roomImageUrl;
    _price3h = price3h;
    _price6h = price6h;
    _price24h = price24h;
    _paymentMode = paymentMode;
    _partialPercent3h = partialPercent3h;
    _partialPercent6h = partialPercent6h;
    _partialPercent24h = partialPercent24h;
    _checkInTime = checkInTime;
    // Default to first available slot
    final slots = availableSlots;
    _duration = slots.isNotEmpty ? slots.first : 3;
    // Default to first available check-in time
    final times = availableTimes;
    _selectedTime = times.isNotEmpty ? times.first : '14:00';
    _confirmedReservation = null;
    _error = null;
    // notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  /// Select one of the available booking slots.
  void selectSlot(int hours) {
    if (availableSlots.contains(hours)) {
      _duration = hours;
      notifyListeners();
    }
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  String _generateCode() {
    final rng = Random();
    final num = rng.nextInt(9000) + 1000;
    return 'RM-$num';
  }

  Future<bool> confirmAndPay(
    String profileId, {
    required String clientEmail,
    required String clientName,
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

      // For pay-partial only the deposit is charged online; the balance is
      // collected at the property. For pay-at-app the full price is charged.
      final chargeAmount = amountDueNow;

      final result = await _paymentGateway.charge(
        PaymentChargeRequest(
          amount: chargeAmount,
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

      await _persistBooking(
        profileId: profileId,
        code: code,
        provider: method.providerKey,
        paymentStatus: result.status,
        paymentAmount: chargeAmount,
        depositAmount: chargeAmount,
        balanceDue: balanceDueAtProperty,
        providerReference: result.providerReference,
        paidAt: result.status == 'completed' ? DateTime.now() : null,
        clientEmail: clientEmail,
        clientName: clientName,
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
        paymentAmount: totalPrice,
        depositAmount: 0,
        balanceDue: totalPrice,
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
    required double paymentAmount,
    required double depositAmount,
    required double balanceDue,
    String? providerReference,
    DateTime? paidAt,
    String clientEmail = '',
    String clientName = '',
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
      paymentMode: _paymentMode.dbValue,
      depositAmount: depositAmount,
      balanceDue: balanceDue,
      status: 'confirmed',
      createdAt: now,
      updatedAt: now,
      roomName: _roomName,
      hotelName: _hotelName,
    );

    final createdRes = await _reservationRepository.createReservation(
      reservation,
    );

    final payment = Payment(
      id: '',
      reservationId: createdRes.id,
      amount: paymentAmount,
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

    // Only a completed (paid) booking triggers the confirmation emails — the
    // guest is told "payment confirmed", so pending / pay-on-property bookings
    // are intentionally excluded here.
    if (paymentStatus == 'completed') {
      _sendConfirmationEmails(
        code: code,
        clientEmail: clientEmail,
        clientName: clientName,
      );
    }
  }

  /// Fires the guest confirmation and hotel notification emails after a paid
  /// booking. Non-blocking on purpose: the sends are never awaited and
  /// [EmailService] swallows its own errors, so a mail failure can never affect
  /// the booking result or delay navigation to the confirmation screen.
  void _sendConfirmationEmails({
    required String code,
    required String clientEmail,
    required String clientName,
  }) {
    final date = _formatDate(_selectedDate);
    final displayName = clientName.trim().isNotEmpty ? clientName.trim() : clientEmail;

    if (clientEmail.isNotEmpty) {
      unawaited(
        _emailService.sendReservationToClient(
          clientEmail: clientEmail,
          reservationCode: code,
          clientName: displayName,
          hotelName: _hotelName ?? '',
          hotelAddress: _hotelAddress ?? '',
          roomName: _roomName ?? '',
          date: date,
          checkIn: _selectedTime,
          checkOut: checkOutTime,
          totalPrice: totalPrice.toStringAsFixed(2),
          roomImageUrl: _roomImageUrl,
        ),
      );
    }

    unawaited(
      _emailService.sendReservationToHotel(
        hotelEmail: NotificationConstants.hotelNotificationEmail,
        reservationCode: code,
        clientName: displayName,
        roomName: _roomName ?? '',
        date: date,
        checkIn: _selectedTime,
        checkOut: checkOutTime,
      ),
    );
  }

  /// Formats a booking date as dd/MM/yyyy for the notification emails.
  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  void resetFlow() {
    _selectedRoomId = null;
    _roomName = null;
    _hotelName = null;
    _hotelAddress = null;
    _roomImageUrl = null;
    _price3h = null;
    _price6h = null;
    _price24h = null;
    _paymentMode = HotelPaymentMode.payAtApp;
    _partialPercent3h = null;
    _partialPercent6h = null;
    _partialPercent24h = null;
    _checkInTime = null;
    _selectedDate = DateTime.now();
    _selectedTime = '14:00';
    _duration = 3;
    _selectedPaymentMethod = PaymentMethodType.card.providerKey;
    _confirmedReservation = null;
    _error = null;
    notifyListeners();
  }
}
