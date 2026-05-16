class Profile {
  final String id;
  final String userId;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? billingAddress;
  final String? preferredLanguage;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.userId,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.billingAddress,
    this.preferredLanguage,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth']) 
          : null,
      billingAddress: json['billing_address'] as String?,
      preferredLanguage: json['preferred_language'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth!.toIso8601String().split('T')[0],
      if (billingAddress != null) 'billing_address': billingAddress,
      if (preferredLanguage != null) 'preferred_language': preferredLanguage,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? billingAddress,
    String? preferredLanguage,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      billingAddress: billingAddress ?? this.billingAddress,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
