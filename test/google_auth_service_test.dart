import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/features/auth/data/service/social_auth_service.dart';

void main() {
  String googleToken({required Object audience, required int expiresAt}) {
    String encode(Object value) =>
        base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

    return '${encode({'alg': 'RS256', 'typ': 'JWT'})}.'
        '${encode({'iss': 'https://accounts.google.com', 'aud': audience, 'exp': expiresAt})}.'
        'signature';
  }

  test('exchanges Google ID token using the credential payload', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.toString(), 'https://api.idile.com.ng/v1/auth/google');
      expect(request.headers['accept'], 'application/json');
      expect(request.headers['content-type'], 'application/json');
      expect(request.headers['user-agent'], 'IdileMobileApp/1.0.0 (Flutter)');
      expect(jsonDecode(request.body), {'credential': 'google-id-token'});

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
    final service = SocialAuthService(httpClient: client);

    final response = await service.exchangeGoogleCredential(
      ' google-id-token ',
    );

    expect(response.statusCode, 200);
  });

  test('accepts a current Google token for the configured audience', () {
    final now = DateTime.utc(2026, 10, 8, 10);
    final token = googleToken(
      audience: 'idile-client.apps.googleusercontent.com',
      expiresAt:
          now.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
    );

    expect(
      () => validateGoogleIdToken(
        token,
        expectedAudience: 'idile-client.apps.googleusercontent.com',
        now: now,
      ),
      returnsNormally,
    );
  });

  test('rejects a Google token issued for another OAuth client', () {
    final now = DateTime.utc(2026, 10, 8, 10);
    final token = googleToken(
      audience: 'other-client.apps.googleusercontent.com',
      expiresAt:
          now.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
    );

    expect(
      () => validateGoogleIdToken(
        token,
        expectedAudience: 'idile-client.apps.googleusercontent.com',
        now: now,
      ),
      throwsA(
        isA<GoogleIdTokenException>().having(
          (error) => error.message,
          'message',
          contains('different app'),
        ),
      ),
    );
  });
}
