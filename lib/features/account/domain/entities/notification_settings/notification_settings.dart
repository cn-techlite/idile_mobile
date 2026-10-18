class NotificationChannels {
  const NotificationChannels({required this.inApp, required this.email});

  factory NotificationChannels.fromJson(Map<String, dynamic> json) =>
      NotificationChannels(
        inApp: json['inApp'] == true,
        email: json['email'] == true,
      );

  final bool inApp;
  final bool email;
}

class QuietHours {
  const QuietHours({
    required this.enabled,
    required this.from,
    required this.to,
  });

  factory QuietHours.fromJson(Map<String, dynamic> json) => QuietHours(
    enabled: json['enabled'] == true,
    from: json['from']?.toString() ?? '',
    to: json['to']?.toString() ?? '',
  );

  final bool enabled;
  final String from;
  final String to;
}

class NotificationSettings {
  const NotificationSettings({
    required this.channels,
    required this.quietHours,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        channels: NotificationChannels.fromJson(_json(json['channels'])),
        quietHours: QuietHours.fromJson(_json(json['quietHours'])),
      );

  final NotificationChannels channels;
  final QuietHours quietHours;
}

Map<String, dynamic> _json(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};
