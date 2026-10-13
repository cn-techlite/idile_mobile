import 'package:idile_mobile_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

/// Compatibility state used by the restored authentication flow.
///
/// The current Ìdílé session continues to use [SessionStore]; this object is
/// retained for the original Auth screens and services that referenced it.
class AppGlobals {
  int? isViewed;
  String userEmail = '';
  String token = '';
  String refreshToken = '';
  String userId = '';
  String userName = '';
  String profilePicture = '';
  String deviceToken = '';
  String? infoCompleted = '';
  bool isEmailVerified = false;
  bool rememberLogin = false;
  bool hasPassword = false;
  String userRole = '';
  String defaultSpaceId = '';
  String householdSpaceId = '';
  String workspaceSpaceId = '';
  String defaultCurrencyId = '';
  List<String> permissions = [];
  List<String> roles = [];
  StopWatchTimer? stopWatchTimer;

  Future<void> init() async {
    final storage = AuthLocalStorageService();
    await storage.migrateLegacySessionIfNeeded();
    userId =
        await storage.readSecureAuthValue(AuthLocalStorageService.userIdKey) ??
        '';
    token =
        await storage.readSecureAuthValue(AuthLocalStorageService.tokenKey) ??
        '';
    refreshToken =
        await storage.readSecureAuthValue(
          AuthLocalStorageService.refreshTokenKey,
        ) ??
        '';
    userEmail =
        await storage.readSecureAuthValue(
          AuthLocalStorageService.userEmailKey,
        ) ??
        '';
    userName =
        await storage.readSecureAuthValue(
          AuthLocalStorageService.userNameKey,
        ) ??
        '';
    profilePicture =
        await storage.readSecureAuthValue(
          AuthLocalStorageService.profilePictureKey,
        ) ??
        '';
    deviceToken = await storage.readString('deviceToken') ?? '';
    infoCompleted = await storage.readString('InfoCompleted') ?? '';
    isEmailVerified = await storage.readBool('isEmailVerified') ?? false;
    rememberLogin =
        await storage.readBool(AuthLocalStorageService.rememberLoginKey) ??
        false;
    hasPassword =
        await storage.readBool(AuthLocalStorageService.hasPasswordKey) ?? false;
    userRole =
        await storage.readSecureAuthValue(
          AuthLocalStorageService.userRoleKey,
        ) ??
        '';
    defaultSpaceId =
        await storage.readSecureAuthValue(
          AuthLocalStorageService.defaultSpaceIdKey,
        ) ??
        '';
    householdSpaceId =
        await storage.readSecureAuthValue(
          AuthLocalStorageService.householdSpaceIdKey,
        ) ??
        '';
    workspaceSpaceId =
        await storage.readSecureAuthValue(
          AuthLocalStorageService.workspaceSpaceIdKey,
        ) ??
        '';
    defaultCurrencyId =
        await storage.readSecureAuthValue(
          AuthLocalStorageService.defaultCurrencyIdKey,
        ) ??
        '';
    permissions = await storage.readStringList('permissions') ?? [];
    roles = await storage.readStringList('roles') ?? [];
    isViewed = await storage.readInt('onBoard');
  }
}

final AppGlobals globals = AppGlobals();
