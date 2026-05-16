class HotelImage {
  final String id;
  final String hotelId;
  final String storageUrl;
  final int sortOrder;

  const HotelImage({
    required this.id,
    required this.hotelId,
    required this.storageUrl,
    this.sortOrder = 0,
  });

  factory HotelImage.fromJson(Map<String, dynamic> json) {
    return HotelImage(
      id: json['id'] as String,
      hotelId: json['hotel_id'] as String,
      storageUrl: json['storage_url'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'storage_url': storageUrl,
      'sort_order': sortOrder,
    };
  }

  HotelImage copyWith({
    String? id,
    String? hotelId,
    String? storageUrl,
    int? sortOrder,
  }) {
    return HotelImage(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      storageUrl: storageUrl ?? this.storageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
