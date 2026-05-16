class ReservationReminder {
  final String id;
  final String reservationId;
  final bool isEnabled;
  final DateTime? remindAt;
  final bool sent;
  final DateTime createdAt;

  const ReservationReminder({
    required this.id,
    required this.reservationId,
    this.isEnabled = false,
    this.remindAt,
    this.sent = false,
    required this.createdAt,
  });

  factory ReservationReminder.fromJson(Map<String, dynamic> json) {
    return ReservationReminder(
      id: json['id'] as String,
      reservationId: json['reservation_id'] as String,
      isEnabled: json['is_enabled'] as bool? ?? false,
      remindAt: json['remind_at'] != null ? DateTime.parse(json['remind_at']) : null,
      sent: json['sent'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': reservationId,
      'is_enabled': isEnabled,
      if (remindAt != null) 'remind_at': remindAt!.toIso8601String(),
      'sent': sent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ReservationReminder copyWith({
    String? id,
    String? reservationId,
    bool? isEnabled,
    DateTime? remindAt,
    bool? sent,
    DateTime? createdAt,
  }) {
    return ReservationReminder(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      isEnabled: isEnabled ?? this.isEnabled,
      remindAt: remindAt ?? this.remindAt,
      sent: sent ?? this.sent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
