import '../models/payment.dart';

abstract class PaymentRepository {
  Future<Payment> createPayment(Payment payment);
  Future<Payment?> getPaymentByReservation(String reservationId);
}
