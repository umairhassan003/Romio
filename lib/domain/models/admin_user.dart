class AdminUser {
  final String id;
  final String userId;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    required this.userId,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AdminUser copyWith({
    String? id,
    String? userId,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
