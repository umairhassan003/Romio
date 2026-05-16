class SavedHotel {
  final String profileId;
  final String hotelId;
  final DateTime savedAt;

  const SavedHotel({
    required this.profileId,
    required this.hotelId,
    required this.savedAt,
  });

  factory SavedHotel.fromJson(Map<String, dynamic> json) {
    return SavedHotel(
      profileId: json['profile_id'] as String,
      hotelId: json['hotel_id'] as String,
      savedAt: DateTime.parse(json['saved_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'hotel_id': hotelId,
      'saved_at': savedAt.toIso8601String(),
    };
  }

  SavedHotel copyWith({
    String? profileId,
    String? hotelId,
    DateTime? savedAt,
  }) {
    return SavedHotel(
      profileId: profileId ?? this.profileId,
      hotelId: hotelId ?? this.hotelId,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
