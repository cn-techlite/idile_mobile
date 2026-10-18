import 'package:flutter_test/flutter_test.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/notification_settings/update_notification_settings_request.dart';

void main() {
  test('serializes only notification fields being changed', () {
    const request = UpdateNotificationSettingsRequest(
      channelInApp: false,
      quietHoursFrom: '21:30',
    );

    expect(request.toJson(), {
      'channelInApp': false,
      'quietHoursFrom': '21:30',
    });
  });

  test('rejects an empty notification update', () {
    expect(
      () => const UpdateNotificationSettingsRequest().toJson(),
      throwsArgumentError,
    );
  });

  test('rejects invalid quiet-hour times', () {
    expect(
      () =>
          const UpdateNotificationSettingsRequest(quietHoursTo: '25:00')
              .toJson(),
      throwsArgumentError,
    );
  });
}
