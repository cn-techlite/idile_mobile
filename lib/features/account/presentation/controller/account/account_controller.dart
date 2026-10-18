import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/app/di/repository_providers.dart';
import 'package:idile_mobile_app/core/network/api_exception.dart';
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
import 'package:idile_mobile_app/features/account/presentation/state/state_model/account_state.dart';

class AccountController extends AsyncNotifier<AccountState> {
  @override
  FutureOr<AccountState> build() => _loadAccount();

  Future<AccountState> _loadAccount() async {
    UserProfile profile;
    try {
      profile = await ref.read(accountUseCasesProvider).currentUser();
    } on ApiException catch (error) {
      if (error.isUnauthorized) return const AccountState();
      rethrow;
    }

    ReminderSettings? reminderSettings;
    NotificationSettings? notificationSettings;
    ExchangeRates? exchangeRates;
    String? reminderSettingsError;
    String? notificationSettingsError;
    String? exchangeRatesError;

    try {
      reminderSettings = await ref
          .read(accountUseCasesProvider)
          .reminderSettings();
    } catch (error) {
      reminderSettingsError = _message(error);
    }
    try {
      notificationSettings = await ref
          .read(accountUseCasesProvider)
          .notificationSettings();
    } catch (error) {
      notificationSettingsError = _message(error);
    }
    try {
      exchangeRates = await ref.read(accountUseCasesProvider).exchangeRates();
    } catch (error) {
      exchangeRatesError = _message(error);
    }
    return AccountState(
      profile: profile,
      reminderSettings: reminderSettings,
      notificationSettings: notificationSettings,
      exchangeRates: exchangeRates,
      reminderSettingsError: reminderSettingsError,
      notificationSettingsError: notificationSettingsError,
      exchangeRatesError: exchangeRatesError,
    );
  }

  Future<UserProfile> updateProfile(UpdateAccountRequest request) async {
    final previous = state.value ?? const AccountState();
    state = AsyncData(previous.copyWith(isUpdating: true, errorMessage: null));
    try {
      final profile = await ref
          .read(accountUseCasesProvider)
          .updateProfile(request);
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          profile: profile,
          isUpdating: false,
          errorMessage: null,
        ),
      );
      return profile;
    } catch (error) {
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          isUpdating: false,
          errorMessage: error is ApiException
              ? error.message
              : error.toString(),
        ),
      );
      rethrow;
    }
  }

  Future<UserProfile> uploadAvatar(UploadAvatarRequest request) async {
    final previous = state.value ?? const AccountState();
    state = AsyncData(
      previous.copyWith(isUploadingAvatar: true, errorMessage: null),
    );
    try {
      final profile = await ref
          .read(accountUseCasesProvider)
          .uploadAvatar(request);
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          profile: profile,
          isUploadingAvatar: false,
          errorMessage: null,
        ),
      );
      return profile;
    } catch (error) {
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          isUploadingAvatar: false,
          errorMessage: _message(error),
        ),
      );
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadAccount);
  }

  Future<ReminderSettings?> refreshReminderSettings() async {
    final previous = state.value ?? const AccountState();
    state = AsyncData(
      previous.copyWith(
        isLoadingReminderSettings: true,
        reminderSettingsError: null,
      ),
    );
    try {
      final settings = await ref
          .read(accountUseCasesProvider)
          .reminderSettings();
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          reminderSettings: settings,
          isLoadingReminderSettings: false,
          reminderSettingsError: null,
        ),
      );
      return settings;
    } catch (error) {
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          isLoadingReminderSettings: false,
          reminderSettingsError: _message(error),
        ),
      );
      return null;
    }
  }

  Future<ReminderSettings> updateReminderSettings(
    UpdateReminderSettingsRequest request,
  ) async {
    final previous = state.value ?? const AccountState();
    state = AsyncData(
      previous.copyWith(
        isLoadingReminderSettings: true,
        reminderSettingsError: null,
      ),
    );
    try {
      final settings = await ref
          .read(accountUseCasesProvider)
          .updateReminderSettings(request);
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          reminderSettings: settings,
          isLoadingReminderSettings: false,
          reminderSettingsError: null,
        ),
      );
      return settings;
    } catch (error) {
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          isLoadingReminderSettings: false,
          reminderSettingsError: _message(error),
        ),
      );
      rethrow;
    }
  }

  Future<NotificationSettings?> refreshNotificationSettings() async {
    final previous = state.value ?? const AccountState();
    state = AsyncData(
      previous.copyWith(
        isLoadingNotificationSettings: true,
        notificationSettingsError: null,
      ),
    );
    try {
      final settings = await ref
          .read(accountUseCasesProvider)
          .notificationSettings();
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          notificationSettings: settings,
          isLoadingNotificationSettings: false,
          notificationSettingsError: null,
        ),
      );
      return settings;
    } catch (error) {
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          isLoadingNotificationSettings: false,
          notificationSettingsError: _message(error),
        ),
      );
      return null;
    }
  }

  Future<NotificationSettings> updateNotificationSettings(
    UpdateNotificationSettingsRequest request,
  ) async {
    final previous = state.value ?? const AccountState();
    state = AsyncData(
      previous.copyWith(
        isLoadingNotificationSettings: true,
        notificationSettingsError: null,
      ),
    );
    try {
      final settings = await ref
          .read(accountUseCasesProvider)
          .updateNotificationSettings(request);
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          notificationSettings: settings,
          isLoadingNotificationSettings: false,
          notificationSettingsError: null,
        ),
      );
      return settings;
    } catch (error) {
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          isLoadingNotificationSettings: false,
          notificationSettingsError: _message(error),
        ),
      );
      rethrow;
    }
  }

  Future<ExchangeRates?> refreshExchangeRates() async {
    final previous = state.value ?? const AccountState();
    state = AsyncData(
      previous.copyWith(isLoadingExchangeRates: true, exchangeRatesError: null),
    );
    try {
      final rates = await ref.read(accountUseCasesProvider).exchangeRates();
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          exchangeRates: rates,
          isLoadingExchangeRates: false,
          exchangeRatesError: null,
        ),
      );
      return rates;
    } catch (error) {
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          isLoadingExchangeRates: false,
          exchangeRatesError: _message(error),
        ),
      );
      return null;
    }
  }

  Future<AccountDataExport> exportData() async {
    final previous = state.value ?? const AccountState();
    state = AsyncData(
      previous.copyWith(isExportingData: true, dataExportError: null),
    );
    try {
      final export = await ref.read(accountUseCasesProvider).exportData();
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          dataExport: export,
          isExportingData: false,
          dataExportError: null,
        ),
      );
      return export;
    } catch (error) {
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          isExportingData: false,
          dataExportError: _message(error),
        ),
      );
      rethrow;
    }
  }

  Future<void> sendDeletionCode() async {
    final previous = state.value ?? const AccountState();
    state = AsyncData(
      previous.copyWith(
        isSendingDeletionCode: true,
        deletionCodeSent: false,
        deletionError: null,
      ),
    );
    try {
      final sent = await ref.read(accountUseCasesProvider).sendDeletionCode();
      if (!sent) throw StateError('The deletion code was not sent.');
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          isSendingDeletionCode: false,
          deletionCodeSent: true,
          deletionError: null,
        ),
      );
    } catch (error) {
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          isSendingDeletionCode: false,
          deletionCodeSent: false,
          deletionError: _message(error),
        ),
      );
      rethrow;
    }
  }

  Future<AccountDeletionSchedule> scheduleDeletion(
    ScheduleAccountDeletionRequest request,
  ) async {
    final previous = state.value ?? const AccountState();
    state = AsyncData(
      previous.copyWith(isSchedulingDeletion: true, deletionError: null),
    );
    try {
      final schedule = await ref
          .read(accountUseCasesProvider)
          .scheduleDeletion(request);
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          deletionScheduledAt: schedule.deletionScheduledAt,
          isSchedulingDeletion: false,
          deletionError: null,
        ),
      );
      return schedule;
    } catch (error) {
      final current = state.value ?? previous;
      state = AsyncData(
        current.copyWith(
          isSchedulingDeletion: false,
          deletionError: _message(error),
        ),
      );
      rethrow;
    }
  }

  void clear() {
    state = const AsyncData(AccountState());
  }

  String _message(Object error) =>
      error is ApiException ? error.message : error.toString();
}
