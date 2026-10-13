import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/more/data/dto/maintenance/create_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/maintenance/get_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/maintenance/update_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/data/model/maintenance/maintenance_task.dart';
import 'package:idile_mobile_app/features/more/data/service/maintenance/maintenance_remote_service.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/maintenance_state.dart';

void main() {
  test('validates maintenance requests and pagination filters', () {
    expect(
      const CreateMaintenanceRequest(
        title: ' Service air conditioner ',
        spaceId: 'space-id',
        item: ' Living room AC ',
        lastDone: '2026-07-01',
        nextDue: '2026-10-15',
      ).toJson(),
      {
        'title': 'Service air conditioner',
        'spaceId': 'space-id',
        'item': 'Living room AC',
        'lastDone': '2026-07-01',
        'nextDue': '2026-10-15',
        'intervalMonths': 3,
      },
    );
    expect(const UpdateMaintenanceRequest(status: 'Scheduled').toJson(), {
      'status': 'scheduled',
    });
    expect(
      const GetMaintenanceRequest(
        status: 'due',
        spaceId: 'space-id',
        page: 2,
        limit: 50,
      ).toQueryParameters(),
      {
        'page': '2',
        'limit': '50',
        'status': 'due',
        'spaceId': 'space-id',
        'sort': 'nextDue:asc',
      },
    );
    expect(
      () => const UpdateMaintenanceRequest().toJson(),
      throwsArgumentError,
    );
    expect(
      () => const GetMaintenanceRequest(status: 'late').toQueryParameters(),
      throwsArgumentError,
    );
  });

  test('uses the complete authenticated maintenance API contract', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer access-token');
      final path = request.url.path;

      if (request.method == 'GET' && path == '/v1/maintenance') {
        expect(request.url.queryParameters, {
          'page': '1',
          'limit': '20',
          'status': 'due',
          'spaceId': 'space-id',
          'sort': 'nextDue:asc',
        });
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [_maintenanceJson()],
            'meta': {
              'pagination': {
                'page': 1,
                'limit': 20,
                'total': 42,
                'totalPages': 3,
                'hasNextPage': true,
                'hasPrevPage': false,
              },
            },
          }),
          200,
        );
      }
      if (request.method == 'GET' && path == '/v1/maintenance/maintenance-id') {
        return _response(_maintenanceJson());
      }
      if (request.method == 'POST' && path == '/v1/maintenance') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['intervalMonths'], 3);
        expect(body.containsKey('status'), isFalse);
        return _response(_maintenanceJson(), statusCode: 201);
      }
      if (request.method == 'PATCH' &&
          path == '/v1/maintenance/maintenance-id') {
        expect(jsonDecode(request.body), {'status': 'scheduled'});
        return _response(_maintenanceJson(status: 'scheduled'));
      }
      if (request.method == 'DELETE' &&
          path == '/v1/maintenance/maintenance-id') {
        expect(request.body, isEmpty);
        return _response({'deleted': true});
      }
      if (request.method == 'PATCH' &&
          path == '/v1/maintenance/maintenance-id/mark-done') {
        expect(request.body, isEmpty);
        return _response(
          _maintenanceJson(status: 'scheduled', nextDue: '2027-01-07'),
        );
      }
      return http.Response('Not found', 404);
    });
    final service = MaintenanceRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final page = await service.maintenance(
      const GetMaintenanceRequest(status: 'due', spaceId: 'space-id'),
    );
    final task = await service.maintenanceTask('maintenance-id');
    final created = await service.createMaintenance(
      const CreateMaintenanceRequest(
        title: 'Service air conditioner',
        spaceId: 'space-id',
        item: 'Living room AC',
        lastDone: '2026-07-01',
        nextDue: '2026-10-15',
      ),
    );
    final updated = await service.updateMaintenance(
      'maintenance-id',
      const UpdateMaintenanceRequest(status: 'scheduled'),
    );
    final deleted = await service.deleteMaintenance('maintenance-id');
    final completed = await service.markDone('maintenance-id');

    expect(page.tasks.single.id, 'maintenance-id');
    expect(page.pagination.total, 42);
    expect(page.pagination.hasNextPage, isTrue);
    expect(task.title, 'Service air conditioner');
    expect(created.intervalMonths, 3);
    expect(updated.status, 'scheduled');
    expect(deleted, isTrue);
    expect(completed.nextDue, '2027-01-07');
  });

  test('appends paginated maintenance tasks without duplicates', () {
    final first = MaintenancePage(
      tasks: [
        MaintenanceTask.fromJson(_maintenanceJson()),
        MaintenanceTask.fromJson(_maintenanceJson(id: 'two')),
      ],
      pagination: const MaintenancePagination(
        page: 1,
        limit: 2,
        total: 3,
        totalPages: 2,
        hasNextPage: true,
        hasPrevPage: false,
      ),
    );
    final second = MaintenancePage(
      tasks: [
        MaintenanceTask.fromJson(_maintenanceJson(id: 'two')),
        MaintenanceTask.fromJson(_maintenanceJson(id: 'three')),
      ],
      pagination: const MaintenancePagination(
        page: 2,
        limit: 2,
        total: 3,
        totalPages: 2,
        hasNextPage: false,
        hasPrevPage: true,
      ),
    );

    final state = MaintenanceState.fromPage(first).append(second);

    expect(state.tasks.map((task) => task.id), [
      'maintenance-id',
      'two',
      'three',
    ]);
    expect(state.page, 2);
    expect(state.hasNextPage, isFalse);
  });
}

Map<String, dynamic> _maintenanceJson({
  String id = 'maintenance-id',
  String status = 'soon',
  String nextDue = '2026-10-15',
}) => {
  '_id': id,
  'userId': 'user-id',
  'title': 'Service air conditioner',
  'spaceId': 'space-id',
  'item': 'Living room AC',
  'lastDone': '2026-07-01',
  'nextDue': nextDue,
  'status': status,
  'intervalMonths': 3,
  'createdAt': '2026-09-01T08:30:00.000Z',
  'updatedAt': '2026-10-01T08:30:00.000Z',
};

http.Response _response(Object data, {int statusCode = 200}) =>
    http.Response(jsonEncode({'success': true, 'data': data}), statusCode);
