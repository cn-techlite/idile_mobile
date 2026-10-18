import 'package:idile_mobile_app/features/auth/domain/entities/login_response.dart';
import 'package:idile_mobile_app/features/account/domain/entities/profile/user_profile.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalStorageService {
  static const _secureStorage = FlutterSecureStorage();

  static const tokenKey = "token";
  static const refreshTokenKey = "refreshToken";
  static const userEmailKey = "userEmail";
  static const userIdKey = "userId";
  static const userNameKey = "userName";
  static const profilePictureKey = "profilePicture";
  static const isSubscriptionActiveKey = "isSubscriptionActive";
  static const subscriptionExpiresAtKey = "subscriptionExpiresAt";
  static const userPasswordKey = "userPassword";
  static const rememberLoginKey = "rememberLogin";
  static const userRoleKey = "userRole";
  static const hasPasswordKey = "hasPassword";
  static const defaultSpaceIdKey = "defaultSpaceId";
  static const householdSpaceIdKey = "householdSpaceId";
  static const workspaceSpaceIdKey = "workspaceSpaceId";
  static const defaultCurrencyIdKey = "defaultCurrencyId";

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  Future<void> writeString(String key, String value) async {
    await (await _preferences).setString(key, value);
  }

  Future<void> writeInt(String key, int value) async {
    await (await _preferences).setInt(key, value);
  }

  Future<void> writeDouble(String key, double value) async {
    await (await _preferences).setDouble(key, value);
  }

  Future<void> writeBool(String key, bool value) async {
    await (await _preferences).setBool(key, value);
  }

  Future<void> writeStringList(String key, List<String> value) async {
    await (await _preferences).setStringList(key, value);
  }

  Future<String?> readString(String key) async =>
      (await _preferences).getString(key);

  Future<int?> readInt(String key) async => (await _preferences).getInt(key);

  Future<double?> readDouble(String key) async {
    final value = (await _preferences).get(key);
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return null;
  }

  Future<bool?> readBool(String key) async => (await _preferences).getBool(key);

  Future<List<String>?> readStringList(String key) async =>
      (await _preferences).getStringList(key);

  Future<void> remove(String key) async {
    await (await _preferences).remove(key);
  }

  Future<void> saveLoginSession({
    required LoginResponseModel model,
    String? password,
  }) async {
    await _saveSecureSession(model);

    await writeBool("isHomeLoaded", true);
    await writeBool("isEmailVerified", model.emailVerified ?? true);
    await writeBool(rememberLoginKey, model.remember ?? false);
    await writeStringList("roles", model.roles ?? []);
    await writeStringList("permissions", model.permissions ?? []);
  }

  Future<void> saveRefreshedTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _writeSecureString(tokenKey, accessToken);
    await _writeSecureString(refreshTokenKey, refreshToken);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _writeSecureString(userIdKey, profile.id);
    await _writeSecureString(userEmailKey, profile.email);
    await _writeSecureString(userNameKey, profile.name);
    await _writeSecureString(userRoleKey, profile.role);
    await _writeSecureString(profilePictureKey, profile.avatarUrl);
    await _writeSecureString(defaultSpaceIdKey, profile.defaultSpaceId);
    await _writeSecureString(householdSpaceIdKey, profile.householdSpaceId);
    await _writeSecureString(workspaceSpaceIdKey, profile.workspaceSpaceId);
    await _writeSecureString(defaultCurrencyIdKey, profile.defaultCurrencyId);
    await writeBool(hasPasswordKey, profile.hasPassword);
  }

  Future<void> saveSocialLoginSession({
    required LoginResponseModel model,
    required String providerUid,
  }) async {
    await _saveSecureSession(model);

    await writeBool("isHomeLoaded", true);
    await writeBool("isEmailVerified", model.emailVerified ?? false);
    await writeBool(rememberLoginKey, model.remember ?? false);
    await writeStringList("roles", model.roles ?? []);
    await writeStringList("permissions", model.permissions ?? []);
  }

  Future<void> saveVerifiedEmailSession({
    required LoginResponseModel model,
    required String password,
  }) async {
    await _saveSecureSession(model);

    await writeBool("isEmailVerified", model.emailVerified ?? false);
    await writeString("isLoggedIn", "isLoggedIn");
    await writeStringList("roles", model.roles ?? []);
    await writeStringList("permissions", model.permissions ?? []);
  }

  Future<void> clearAuthSession() async {
    await clearSecureAuthSession();
    await _removeLegacySensitiveValues();

    await writeString("isLoggedIn", "");
    await writeBool("isHomeLoaded", false);
    await writeBool("isEmailVerified", false);
    await writeBool(rememberLoginKey, false);
    await writeBool(hasPasswordKey, false);
    await writeStringList("roles", []);
    await writeStringList("permissions", []);
    await writeBool("activateBrand", false);
    await writeBool("activateProfession", false);
    await remove("InfoCompleted");
  }

  Future<String?> readSecureAuthValue(String key) {
    return _secureStorage.read(key: key);
  }

  Future<void> migrateLegacySessionIfNeeded() async {
    final secureToken = await readSecureAuthValue(tokenKey);
    if ((secureToken ?? '').isNotEmpty) {
      await remove(userPasswordKey);
      return;
    }

    for (final key in _secureKeys) {
      if (key == userPasswordKey) continue;

      final value = await readString(key);
      if ((value ?? '').toString().isNotEmpty) {
        await _writeSecureString(key, value);
      }
    }

    await _removeLegacySensitiveValues();
  }

  Future<void> clearSecureAuthSession() async {
    await SessionStore().clear();
    for (final key in _secureKeys) {
      await _secureStorage.delete(key: key);
    }
  }

  Future<void> _saveSecureSession(LoginResponseModel model) async {
    await _writeSecureString(tokenKey, model.token);
    await _writeSecureString(refreshTokenKey, model.refreshToken);
    await _writeSecureString(userEmailKey, model.email);
    await _writeSecureString(userIdKey, model.userId);
    await _writeSecureString(userNameKey, model.fullName);
    await _writeSecureString(profilePictureKey, model.profileImage);
    await _writeSecureString(
      isSubscriptionActiveKey,
      (model.isSubscriptionActive ?? false).toString(),
    );
    await _writeSecureString(
      subscriptionExpiresAtKey,
      model.subscriptionExpiresAt?.toIso8601String(),
    );
    await writeString("InfoCompleted", model.infoCompleted?.trim() ?? "");
    await remove(userPasswordKey);
  }

  Future<void> _writeSecureString(String key, String? value) async {
    final normalizedValue = (value ?? '').trim();
    if (normalizedValue.isEmpty) {
      await _secureStorage.delete(key: key);
      return;
    }

    await _secureStorage.write(key: key, value: normalizedValue);
  }

  Future<void> _removeLegacySensitiveValues() async {
    for (final key in _secureKeys) {
      await remove(key);
    }
  }
}

const _secureKeys = <String>[
  AuthLocalStorageService.tokenKey,
  AuthLocalStorageService.refreshTokenKey,
  AuthLocalStorageService.userEmailKey,
  AuthLocalStorageService.userIdKey,
  AuthLocalStorageService.userNameKey,
  AuthLocalStorageService.profilePictureKey,
  AuthLocalStorageService.isSubscriptionActiveKey,
  AuthLocalStorageService.subscriptionExpiresAtKey,
  AuthLocalStorageService.userPasswordKey,
  AuthLocalStorageService.userRoleKey,
  AuthLocalStorageService.defaultSpaceIdKey,
  AuthLocalStorageService.householdSpaceIdKey,
  AuthLocalStorageService.workspaceSpaceIdKey,
  AuthLocalStorageService.defaultCurrencyIdKey,
];
