import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/account/data/dto/account/schedule_account_deletion_request.dart';
import 'package:idile_mobile_app/features/account/data/model/account/account_data_export.dart';
import 'package:idile_mobile_app/features/account/data/service/account/account_remote_service.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/account_state.dart';

void main() {
  test('validates password and code account deletion requests', () {
    expect(
      const ScheduleAccountDeletionRequest(
        password: 'correct-horse-battery',
        confirm: 'DELETE',
      ).toJson(),
      {'password': 'correct-horse-battery', 'confirm': 'DELETE'},
    );
    expect(
      const ScheduleAccountDeletionRequest(
        code: '482913',
        confirm: ' DELETE ',
      ).toJson(),
      {'code': '482913', 'confirm': 'DELETE'},
    );
    expect(
      () => const ScheduleAccountDeletionRequest(confirm: 'DELETE').toJson(),
      throwsArgumentError,
    );
    expect(
      () => const ScheduleAccountDeletionRequest(
        code: '123',
        confirm: 'DELETE',
      ).toJson(),
      throwsArgumentError,
    );
    expect(
      () => const ScheduleAccountDeletionRequest(
        code: '482913',
        confirm: 'delete',
      ).toJson(),
      throwsArgumentError,
    );
  });

  test('uses the complete authenticated account data API contract', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer access-token');
      final path = request.url.path;

      if (request.method == 'GET' && path == '/v1/users/me/export') {
        return _response({
          'exportedAt': '2026-10-07T09:00:00.000Z',
          'account': {'email': 'ada@example.com', 'name': 'Ada Okafor'},
          'spaces': [
            {'_id': 'space-id', 'name': 'Lekki Apartment'},
          ],
          'categories': [],
          'currencies': [],
          'bills': [
            {'_id': 'bill-id', 'title': 'Ikeja Electric'},
          ],
          'subscriptions': [],
          'householdItems': [],
          'maintenanceTasks': [
            {'_id': 'maintenance-id', 'title': 'Service AC'},
          ],
          'assets': [],
          'documents': [],
          'notifications': [],
        });
      }
      if (request.method == 'POST' && path == '/v1/users/me/deletion/code') {
        expect(request.body, isEmpty);
        return _response({'sent': true});
      }
      if (request.method == 'POST' && path == '/v1/users/me/deletion') {
        expect(jsonDecode(request.body), {
          'code': '482913',
          'confirm': 'DELETE',
        });
        return _response({'deletionScheduledAt': '2026-11-06T09:00:00.000Z'});
      }
      return http.Response('Not found', 404);
    });
    final service = AccountRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final export = await service.exportData();
    final sent = await service.sendDeletionCode();
    final schedule = await service.scheduleDeletion(
      const ScheduleAccountDeletionRequest(code: '482913', confirm: 'DELETE'),
    );

    expect(export.exportedAt, DateTime.parse('2026-10-07T09:00:00.000Z'));
    expect(export.account['email'], 'ada@example.com');
    expect(export.spaces.single['name'], 'Lekki Apartment');
    expect(export.bills.single['title'], 'Ikeja Electric');
    expect(export.maintenanceTasks.single['_id'], 'maintenance-id');
    expect(sent, isTrue);
    expect(
      schedule.deletionScheduledAt,
      DateTime.parse('2026-11-06T09:00:00.000Z'),
    );
  });

  test('main account state owns export and deletion operation state', () {
    final export = AccountDataExport.fromJson({
      'exportedAt': '2026-10-07T09:00:00.000Z',
    });
    const initial = AccountState();
    final exporting = initial.copyWith(
      dataExport: export,
      isExportingData: true,
      isSendingDeletionCode: true,
      deletionCodeSent: true,
      isSchedulingDeletion: true,
      deletionScheduledAt: DateTime.utc(2026, 11, 6, 9),
    );

    expect(exporting.dataExport, same(export));
    expect(exporting.isExportingData, isTrue);
    expect(exporting.isSendingDeletionCode, isTrue);
    expect(exporting.deletionCodeSent, isTrue);
    expect(exporting.isSchedulingDeletion, isTrue);
    expect(exporting.deletionScheduledAt, DateTime.utc(2026, 11, 6, 9));
    expect(exporting.copyWith().dataExport, same(export));
  });
}

http.Response _response(Object data, {int statusCode = 200}) =>
    http.Response(jsonEncode({'success': true, 'data': data}), statusCode);
