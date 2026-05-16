class PaymentMethod {
  final String id;
  final String profileId;
  final String type;
  final String? displayLabel;
  final String? providerToken;
  final bool isDefault;
  final DateTime createdAt;

  const PaymentMethod({
    required this.id,
    required this.profileId,
    required this.type,
    this.displayLabel,
    this.providerToken,
    this.isDefault = false,
    required this.createdAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      type: json['type'] as String,
      displayLabel: json['display_label'] as String?,
      providerToken: json['provider_token'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'type': type,
      if (displayLabel != null) 'display_label': displayLabel,
      if (providerToken != null) 'provider_token': providerToken,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PaymentMethod copyWith({
    String? id,
    String? profileId,
    String? type,
    String? displayLabel,
    String? providerToken,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      type: type ?? this.type,
      displayLabel: displayLabel ?? this.displayLabel,
      providerToken: providerToken ?? this.providerToken,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
