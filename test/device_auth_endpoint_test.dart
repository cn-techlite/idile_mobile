import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/features/auth/data/model/apple_sign_in_payload.dart';
import 'package:idile_mobile_app/features/auth/data/model/device_binding_models.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_remote_service.dart';

void main() {
  test('uses the complete Idile mobile-device endpoint contract', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      if (request.url.path.endsWith('/device/challenge')) {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'challenge': 'challenge',
              'expiresAt': '2026-10-07T09:05:00.000Z',
            },
          }),
          200,
        );
      }
      if (request.url.path.endsWith('/device/not-me')) {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'revoked': true},
          }),
          200,
        );
      }
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {'status': 'approval_required', 'deviceId': 'device-id'},
        }),
        200,
      );
    });
    final service = AuthRemoteService(apiClient: ApiClient(client: client));
    const device = DeviceInfo(
      publicKey: DevicePublicKey(kty: 'EC', crv: 'P-256', x: 'x', y: 'y'),
      name: 'Test phone',
      platform: 'ios',
    );

    await service.getDeviceChallenge();
    await service.deviceLogin(
      email: 'ada@example.com',
      password: 'correct-horse-battery',
      device: device,
      challenge: 'challenge',
      signature: 'signature',
    );
    await service.deviceGoogle(
      credential: 'google-id-token',
      device: device,
      challenge: 'challenge',
      signature: 'signature',
    );
    await service.deviceApple(
      apple: const AppleSignInPayload(
        credential: 'apple-identity-token',
        nonce: 'raw-nonce',
        name: 'Ada Lovelace',
        authorizationCode: 'authorization-code',
      ),
      device: device,
      challenge: 'challenge',
      signature: 'signature',
    );
    await service.approveDevice(
      deviceId: 'device-id',
      code: '482913',
      challenge: 'fresh-challenge',
      signature: 'fresh-signature',
    );
    await service.reportUnrecognisedDevice('not-me-token');

    expect(requests.map((request) => request.url.path), [
      '/v1/auth/device/challenge',
      '/v1/auth/device/login',
      '/v1/auth/device/google',
      '/v1/auth/device/apple',
      '/v1/auth/device/approve',
      '/v1/auth/device/not-me',
    ]);
    expect(requests.every((request) => request.method == 'POST'), isTrue);
    final loginBody = jsonDecode(requests[1].body) as Map<String, dynamic>;
    expect(loginBody['email'], 'ada@example.com');
    expect(loginBody['device'], containsPair('platform', 'ios'));
    expect(loginBody['challenge'], 'challenge');
    expect(loginBody['signature'], 'signature');
    final googleBody = jsonDecode(requests[2].body) as Map<String, dynamic>;
    expect(googleBody['credential'], 'google-id-token');
    final appleBody = jsonDecode(requests[3].body) as Map<String, dynamic>;
    expect(appleBody['credential'], 'apple-identity-token');
    expect(appleBody['nonce'], 'raw-nonce');
    expect(appleBody['authorizationCode'], 'authorization-code');
    final approvalBody = jsonDecode(requests[4].body) as Map<String, dynamic>;
    expect(approvalBody['code'], '482913');
    expect(approvalBody['challenge'], 'fresh-challenge');
    expect(jsonDecode(requests[5].body), containsPair('token', 'not-me-token'));
  });
}
