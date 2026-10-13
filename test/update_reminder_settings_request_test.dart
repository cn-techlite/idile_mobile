import 'package:flutter_test/flutter_test.dart';
import 'package:idile_mobile_app/features/account/data/dto/reminders/update_reminder_settings_request.dart';
import 'package:idile_mobile_app/features/account/data/model/reminders/reminder_settings.dart';

void main() {
  test('serializes only the reminder kinds being changed', () {
    final request = UpdateReminderSettingsRequest.forKind(
      ReminderKind.maintenance,
      const ReminderPreference(enabled: true, leadDays: [7, 1, 0]),
    );

    expect(request.toJson(), {
      'maintenance': {
        'enabled': true,
        'leadDays': [7, 1, 0],
      },
    });
  });

  test('supports changing multiple reminder kinds together', () {
    const request = UpdateReminderSettingsRequest(
      bills: ReminderPreference(enabled: false, leadDays: [1, 0]),
      expiries: ReminderPreference(enabled: true, leadDays: [30, 7]),
    );

    expect(request.toJson().keys, ['bills', 'expiries']);
  });

  test('rejects an empty reminder update', () {
    expect(
      () => const UpdateReminderSettingsRequest().toJson(),
      throwsArgumentError,
    );
  });
}
