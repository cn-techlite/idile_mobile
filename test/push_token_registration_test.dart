import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/auth/data/model/device_binding_models.dart';
import 'package:idile_mobile_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_remote_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_session_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/device_binding_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/push_token_registration_service.dart';
import 'package:idile_mobile_app/features/auth/data/service/social_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      PushTokenRegistrationService.deviceTokenStorageKey: 'stored-fcm-token',
    });
    FlutterSecureStorage.setMockInitialValues({
      'token': 'access-token',
      'refreshToken': 'refresh-token',
      'idile_device_bound': 'true',
      'idile_device_id': 'device-id',
    });
  });

  test(
    'registers the stored FCM token once using the device-bound API',
    () async {
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'registered': true},
          }),
          200,
        );
      });
      final service = _service(client);

      expect(await service.registerStoredToken(force: true), isTrue);
      expect(await service.registerStoredToken(), isTrue);

      expect(requests, hasLength(1));
      final request = requests.single;
      expect(request.method, 'PUT');
      expect(
        request.url.toString(),
        'https://api.idile.com.ng/v1/devices/me/push-token',
      );
      expect(request.headers['authorization'], 'DPoP access-token');
      expect(request.headers['dpop'], 'test-dpop-proof');
      expect(request.headers['user-agent'], 'IdileMobileApp/1.0.0 (Flutter)');
      expect(jsonDecode(request.body), {'token': 'stored-fcm-token'});
    },
  );

  test('removes the push token before local session cleanup', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {'removed': true},
        }),
        200,
      );
    });

    expect(await _service(client).remove(), isTrue);

    expect(captured.method, 'DELETE');
    expect(
      captured.url.toString(),
      'https://api.idile.com.ng/v1/devices/me/push-token',
    );
    expect(captured.headers['authorization'], 'DPoP access-token');
    expect(captured.headers['dpop'], 'test-dpop-proof');
  });

  test('does not call the API without a device-bound session', () async {
    FlutterSecureStorage.setMockInitialValues({
      'token': 'access-token',
      'refreshToken': 'refresh-token',
    });
    var called = false;
    final service = _service(
      MockClient((_) async {
        called = true;
        return http.Response('{}', 200);
      }),
    );

    expect(await service.registerStoredToken(force: true), isFalse);
    expect(called, isFalse);
  });

  test(
    'registers the FCM token once after a successful device login',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        if (request.url.path.endsWith('/auth/device/challenge')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'challenge': 'challenge',
                'expiresAt': '2030-10-08T09:00:00.000Z',
              },
            }),
            200,
          );
        }
        if (request.url.path.endsWith('/auth/device/login')) {
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
        }
        if (request.url.path.endsWith('/devices/me/push-token')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {'registered': true},
            }),
            200,
          );
        }
        return http.Response('{}', 404);
      });
      const storage = FlutterSecureStorage();
      final deviceBinding = _FakeDeviceBindingService();
      final api = ApiClient(
        client: client,
        store: SessionStore(storage: storage),
        deviceBindingService: deviceBinding,
      );
      final localStorage = AuthLocalStorageService();
      final repository = AuthRepositoryImpl(
        remoteService: AuthRemoteService(apiClient: api),
        socialAuthService: SocialAuthService(),
        localStorageService: localStorage,
        sessionService: AuthSessionService(),
        deviceBindingService: deviceBinding,
        pushTokenRegistration: PushTokenRegistrationService(
          apiClient: api,
          localStorage: localStorage,
        ),
      );

      final result = await repository.login(
        email: 'ada@example.com',
        password: 'correct-horse-battery',
        rememberMe: true,
      );

      expect(result.isSuccess, isTrue);
      final pushRequests = requests
          .where(
            (request) => request.url.path.endsWith('/devices/me/push-token'),
          )
          .toList();
      expect(pushRequests, hasLength(1));
      expect(pushRequests.single.method, 'PUT');
      expect(jsonDecode(pushRequests.single.body), {
        'token': 'stored-fcm-token',
      });
    },
  );
}

PushTokenRegistrationService _service(http.Client client) {
  const storage = FlutterSecureStorage();
  return PushTokenRegistrationService(
    apiClient: ApiClient(
      client: client,
      store: SessionStore(storage: storage),
      deviceBindingService: _FakeDeviceBindingService(),
    ),
    localStorage: AuthLocalStorageService(),
  );
}

class _FakeDeviceBindingService extends DeviceBindingService {
  @override
  Future<DeviceInfo> getDeviceInfo() async => const DeviceInfo(
    publicKey: DevicePublicKey(kty: 'EC', crv: 'P-256', x: 'x', y: 'y'),
    name: 'Test phone',
    platform: 'android',
  );

  @override
  Future<String> signChallenge(String challenge) async => 'signature';

  @override
  Future<String> createDpopProof({
    required String method,
    required Uri uri,
    String? accessToken,
  }) async => 'test-dpop-proof';
}
