class Amenity {
  final String id;
  final String name;
  final String? iconKey;
  final String appliesTo;
  final DateTime createdAt;

  const Amenity({
    required this.id,
    required this.name,
    this.iconKey,
    required this.appliesTo,
    required this.createdAt,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'] as String,
      name: json['name'] as String,
      iconKey: json['icon_key'] as String?,
      appliesTo: json['applies_to'] as String,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (iconKey != null) 'icon_key': iconKey,
      'applies_to': appliesTo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Amenity copyWith({
    String? id,
    String? name,
    String? iconKey,
    String? appliesTo,
    DateTime? createdAt,
  }) {
    return Amenity(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      appliesTo: appliesTo ?? this.appliesTo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
