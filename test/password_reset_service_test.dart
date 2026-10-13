import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_remote_service.dart';

void main() {
  test('verifies code and returns the single-use reset token', () async {
    final client = MockClient((request) async {
      expect(request.headers['user-agent'], 'IdileMobileApp/1.0.0 (Flutter)');
      expect(
        request.url.toString(),
        'https://api.idile.com.ng/v1/auth/password/verify',
      );
      expect(jsonDecode(request.body), {
        'email': 'ada@example.com',
        'code': '123456',
      });
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {'resetToken': 'single-use-token'},
        }),
        200,
      );
    });
    final service = AuthRemoteService(apiClient: ApiClient(client: client));

    final token = await service.verifyPasswordResetCode(
      email: 'ada@example.com',
      code: '123456',
    );

    expect(token, 'single-use-token');
  });
}
