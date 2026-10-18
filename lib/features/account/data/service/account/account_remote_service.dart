import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/account/schedule_account_deletion_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/profile/update_account_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/profile/upload_avatar_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/reminders/update_reminder_settings_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/notification_settings/update_notification_settings_request.dart';
import 'package:idile_mobile_app/features/account/domain/entities/notification_settings/notification_settings.dart';
import 'package:idile_mobile_app/features/account/domain/entities/account/account_data_export.dart';
import 'package:idile_mobile_app/features/account/domain/entities/account/account_deletion_schedule.dart';
import 'package:idile_mobile_app/features/account/domain/entities/exchange_rates/exchange_rates.dart';
import 'package:idile_mobile_app/features/account/domain/entities/profile/user_profile.dart';
import 'package:idile_mobile_app/features/account/domain/entities/reminders/reminder_settings.dart';

class AccountRemoteService {
  const AccountRemoteService(this._api);

  final ApiClient _api;

  Future<UserProfile> currentUser() => _api.get(
    Endpoints.currentUserUrl,
    (value) => UserProfile.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<UserProfile> updateProfile(UpdateAccountRequest request) => _api.patch(
    Endpoints.currentUserUrl,
    (value) => UserProfile.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<UserProfile> uploadAvatar(UploadAvatarRequest request) {
    request.validate();
    return _api.multipart(
      Endpoints.currentUserAvatarUrl,
      (value) => UserProfile.fromJson(Map<String, dynamic>.from(value as Map)),
      method: 'PUT',
      fields: const {},
      fileBytes: request.fileBytes,
      fileName: request.normalizedFileName,
      fileContentType: request.contentType,
    );
  }

  Future<ReminderSettings> reminderSettings() => _api.get(
    Endpoints.reminderSettingsUrl,
    (value) =>
        ReminderSettings.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<ReminderSettings> updateReminderSettings(
    UpdateReminderSettingsRequest request,
  ) => _api.patch(
    Endpoints.reminderSettingsUrl,
    (value) =>
        ReminderSettings.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<NotificationSettings> notificationSettings() => _api.get(
    Endpoints.notificationSettingsUrl,
    (value) =>
        NotificationSettings.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<NotificationSettings> updateNotificationSettings(
    UpdateNotificationSettingsRequest request,
  ) => _api.patch(
    Endpoints.notificationSettingsUrl,
    (value) =>
        NotificationSettings.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<AccountDataExport> exportData() => _api.get(
    Endpoints.accountExportUrl,
    (value) =>
        AccountDataExport.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<ExchangeRates?> exchangeRates() => _api.get(
    Endpoints.exchangeRatesUrl,
    (value) => value == null
        ? null
        : ExchangeRates.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<bool> sendDeletionCode() => _api.post(
    Endpoints.accountDeletionCodeUrl,
    (value) => value is Map && value['sent'] == true,
  );

  Future<AccountDeletionSchedule> scheduleDeletion(
    ScheduleAccountDeletionRequest request,
  ) => _api.post(
    Endpoints.accountDeletionUrl,
    (value) => AccountDeletionSchedule.fromJson(
      Map<String, dynamic>.from(value as Map),
    ),
    body: request.toJson(),
  );
}
