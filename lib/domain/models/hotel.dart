import 'hotel_image.dart';
import 'amenity.dart';
import 'room.dart';

/// How guests pay for a booking at a hotel. Exactly one mode is active per
/// hotel and it is chosen by the admin when creating/editing the hotel.
enum HotelPaymentMode {
  /// Reserve without paying in the app; settle the full amount at the property.
  payAtProperty('pay_at_property'),

  /// Pay the full amount online up front; the booking is reserved only once the
  /// payment completes.
  payAtApp('pay_at_app'),

  /// Pay a percentage online up front (the deposit) and the rest at the
  /// property. The deposit percentage is configured per booking slot.
  payPartial('pay_partial');

  const HotelPaymentMode(this.dbValue);

  /// Value stored in `hotels.payment_mode`.
  final String dbValue;

  static HotelPaymentMode fromDbValue(String? value) {
    return HotelPaymentMode.values.firstWhere(
      (m) => m.dbValue == value,
      orElse: () => HotelPaymentMode.payAtApp,
    );
  }
}

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

  /// Which of the three payment modes is active for this hotel.
  final HotelPaymentMode paymentMode;

  /// Deposit percentages (0–100) charged online per booking slot when
  /// [paymentMode] is [HotelPaymentMode.payPartial]. Null when not configured.
  final double? partialPercent3h;
  final double? partialPercent6h;
  final double? partialPercent24h;

  /// True when guests settle at the property (pay-at-property mode). Kept as a
  /// convenience for the legacy `pay_on_property` concept.
  bool get payOnProperty => paymentMode == HotelPaymentMode.payAtProperty;

  /// Earliest time guests can check in, stored as "HH:MM" (24-hour).
  /// When set, the reservation screen only shows time slots at or after
  /// this time.
  final String? checkInTime;

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
    this.paymentMode = HotelPaymentMode.payAtApp,
    this.partialPercent3h,
    this.partialPercent6h,
    this.partialPercent24h,
    this.checkInTime,
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
      // Prefer the explicit payment_mode; fall back to the legacy boolean so
      // rows written before this column existed still resolve correctly.
      paymentMode: json['payment_mode'] != null
          ? HotelPaymentMode.fromDbValue(json['payment_mode'] as String?)
          : ((json['pay_on_property'] as bool? ?? false)
              ? HotelPaymentMode.payAtProperty
              : HotelPaymentMode.payAtApp),
      partialPercent3h: json['partial_percent_3h'] != null
          ? (json['partial_percent_3h'] as num).toDouble()
          : null,
      partialPercent6h: json['partial_percent_6h'] != null
          ? (json['partial_percent_6h'] as num).toDouble()
          : null,
      partialPercent24h: json['partial_percent_24h'] != null
          ? (json['partial_percent_24h'] as num).toDouble()
          : null,
      checkInTime: json['check_in_time'] as String?,
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
      'payment_mode': paymentMode.dbValue,
      'partial_percent_3h': partialPercent3h,
      'partial_percent_6h': partialPercent6h,
      'partial_percent_24h': partialPercent24h,
      // Mirror the legacy boolean so older readers keep working.
      'pay_on_property': payOnProperty,
      'check_in_time': checkInTime,
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
    HotelPaymentMode? paymentMode,
    double? partialPercent3h,
    double? partialPercent6h,
    double? partialPercent24h,
    String? checkInTime,
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
      paymentMode: paymentMode ?? this.paymentMode,
      partialPercent3h: partialPercent3h ?? this.partialPercent3h,
      partialPercent6h: partialPercent6h ?? this.partialPercent6h,
      partialPercent24h: partialPercent24h ?? this.partialPercent24h,
      checkInTime: checkInTime ?? this.checkInTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      rooms: rooms ?? this.rooms,
    );
  }
}
