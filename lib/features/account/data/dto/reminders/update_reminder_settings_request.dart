import 'package:idile_mobile_app/features/account/data/model/reminders/reminder_settings.dart';

class UpdateReminderSettingsRequest {
  const UpdateReminderSettingsRequest({
    this.bills,
    this.subscriptions,
    this.maintenance,
    this.expiries,
  });

  factory UpdateReminderSettingsRequest.forKind(
    ReminderKind kind,
    ReminderPreference preference,
  ) => switch (kind) {
    ReminderKind.bills => UpdateReminderSettingsRequest(bills: preference),
    ReminderKind.subscriptions => UpdateReminderSettingsRequest(
      subscriptions: preference,
    ),
    ReminderKind.maintenance => UpdateReminderSettingsRequest(
      maintenance: preference,
    ),
    ReminderKind.expiries => UpdateReminderSettingsRequest(
      expiries: preference,
    ),
  };

  final ReminderPreference? bills;
  final ReminderPreference? subscriptions;
  final ReminderPreference? maintenance;
  final ReminderPreference? expiries;

  bool get hasChanges =>
      bills != null ||
      subscriptions != null ||
      maintenance != null ||
      expiries != null;

  Map<String, dynamic> toJson() {
    if (!hasChanges) {
      throw ArgumentError('At least one reminder setting must be supplied.');
    }
    return {
      if (bills != null) 'bills': bills!.toJson(),
      if (subscriptions != null) 'subscriptions': subscriptions!.toJson(),
      if (maintenance != null) 'maintenance': maintenance!.toJson(),
      if (expiries != null) 'expiries': expiries!.toJson(),
    };
  }
}
