import 'package:idile_mobile_app/features/account/data/dto/account/schedule_account_deletion_request.dart';
import 'package:idile_mobile_app/features/account/data/dto/profile/update_account_request.dart';
import 'package:idile_mobile_app/features/account/data/dto/profile/upload_avatar_request.dart';
import 'package:idile_mobile_app/features/account/data/dto/reminders/update_reminder_settings_request.dart';
import 'package:idile_mobile_app/features/account/data/dto/notification_settings/update_notification_settings_request.dart';
import 'package:idile_mobile_app/features/account/data/model/account/account_data_export.dart';
import 'package:idile_mobile_app/features/account/data/model/account/account_deletion_schedule.dart';
import 'package:idile_mobile_app/features/account/data/model/exchange_rates/exchange_rates.dart';
import 'package:idile_mobile_app/features/account/data/model/notification_settings/notification_settings.dart';
import 'package:idile_mobile_app/features/account/data/model/profile/user_profile.dart';
import 'package:idile_mobile_app/features/account/data/model/reminders/reminder_settings.dart';
import 'package:idile_mobile_app/features/account/data/service/account/account_remote_service.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/account/account_repository.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_session_service.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(
    this._remoteService,
    this._localStorageService, {
    AuthSessionService? sessionService,
  }) : _sessionService = sessionService ?? AuthSessionService();

  final AccountRemoteService _remoteService;
  final AuthLocalStorageService _localStorageService;
  final AuthSessionService _sessionService;

  @override
  Future<UserProfile> currentUser() async {
    final profile = await _remoteService.currentUser();
    await _localStorageService.saveUserProfile(profile);
    return profile;
  }

  @override
  Future<UserProfile> updateProfile(UpdateAccountRequest request) async {
    final profile = await _remoteService.updateProfile(request);
    await _localStorageService.saveUserProfile(profile);
    return profile;
  }

  @override
  Future<UserProfile> uploadAvatar(UploadAvatarRequest request) async {
    final profile = await _remoteService.uploadAvatar(request);
    await _localStorageService.saveUserProfile(profile);
    return profile;
  }

  @override
  Future<ReminderSettings> reminderSettings() =>
      _remoteService.reminderSettings();

  @override
  Future<ReminderSettings> updateReminderSettings(
    UpdateReminderSettingsRequest request,
  ) => _remoteService.updateReminderSettings(request);

  @override
  Future<NotificationSettings> notificationSettings() =>
      _remoteService.notificationSettings();

  @override
  Future<NotificationSettings> updateNotificationSettings(
    UpdateNotificationSettingsRequest request,
  ) => _remoteService.updateNotificationSettings(request);

  @override
  Future<AccountDataExport> exportData() => _remoteService.exportData();

  @override
  Future<ExchangeRates?> exchangeRates() => _remoteService.exchangeRates();

  @override
  Future<bool> sendDeletionCode() => _remoteService.sendDeletionCode();

  @override
  Future<AccountDeletionSchedule> scheduleDeletion(
    ScheduleAccountDeletionRequest request,
  ) async {
    final schedule = await _remoteService.scheduleDeletion(request);
    await _localStorageService.clearAuthSession();
    await _sessionService.clear();
    return schedule;
  }
}
