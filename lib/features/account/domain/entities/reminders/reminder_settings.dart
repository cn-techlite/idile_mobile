class ReminderPreference {
  const ReminderPreference({required this.enabled, required this.leadDays});

  factory ReminderPreference.fromJson(Map<String, dynamic> json) =>
      ReminderPreference(
        enabled: json['enabled'] == true,
        leadDays: List<int>.unmodifiable(
          (json['leadDays'] as List? ?? const []).map(
            (value) => (value as num).toInt(),
          ),
        ),
      );

  final bool enabled;
  final List<int> leadDays;

  Map<String, dynamic> toJson() => {'enabled': enabled, 'leadDays': leadDays};
}

enum ReminderKind { bills, subscriptions, maintenance, expiries }

extension ReminderKindDisplay on ReminderKind {
  String get displayName => switch (this) {
    ReminderKind.bills => 'Bills',
    ReminderKind.subscriptions => 'Subscriptions',
    ReminderKind.maintenance => 'Maintenance',
    ReminderKind.expiries => 'Expiries',
  };
}

class ReminderSettings {
  const ReminderSettings({
    required this.bills,
    required this.subscriptions,
    required this.maintenance,
    required this.expiries,
  });

  factory ReminderSettings.fromJson(Map<String, dynamic> json) =>
      ReminderSettings(
        bills: _preference(json['bills']),
        subscriptions: _preference(json['subscriptions']),
        maintenance: _preference(json['maintenance']),
        expiries: _preference(json['expiries']),
      );

  final ReminderPreference bills;
  final ReminderPreference subscriptions;
  final ReminderPreference maintenance;
  final ReminderPreference expiries;

  Map<ReminderKind, ReminderPreference> get entries => {
    ReminderKind.bills: bills,
    ReminderKind.subscriptions: subscriptions,
    ReminderKind.maintenance: maintenance,
    ReminderKind.expiries: expiries,
  };
}

ReminderPreference _preference(Object? value) => ReminderPreference.fromJson(
  value is Map ? Map<String, dynamic>.from(value) : const {},
);
