import 'package:idile_mobile_app/features/account/domain/entities/account/account_data_export.dart';
import 'package:idile_mobile_app/features/account/domain/entities/account/account_deletion_schedule.dart';
import 'package:idile_mobile_app/features/account/domain/entities/exchange_rates/exchange_rates.dart';
import 'package:idile_mobile_app/features/account/domain/entities/notification_settings/notification_settings.dart';
import 'package:idile_mobile_app/features/account/domain/entities/profile/user_profile.dart';
import 'package:idile_mobile_app/features/account/domain/entities/reminders/reminder_settings.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/account/schedule_account_deletion_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/notification_settings/update_notification_settings_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/profile/update_account_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/profile/upload_avatar_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/reminders/update_reminder_settings_request.dart';
import 'package:idile_mobile_app/features/account/domain/repositories/account/account_repository.dart';

final class AccountUseCases {
  const AccountUseCases(this._repository);

  final AccountRepository _repository;

  Future<UserProfile> currentUser() => _repository.currentUser();

  Future<UserProfile> updateProfile(UpdateAccountRequest request) =>
      _repository.updateProfile(request);

  Future<UserProfile> uploadAvatar(UploadAvatarRequest request) =>
      _repository.uploadAvatar(request);

  Future<ReminderSettings> reminderSettings() => _repository.reminderSettings();

  Future<ReminderSettings> updateReminderSettings(
    UpdateReminderSettingsRequest request,
  ) => _repository.updateReminderSettings(request);

  Future<NotificationSettings> notificationSettings() =>
      _repository.notificationSettings();

  Future<NotificationSettings> updateNotificationSettings(
    UpdateNotificationSettingsRequest request,
  ) => _repository.updateNotificationSettings(request);

  Future<AccountDataExport> exportData() => _repository.exportData();

  Future<ExchangeRates?> exchangeRates() => _repository.exchangeRates();

  Future<bool> sendDeletionCode() => _repository.sendDeletionCode();

  Future<AccountDeletionSchedule> scheduleDeletion(
    ScheduleAccountDeletionRequest request,
  ) => _repository.scheduleDeletion(request);
}
