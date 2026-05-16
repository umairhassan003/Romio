import 'room_image.dart';
import 'amenity.dart';

class Room {
  final String id;
  final String hotelId;
  final String name;
  final String? description;
  final double pricePerHour;
  final double rating;
  final String? coverImageUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final List<RoomImage>? images;
  final List<Amenity>? amenities;

  const Room({
    required this.id,
    required this.hotelId,
    required this.name,
    this.description,
    required this.pricePerHour,
    this.rating = 0.0,
    this.coverImageUrl,
    this.status = 'available',
    required this.createdAt,
    required this.updatedAt,
    this.images,
    this.amenities,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      hotelId: json['hotel_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      pricePerHour: json['price_per_hour'] != null ? (json['price_per_hour'] as num).toDouble() : 0.0,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      coverImageUrl: json['cover_image_url'] as String?,
      status: json['status'] as String? ?? 'available',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      images: json['room_images'] != null 
          ? (json['room_images'] as List).map((i) => RoomImage.fromJson(i)).toList()
          : null,
      amenities: json['room_amenities'] != null
          ? (json['room_amenities'] as List).map((i) => Amenity.fromJson(i['amenities'])).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'name': name,
      if (description != null) 'description': description,
      'price_per_hour': pricePerHour,
      'rating': rating,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Room copyWith({
    String? id,
    String? hotelId,
    String? name,
    String? description,
    double? pricePerHour,
    double? rating,
    String? coverImageUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<RoomImage>? images,
    List<Amenity>? amenities,
  }) {
    return Room(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name ?? this.name,
      description: description ?? this.description,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      rating: rating ?? this.rating,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
    );
  }
}
