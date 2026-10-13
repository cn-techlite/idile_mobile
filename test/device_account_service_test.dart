import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/account/data/service/devices/device_remote_service.dart';

void main() {
  test('loads every registered device for the authenticated user', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.toString(), 'https://api.idile.com.ng/v1/devices');
      expect(request.headers['authorization'], 'Bearer access-token');
      return http.Response(
        jsonEncode({
          'success': true,
          'data': [
            {
              'id': 'device-id',
              'name': "Ada's iPhone",
              'platform': 'ios',
              'status': 'approved',
              'createdAt': '2026-09-01T08:30:00.000Z',
              'approvedAt': '2026-09-01T08:32:00.000Z',
              'lastUsedAt': '2026-10-07T07:12:00.000Z',
              'revokedAt': null,
            },
          ],
        }),
        200,
      );
    });
    final service = DeviceRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final devices = await service.devices();

    expect(devices, hasLength(1));
    expect(devices.single.id, 'device-id');
    expect(devices.single.name, "Ada's iPhone");
    expect(devices.single.platform, 'ios');
    expect(devices.single.status, 'approved');
    expect(devices.single.lastUsedAt, DateTime.utc(2026, 10, 7, 7, 12));
    expect(devices.single.canRevoke, isTrue);
  });

  test('revokes a device using its authenticated id route', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.method, 'DELETE');
      expect(
        request.url.toString(),
        'https://api.idile.com.ng/v1/devices/device-id',
      );
      expect(request.headers['authorization'], 'Bearer access-token');
      expect(request.body, isEmpty);
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'id': 'device-id',
            'name': "Ada's iPhone",
            'platform': 'ios',
            'status': 'revoked',
            'createdAt': '2026-09-01T08:30:00.000Z',
            'approvedAt': '2026-09-01T08:32:00.000Z',
            'lastUsedAt': '2026-10-07T07:12:00.000Z',
            'revokedAt': '2026-10-07T09:00:00.000Z',
          },
        }),
        200,
      );
    });
    final service = DeviceRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final device = await service.revokeDevice('device-id');

    expect(device.status, 'revoked');
    expect(device.revokedAt, DateTime.utc(2026, 10, 7, 9));
    expect(device.canRevoke, isFalse);
  });
}
