import 'package:idile_mobile_app/features/account/data/model/account/account_data_export.dart';
import 'package:idile_mobile_app/features/account/data/model/exchange_rates/exchange_rates.dart';
import 'package:idile_mobile_app/features/account/data/model/reminders/reminder_settings.dart';
import 'package:idile_mobile_app/features/account/data/model/notification_settings/notification_settings.dart';
import 'package:idile_mobile_app/features/account/data/model/profile/user_profile.dart';

class AccountState {
  const AccountState({
    this.profile,
    this.reminderSettings,
    this.notificationSettings,
    this.exchangeRates,
    this.isUpdating = false,
    this.isUploadingAvatar = false,
    this.isLoadingReminderSettings = false,
    this.isLoadingNotificationSettings = false,
    this.isLoadingExchangeRates = false,
    this.dataExport,
    this.deletionScheduledAt,
    this.isExportingData = false,
    this.isSendingDeletionCode = false,
    this.isSchedulingDeletion = false,
    this.deletionCodeSent = false,
    this.errorMessage,
    this.reminderSettingsError,
    this.notificationSettingsError,
    this.exchangeRatesError,
    this.dataExportError,
    this.deletionError,
  });

  final UserProfile? profile;
  final ReminderSettings? reminderSettings;
  final NotificationSettings? notificationSettings;
  final ExchangeRates? exchangeRates;
  final bool isUpdating;
  final bool isUploadingAvatar;
  final bool isLoadingReminderSettings;
  final bool isLoadingNotificationSettings;
  final bool isLoadingExchangeRates;
  final AccountDataExport? dataExport;
  final DateTime? deletionScheduledAt;
  final bool isExportingData;
  final bool isSendingDeletionCode;
  final bool isSchedulingDeletion;
  final bool deletionCodeSent;
  final String? errorMessage;
  final String? reminderSettingsError;
  final String? notificationSettingsError;
  final String? exchangeRatesError;
  final String? dataExportError;
  final String? deletionError;

  bool get hasProfile => profile != null;

  AccountState copyWith({
    Object? profile = _unset,
    Object? reminderSettings = _unset,
    Object? notificationSettings = _unset,
    Object? exchangeRates = _unset,
    bool? isUpdating,
    bool? isUploadingAvatar,
    bool? isLoadingReminderSettings,
    bool? isLoadingNotificationSettings,
    bool? isLoadingExchangeRates,
    Object? dataExport = _unset,
    Object? deletionScheduledAt = _unset,
    bool? isExportingData,
    bool? isSendingDeletionCode,
    bool? isSchedulingDeletion,
    bool? deletionCodeSent,
    Object? errorMessage = _unset,
    Object? reminderSettingsError = _unset,
    Object? notificationSettingsError = _unset,
    Object? exchangeRatesError = _unset,
    Object? dataExportError = _unset,
    Object? deletionError = _unset,
  }) {
    return AccountState(
      profile: identical(profile, _unset)
          ? this.profile
          : profile as UserProfile?,
      reminderSettings: identical(reminderSettings, _unset)
          ? this.reminderSettings
          : reminderSettings as ReminderSettings?,
      notificationSettings: identical(notificationSettings, _unset)
          ? this.notificationSettings
          : notificationSettings as NotificationSettings?,
      exchangeRates: identical(exchangeRates, _unset)
          ? this.exchangeRates
          : exchangeRates as ExchangeRates?,
      isUpdating: isUpdating ?? this.isUpdating,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      isLoadingReminderSettings:
          isLoadingReminderSettings ?? this.isLoadingReminderSettings,
      isLoadingNotificationSettings:
          isLoadingNotificationSettings ?? this.isLoadingNotificationSettings,
      isLoadingExchangeRates:
          isLoadingExchangeRates ?? this.isLoadingExchangeRates,
      dataExport: identical(dataExport, _unset)
          ? this.dataExport
          : dataExport as AccountDataExport?,
      deletionScheduledAt: identical(deletionScheduledAt, _unset)
          ? this.deletionScheduledAt
          : deletionScheduledAt as DateTime?,
      isExportingData: isExportingData ?? this.isExportingData,
      isSendingDeletionCode:
          isSendingDeletionCode ?? this.isSendingDeletionCode,
      isSchedulingDeletion: isSchedulingDeletion ?? this.isSchedulingDeletion,
      deletionCodeSent: deletionCodeSent ?? this.deletionCodeSent,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      reminderSettingsError: identical(reminderSettingsError, _unset)
          ? this.reminderSettingsError
          : reminderSettingsError as String?,
      notificationSettingsError: identical(notificationSettingsError, _unset)
          ? this.notificationSettingsError
          : notificationSettingsError as String?,
      exchangeRatesError: identical(exchangeRatesError, _unset)
          ? this.exchangeRatesError
          : exchangeRatesError as String?,
      dataExportError: identical(dataExportError, _unset)
          ? this.dataExportError
          : dataExportError as String?,
      deletionError: identical(deletionError, _unset)
          ? this.deletionError
          : deletionError as String?,
    );
  }
}

const _unset = Object();
