class RoomImage {
  final String id;
  final String roomId;
  final String storageUrl;
  final int sortOrder;

  const RoomImage({
    required this.id,
    required this.roomId,
    required this.storageUrl,
    this.sortOrder = 0,
  });

  factory RoomImage.fromJson(Map<String, dynamic> json) {
    return RoomImage(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      storageUrl: json['storage_url'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'storage_url': storageUrl,
      'sort_order': sortOrder,
    };
  }

  RoomImage copyWith({
    String? id,
    String? roomId,
    String? storageUrl,
    int? sortOrder,
  }) {
    return RoomImage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      storageUrl: storageUrl ?? this.storageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
