class Reservation {
  final String id;
  final String profileId;
  final String roomId;
  final String reservationCode;
  final DateTime reservationDate;
  final String checkInTime;
  final String checkOutTime;
  final int durationHours;
  final double totalPrice;
  final String status;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reservation({
    required this.id,
    required this.profileId,
    required this.roomId,
    required this.reservationCode,
    required this.reservationDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.durationHours,
    required this.totalPrice,
    this.status = 'pending',
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      roomId: json['room_id'] as String,
      reservationCode: json['reservation_code'] as String,
      reservationDate: DateTime.parse(json['reservation_date']),
      checkInTime: json['check_in_time'] as String,
      checkOutTime: json['check_out_time'] as String,
      durationHours: json['duration_hours'] as int,
      totalPrice: (json['total_price'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'room_id': roomId,
      'reservation_code': reservationCode,
      'reservation_date': reservationDate.toIso8601String().split('T')[0],
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'duration_hours': durationHours,
      'total_price': totalPrice,
      'status': status,
      if (cancelledAt != null) 'cancelled_at': cancelledAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Reservation copyWith({
    String? id,
    String? profileId,
    String? roomId,
    String? reservationCode,
    DateTime? reservationDate,
    String? checkInTime,
    String? checkOutTime,
    int? durationHours,
    double? totalPrice,
    String? status,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      roomId: roomId ?? this.roomId,
      reservationCode: reservationCode ?? this.reservationCode,
      reservationDate: reservationDate ?? this.reservationDate,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      durationHours: durationHours ?? this.durationHours,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
