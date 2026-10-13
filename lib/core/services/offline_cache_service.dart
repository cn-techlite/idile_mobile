import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class OfflineCacheService {
  static const _boxName = 'encrypted_api_cache';
  static const _encryptionKeyName = 'offline_cache_encryption_key';
  static const _secureStorage = FlutterSecureStorage();
  static Box<String>? _box;

  static Future<void> initialize() async {
    if (_box?.isOpen == true) return;
    var encodedKey = await _secureStorage.read(key: _encryptionKeyName);
    if (encodedKey == null) {
      final random = Random.secure();
      encodedKey = base64UrlEncode(
        List<int>.generate(32, (_) => random.nextInt(256)),
      );
      await _secureStorage.write(key: _encryptionKeyName, value: encodedKey);
    }
    _box = await Hive.openBox<String>(
      _boxName,
      encryptionCipher: HiveAesCipher(base64Url.decode(encodedKey)),
    );
  }

  static Future<void> write(String key, String json) async {
    await initialize();
    await _box!.put(key, json);
  }

  static String? read(String key) {
    if (_box?.isOpen != true) return null;
    return _box!.get(key);
  }

  static Future<void> clear() async {
    if (_box?.isOpen == true) await _box!.clear();
  }
}
