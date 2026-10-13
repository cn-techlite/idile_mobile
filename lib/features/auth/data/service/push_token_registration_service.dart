import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/auth/data/dto/register_push_token_request.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_local_storage_service.dart';

class PushTokenRegistrationService {
  PushTokenRegistrationService({
    ApiClient? apiClient,
    AuthLocalStorageService? localStorage,
  }) : _api = apiClient ?? ApiClient(),
       _localStorage = localStorage ?? AuthLocalStorageService();

  static const deviceTokenStorageKey = 'deviceToken';
  static const _registeredTokenFingerprintKey =
      'registeredPushTokenFingerprint';

  final ApiClient _api;
  final AuthLocalStorageService _localStorage;
  String? _lastRegisteredFingerprint;

  Future<bool> registerStoredToken({bool force = false}) async {
    final token = await _localStorage.readString(deviceTokenStorageKey) ?? '';
    return register(token, force: force);
  }

  Future<bool> register(String token, {bool force = false}) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) return false;

    final accessToken = (await _api.store.accessToken)?.trim() ?? '';
    final isDeviceBound = await _api.store.isDeviceBound;
    final deviceId = (await _api.store.deviceId)?.trim() ?? '';
    if (accessToken.isEmpty || !isDeviceBound || deviceId.isEmpty) return false;

    final fingerprint = '$deviceId:$normalizedToken';
    if (_lastRegisteredFingerprint == fingerprint) return true;
    if (!force &&
        await _localStorage.readString(_registeredTokenFingerprintKey) ==
            fingerprint) {
      _lastRegisteredFingerprint = fingerprint;
      return true;
    }

    final registered = await _api.put<bool>(
      '/${Endpoints.devicePushTokenUrl}',
      (value) => value is Map ? value['registered'] == true : true,
      body: RegisterPushTokenRequest(token: normalizedToken).toJson(),
    );
    if (!registered) return false;

    _lastRegisteredFingerprint = fingerprint;
    await _localStorage.writeString(
      _registeredTokenFingerprintKey,
      fingerprint,
    );
    return true;
  }

  Future<bool> remove() async {
    final accessToken = (await _api.store.accessToken)?.trim() ?? '';
    final isDeviceBound = await _api.store.isDeviceBound;
    if (accessToken.isEmpty || !isDeviceBound) {
      await clearRegistrationMarker();
      return false;
    }

    final removed = await _api.delete<bool>(
      '/${Endpoints.devicePushTokenUrl}',
      (value) => value is Map ? value['removed'] == true : true,
    );
    if (removed) await clearRegistrationMarker();
    return removed;
  }

  Future<void> clearRegistrationMarker() async {
    _lastRegisteredFingerprint = null;
    await _localStorage.remove(_registeredTokenFingerprintKey);
  }
}
