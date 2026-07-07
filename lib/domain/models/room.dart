import 'room_image.dart';
import 'amenity.dart';

class Room {
  final String id;
  final String hotelId;
  final String name;
  final String? description;
  final double pricePerHour;

  /// Per-slot prices. When the DB value is null (e.g. rooms created before
  /// slot pricing existed), these fall back to [pricePerHour] × hours so the
  /// UI always has a sensible auto-calculated value to show.
  final double price3h;
  final double price6h;
  final double price24h;
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
    required this.price3h,
    required this.price6h,
    required this.price24h,
    this.rating = 0.0,
    this.coverImageUrl,
    this.status = 'available',
    required this.createdAt,
    required this.updatedAt,
    this.images,
    this.amenities,
  });

  /// Price for one of the bookable slots (3h / 6h / 24h). Falls back to the
  /// hourly rate for any other duration.
  double priceForHours(int hours) {
    switch (hours) {
      case 3:
        return price3h;
      case 6:
        return price6h;
      case 24:
        return price24h;
      default:
        return pricePerHour * hours;
    }
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    final pph = json['price_per_hour'] != null ? (json['price_per_hour'] as num).toDouble() : 0.0;
    double slot(String key, int hours) =>
        json[key] != null ? (json[key] as num).toDouble() : pph * hours;
    return Room(
      id: json['id'] as String,
      hotelId: json['hotel_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      pricePerHour: pph,
      price3h: slot('price_3h', 3),
      price6h: slot('price_6h', 6),
      price24h: slot('price_24h', 24),
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
      'price_3h': price3h,
      'price_6h': price6h,
      'price_24h': price24h,
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
    double? price3h,
    double? price6h,
    double? price24h,
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
      price3h: price3h ?? this.price3h,
      price6h: price6h ?? this.price6h,
      price24h: price24h ?? this.price24h,
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
