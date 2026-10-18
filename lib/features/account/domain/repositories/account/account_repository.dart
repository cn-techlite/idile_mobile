import 'package:idile_mobile_app/features/account/domain/parameters/account/schedule_account_deletion_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/profile/update_account_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/profile/upload_avatar_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/reminders/update_reminder_settings_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/notification_settings/update_notification_settings_request.dart';
import 'package:idile_mobile_app/features/account/domain/entities/account/account_data_export.dart';
import 'package:idile_mobile_app/features/account/domain/entities/account/account_deletion_schedule.dart';
import 'package:idile_mobile_app/features/account/domain/entities/exchange_rates/exchange_rates.dart';
import 'package:idile_mobile_app/features/account/domain/entities/notification_settings/notification_settings.dart';
import 'package:idile_mobile_app/features/account/domain/entities/profile/user_profile.dart';
import 'package:idile_mobile_app/features/account/domain/entities/reminders/reminder_settings.dart';

abstract interface class AccountRepository {
  Future<UserProfile> currentUser();
  Future<UserProfile> updateProfile(UpdateAccountRequest request);
  Future<UserProfile> uploadAvatar(UploadAvatarRequest request);
  Future<ReminderSettings> reminderSettings();
  Future<ReminderSettings> updateReminderSettings(
    UpdateReminderSettingsRequest request,
  );
  Future<NotificationSettings> notificationSettings();
  Future<NotificationSettings> updateNotificationSettings(
    UpdateNotificationSettingsRequest request,
  );
  Future<AccountDataExport> exportData();
  Future<ExchangeRates?> exchangeRates();
  Future<bool> sendDeletionCode();
  Future<AccountDeletionSchedule> scheduleDeletion(
    ScheduleAccountDeletionRequest request,
  );
}
