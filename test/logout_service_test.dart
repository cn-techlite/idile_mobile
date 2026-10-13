import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_remote_service.dart';

void main() {
  test('logout sends the refresh token with bearer authentication', () async {
    FlutterSecureStorage.setMockInitialValues({
      'token': 'access-token',
      'refreshToken': 'refresh-token',
    });
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.toString(), 'https://api.idile.com.ng/v1/auth/logout');
      expect(request.headers['authorization'], 'Bearer access-token');
      expect(request.headers['user-agent'], 'IdileMobileApp/1.0.0 (Flutter)');
      expect(jsonDecode(request.body), {'refreshToken': 'refresh-token'});

      return http.Response(
        jsonEncode({
          'success': true,
          'data': {'loggedOut': true},
        }),
        200,
      );
    });
    final service = AuthRemoteService(
      apiClient: ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    await service.logoutSession();
  });
}
