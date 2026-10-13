import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:idile_mobile_app/features/auth/data/model/device_binding_models.dart';

class DeviceBindingService {
  DeviceBindingService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'com.app.idile_mobile_app/device_binding';
  static const challengePrefix = 'idile-device-challenge:';

  final MethodChannel _channel;

  Future<DeviceInfo> getDeviceInfo() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'getDeviceInfo',
    );
    if (result == null) {
      throw const DeviceBindingException('Unable to create the device key.');
    }
    final info = DeviceInfo.fromJson(result);
    if (info.publicKey.x.isEmpty || info.publicKey.y.isEmpty) {
      throw const DeviceBindingException('The device public key is invalid.');
    }
    return info;
  }

  Future<String> signChallenge(String challenge) =>
      sign('$challengePrefix$challenge');

  Future<String> sign(String message) async {
    final signature = await _channel.invokeMethod<String>('sign', {
      'message': message,
    });
    if (signature == null || signature.isEmpty) {
      throw const DeviceBindingException('The device signature is empty.');
    }
    return signature;
  }

  Future<String> createDpopProof({
    required String method,
    required Uri uri,
    String? accessToken,
  }) async {
    final device = await getDeviceInfo();
    final header = <String, dynamic>{
      'typ': 'dpop+jwt',
      'alg': 'ES256',
      'jwk': device.publicKey.toJson(),
    };
    final target = uri.toString().split('#').first.split('?').first;
    final payload = <String, dynamic>{
      'htm': method.toUpperCase(),
      'htu': target,
      'iat': DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
      'jti': _uuidV4(),
      if (accessToken != null && accessToken.isNotEmpty)
        'ath': _base64Url(sha256.convert(utf8.encode(accessToken)).bytes),
    };
    final encodedHeader = _base64Url(utf8.encode(jsonEncode(header)));
    final encodedPayload = _base64Url(utf8.encode(jsonEncode(payload)));
    final signingInput = '$encodedHeader.$encodedPayload';
    final signature = await sign(signingInput);
    return '$signingInput.$signature';
  }

  Future<void> deleteKey() => _channel.invokeMethod<void>('deleteKey');

  String _uuidV4() {
    final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((value) => value.toRadixString(16).padLeft(2, '0'));
    final text = hex.join();
    return '${text.substring(0, 8)}-${text.substring(8, 12)}-'
        '${text.substring(12, 16)}-${text.substring(16, 20)}-'
        '${text.substring(20)}';
  }
}

String _base64Url(List<int> bytes) =>
    base64UrlEncode(bytes).replaceAll('=', '');

class DeviceBindingException implements Exception {
  const DeviceBindingException(this.message);
  final String message;

  @override
  String toString() => message;
}
