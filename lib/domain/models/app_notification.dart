/// Kinds of in-app notifications Romio can raise. Stored by name so the UI can
/// render a localized title/body from [data] at display time — this keeps the
/// notification list correct even after the user switches language.
enum AppNotificationType {
  bookingConfirmed;

  static AppNotificationType fromName(String name) => AppNotificationType.values
      .firstWhere((t) => t.name == name, orElse: () => bookingConfirmed);
}

/// A single entry shown on the notifications screen. It carries the notification
/// [type] plus the structured [data] needed to build its localized text, rather
/// than a pre-rendered string, so the language in effect at read time wins.
class AppNotification {
  final String id;
  final AppNotificationType type;
  final Map<String, String> data;
  final DateTime createdAt;
  final bool read;

  const AppNotification({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.read = false,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        data: data,
        createdAt: createdAt,
        read: read ?? this.read,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        type: AppNotificationType.fromName(json['type'] as String),
        data: (json['data'] as Map).map((k, v) => MapEntry('$k', '$v')),
        createdAt: DateTime.parse(json['createdAt'] as String),
        read: json['read'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };
}
