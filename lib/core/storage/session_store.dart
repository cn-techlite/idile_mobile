import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStore {
  SessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'token';
  static const _refreshKey = 'refreshToken';
  static const _legacyAccessKey = 'idile_access_token';
  static const _legacyRefreshKey = 'idile_refresh_token';
  static const _deviceBoundKey = 'idile_device_bound';
  static const _deviceIdKey = 'idile_device_id';
  final FlutterSecureStorage _storage;

  Future<String?> get accessToken =>
      _readAndMigrate(_accessKey, _legacyAccessKey);
  Future<String?> get refreshToken =>
      _readAndMigrate(_refreshKey, _legacyRefreshKey);
  Future<bool> get isDeviceBound async =>
      (await _storage.read(key: _deviceBoundKey)) == 'true';
  Future<String?> get deviceId => _storage.read(key: _deviceIdKey);

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    bool? deviceBound,
    String? deviceId,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
    await _storage.delete(key: _legacyAccessKey);
    await _storage.delete(key: _legacyRefreshKey);
    if (deviceBound != null) {
      await _storage.write(key: _deviceBoundKey, value: deviceBound.toString());
      if (!deviceBound) await _storage.delete(key: _deviceIdKey);
    }
    if (deviceId != null && deviceId.isNotEmpty) {
      await _storage.write(key: _deviceIdKey, value: deviceId);
    }
  }

  Future<void> saveDeviceBoundSession({
    required String accessToken,
    required String refreshToken,
    required String deviceId,
  }) => save(
    accessToken: accessToken,
    refreshToken: refreshToken,
    deviceBound: true,
    deviceId: deviceId,
  );

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _legacyAccessKey);
    await _storage.delete(key: _legacyRefreshKey);
    await _storage.delete(key: _deviceBoundKey);
    await _storage.delete(key: _deviceIdKey);
  }

  Future<String?> _readAndMigrate(String key, String legacyKey) async {
    final value = await _storage.read(key: key);
    if (value != null && value.isNotEmpty) return value;

    final legacyValue = await _storage.read(key: legacyKey);
    if (legacyValue == null || legacyValue.isEmpty) return null;

    await _storage.write(key: key, value: legacyValue);
    await _storage.delete(key: legacyKey);
    return legacyValue;
  }
}
