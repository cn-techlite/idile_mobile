import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idile_mobile_app/features/auth/data/service/device_binding_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('idile.device-binding.test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final signedMessages = <String>[];

  setUp(() {
    signedMessages.clear();
    messenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'getDeviceInfo':
          return {
            'publicKey': {
              'kty': 'EC',
              'crv': 'P-256',
              'x': 'public-x',
              'y': 'public-y',
            },
            'name': 'Test iPhone',
            'platform': 'ios',
          };
        case 'sign':
          signedMessages.add((call.arguments as Map)['message'] as String);
          return 'raw-es256-signature';
      }
      return null;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('signs the exact Idile challenge message', () async {
    final service = DeviceBindingService(channel: channel);
    final signature = await service.signChallenge('challenge-value');

    expect(signature, 'raw-es256-signature');
    expect(signedMessages.single, 'idile-device-challenge:challenge-value');
  });

  test('creates an ES256 DPoP proof with method, URL and token hash', () async {
    final service = DeviceBindingService(channel: channel);
    final proof = await service.createDpopProof(
      method: 'get',
      uri: Uri.parse('https://api.idile.com.ng/v1/users/me?ignored=true'),
      accessToken: 'access-token',
    );

    final parts = proof.split('.');
    expect(parts, hasLength(3));
    expect(parts.last, 'raw-es256-signature');
    expect(signedMessages.single, '${parts[0]}.${parts[1]}');

    final header = _decodePart(parts[0]);
    final payload = _decodePart(parts[1]);
    expect(header['typ'], 'dpop+jwt');
    expect(header['alg'], 'ES256');
    expect(header['jwk'], containsPair('crv', 'P-256'));
    expect(payload['htm'], 'GET');
    expect(payload['htu'], 'https://api.idile.com.ng/v1/users/me');
    expect(payload['jti'], isNotEmpty);
    expect(payload['iat'], isA<int>());
    expect(payload['ath'], isNotEmpty);
  });
}

Map<String, dynamic> _decodePart(String part) => Map<String, dynamic>.from(
  jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(part)))) as Map,
);
