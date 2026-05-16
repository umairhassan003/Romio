class Payment {
  final String id;
  final String reservationId;
  final String? paymentMethodId;
  final double amount;
  final String currency;
  final String provider;  // e.g. 'stripe', 'paypal'
  final String status;
  final String? providerReference;
  final DateTime? paidAt;

  const Payment({
    required this.id,
    required this.reservationId,
    this.paymentMethodId,
    required this.amount,
    this.currency = 'USD',
    this.provider = 'unknown',
    this.status = 'pending',
    this.providerReference,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      reservationId: json['reservation_id'] as String,
      paymentMethodId: json['payment_method_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      provider: json['provider'] as String? ?? 'unknown',
      status: json['status'] as String? ?? 'pending',
      providerReference: json['provider_reference'] as String?,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': reservationId,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      'amount': amount,
      'currency': currency,
      'provider': provider,
      'status': status,
      if (providerReference != null) 'provider_reference': providerReference,
      if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
    };
  }

  Payment copyWith({
    String? id,
    String? reservationId,
    String? paymentMethodId,
    double? amount,
    String? currency,
    String? provider,
    String? status,
    String? providerReference,
    DateTime? paidAt,
  }) {
    return Payment(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      providerReference: providerReference ?? this.providerReference,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
