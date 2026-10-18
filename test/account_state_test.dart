import 'package:flutter_test/flutter_test.dart';
import 'package:idile_mobile_app/features/account/domain/entities/profile/user_profile.dart';
import 'package:idile_mobile_app/features/account/domain/entities/reminders/reminder_settings.dart';
import 'package:idile_mobile_app/features/account/domain/entities/notification_settings/notification_settings.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/account_state.dart';

void main() {
  const profile = UserProfile(
    id: 'user-id',
    email: 'ada@example.com',
    name: 'Ada Okafor',
    role: 'user',
  );

  test('account state exposes and preserves its profile', () {
    const state = AccountState(profile: profile);

    expect(state.hasProfile, isTrue);
    expect(state.copyWith().profile, same(profile));
  });

  test('account state can clear its profile', () {
    const state = AccountState(profile: profile);

    expect(state.copyWith(profile: null).profile, isNull);
  });

  test('account state tracks profile updates without losing the profile', () {
    const state = AccountState(profile: profile);

    final updating = state.copyWith(isUpdating: true, errorMessage: null);

    expect(updating.profile, same(profile));
    expect(updating.isUpdating, isTrue);
    expect(updating.errorMessage, isNull);
  });

  test('account state tracks avatar uploads without losing the profile', () {
    const state = AccountState(profile: profile);

    final uploading = state.copyWith(isUploadingAvatar: true);

    expect(uploading.profile, same(profile));
    expect(uploading.isUploadingAvatar, isTrue);
  });

  test('account state owns and preserves reminder settings', () {
    const reminders = ReminderSettings(
      bills: ReminderPreference(enabled: true, leadDays: [7, 1, 0]),
      subscriptions: ReminderPreference(enabled: true, leadDays: [7, 1]),
      maintenance: ReminderPreference(enabled: false, leadDays: [1]),
      expiries: ReminderPreference(enabled: true, leadDays: [30, 7]),
    );
    const state = AccountState(profile: profile, reminderSettings: reminders);

    final loading = state.copyWith(isLoadingReminderSettings: true);

    expect(loading.profile, same(profile));
    expect(loading.reminderSettings, same(reminders));
    expect(loading.isLoadingReminderSettings, isTrue);
  });

  test('account state owns and preserves notification settings', () {
    const notifications = NotificationSettings(
      channels: NotificationChannels(inApp: true, email: true),
      quietHours: QuietHours(enabled: false, from: '22:00', to: '07:00'),
    );
    const state = AccountState(
      profile: profile,
      notificationSettings: notifications,
    );

    final loading = state.copyWith(isLoadingNotificationSettings: true);

    expect(loading.profile, same(profile));
    expect(loading.notificationSettings, same(notifications));
    expect(loading.isLoadingNotificationSettings, isTrue);
  });
}
