import 'package:idile_mobile_app/core/constants/api_constants.dart';

class Endpoints {
  static String get baseUrl => ApiConstants.baseUrl;

  static String authUrl = "auth";
  static String loginUrl = "auth/login";
  static String registerUrl = "auth/register";
  static const String googleLoginUrl = "auth/google";
  static const String appleLoginUrl = "auth/apple";
  static const String socialLoginUrl = "auth/external-login";
  static String emailVerificationUrl = "auth/email-verification";
  static String forgetPasswordUrl = "auth/password/forgot";
  static String resetPasswordUrl = "auth/password/reset";
  static String logoutUrl = "auth/logout";
  static String refreshTokenUrl = "auth/refresh";
  static const String deviceChallengeUrl = "auth/device/challenge";
  static const String deviceLoginUrl = "auth/device/login";
  static const String deviceGoogleUrl = "auth/device/google";
  static const String deviceAppleUrl = "auth/device/apple";
  static const String deviceApproveUrl = "auth/device/approve";
  static const String deviceNotMeUrl = "auth/device/not-me";
  static const String currentUserUrl = "users/me";
  static const String currentUserAvatarUrl = "$currentUserUrl/avatar";
  static const String reminderSettingsUrl = "users/me/reminder-settings";
  static const String notificationSettingsUrl =
      "users/me/notification-settings";
  static const String accountExportUrl = "users/me/export";
  static const String accountDeletionCodeUrl = "users/me/deletion/code";
  static const String accountDeletionUrl = "users/me/deletion";
  static const String quickAddTemplatesUrl =
      "reference-data/quick-add-templates";
  static const String dashboardAttentionUrl = "dashboard/attention";
  static const String exchangeRatesUrl = "exchange-rates";
  static const String notificationsUrl = "notifications";
  static const String notificationsReadAllUrl = "notifications/read-all";
  static String notificationReadUrl(String id) =>
      "$notificationsUrl/${Uri.encodeComponent(id)}/read";
  static const String devicesUrl = "devices";
  static const String devicePushTokenUrl = "$devicesUrl/me/push-token";
  static String revokeDeviceUrl(String id) =>
      "$devicesUrl/${Uri.encodeComponent(id)}";
  static const String spacesUrl = "spaces";
  static String spaceUrl(String id) => "$spacesUrl/${Uri.encodeComponent(id)}";
  static String spaceSummaryUrl(String id) => "${spaceUrl(id)}/summary";
  static const String categoriesUrl = "categories";
  static String categoryUrl(String id) =>
      "$categoriesUrl/${Uri.encodeComponent(id)}";
  static const String currenciesUrl = "currencies";
  static String currencyUrl(String id) =>
      "$currenciesUrl/${Uri.encodeComponent(id)}";
  static const String billsUrl = "bills";
  static const String billPaymentsUrl = "$billsUrl/payments";
  static String billUrl(String id) => "$billsUrl/${Uri.encodeComponent(id)}";
  static String markBillPaidUrl(String id) => "${billUrl(id)}/mark-paid";
  static const String subscriptionsUrl = "subscriptions";
  static String subscriptionUrl(String id) =>
      "$subscriptionsUrl/${Uri.encodeComponent(id)}";
  static const String householdItemsUrl = "household-items";
  static String householdItemUrl(String id) =>
      "$householdItemsUrl/${Uri.encodeComponent(id)}";
  static const String maintenanceUrl = "maintenance";
  static String maintenanceTaskUrl(String id) =>
      "$maintenanceUrl/${Uri.encodeComponent(id)}";
  static String markMaintenanceDoneUrl(String id) =>
      "${maintenanceTaskUrl(id)}/mark-done";
  static const String assetsUrl = "assets";
  static String assetUrl(String id) => "$assetsUrl/${Uri.encodeComponent(id)}";
  static const String documentsUrl = "documents";
  static String documentUrl(String id) =>
      "$documentsUrl/${Uri.encodeComponent(id)}";
  static const String calendarUrl = "calendar";
  static const String calendarFeedTokenUrl = "$calendarUrl/feed-token";
  static const String calendarFeedTokenRotateUrl =
      "$calendarFeedTokenUrl/rotate";
  static String resendEmailVerificationTokenUrl =
      "auth/email-verification-request-token";
}
