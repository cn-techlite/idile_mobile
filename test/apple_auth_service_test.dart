import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/features/auth/data/model/apple_sign_in_payload.dart';
import 'package:idile_mobile_app/features/auth/data/model/device_binding_models.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_remote_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/social_auth_service.dart';

void main() {
  const apple = AppleSignInPayload(
    credential: 'apple-identity-token',
    nonce: 'raw-nonce',
    name: 'Tola Adeyemi',
    authorizationCode: 'apple-authorization-code',
  );

  test('exchanges an Apple credential using the standard endpoint', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.toString(), 'https://api.idile.com.ng/v1/auth/apple');
      expect(request.headers['accept'], 'application/json');
      expect(request.headers['content-type'], 'application/json');
      expect(request.headers['user-agent'], 'IdileMobileApp/1.0.0 (Flutter)');
      expect(jsonDecode(request.body), apple.toJson());
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'accessToken': 'access-token',
            'refreshToken': 'refresh-token',
            'remember': true,
          },
        }),
        200,
      );
    });

    final response = await SocialAuthService(httpClient: client)
        .exchangeAppleCredential(apple);

    expect(response.statusCode, 200);
  });

  test('uses the device-bound Apple endpoint and complete payload', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(
        request.url.toString(),
        'https://api.idile.com.ng/v1/auth/device/apple',
      );
      expect(request.headers['user-agent'], 'IdileMobileApp/1.0.0 (Flutter)');
      expect(jsonDecode(request.body), {
        ...apple.toJson(),
        'device': {
          'publicKey': {
            'kty': 'EC',
            'crv': 'P-256',
            'x': 'public-x',
            'y': 'public-y',
          },
          'name': 'Ada’s iPhone',
          'platform': 'ios',
        },
        'challenge': 'challenge-value',
        'signature': 'signed-challenge',
      });
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'status': 'signed_in',
            'deviceId': 'device-id',
            'accessToken': 'access-token',
            'refreshToken': 'refresh-token',
          },
        }),
        200,
      );
    });
    final service = AuthRemoteService(apiClient: ApiClient(client: client));

    final result = await service.deviceApple(
      apple: apple,
      device: const DeviceInfo(
        publicKey: DevicePublicKey(
          kty: 'EC',
          crv: 'P-256',
          x: 'public-x',
          y: 'public-y',
        ),
        name: 'Ada’s iPhone',
        platform: 'ios',
      ),
      challenge: 'challenge-value',
      signature: 'signed-challenge',
    );

    expect(result.isSignedIn, isTrue);
    expect(result.deviceId, 'device-id');
  });

  test('omits name when Apple does not return it again', () {
    expect(
      const AppleSignInPayload(
        credential: 'credential',
        nonce: 'nonce',
        authorizationCode: 'code',
      ).toJson(),
      {
        'credential': 'credential',
        'nonce': 'nonce',
        'authorizationCode': 'code',
      },
    );
  });
}
