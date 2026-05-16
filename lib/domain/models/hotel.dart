import 'hotel_image.dart';
import 'amenity.dart';
import 'room.dart';

class Hotel {
  final String id;
  final String name;
  final String? description;
  final String address;
  final String? city;
  final double? latitude;
  final double? longitude;
  final double rating;
  final String? coverImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations
  final List<HotelImage>? images;
  final List<Amenity>? amenities;
  final List<Room>? rooms;

  const Hotel({
    required this.id,
    required this.name,
    this.description,
    required this.address,
    this.city,
    this.latitude,
    this.longitude,
    this.rating = 0.0,
    this.coverImageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.images,
    this.amenities,
    this.rooms,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      city: json['city'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      coverImageUrl: json['cover_image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      images: json['hotel_images'] != null 
          ? (json['hotel_images'] as List).map((i) => HotelImage.fromJson(i)).toList()
          : null,
      amenities: json['hotel_amenities'] != null
          ? (json['hotel_amenities'] as List).map((i) => Amenity.fromJson(i['amenities'])).toList()
          : null,
      rooms: json['rooms'] != null
          ? (json['rooms'] as List).map((r) => Room.fromJson(r)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'address': address,
      if (city != null) 'city': city,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'rating': rating,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Hotel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    double? rating,
    String? coverImageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<HotelImage>? images,
    List<Amenity>? amenities,
    List<Room>? rooms,
  }) {
    return Hotel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      rooms: rooms ?? this.rooms,
    );
  }
}
