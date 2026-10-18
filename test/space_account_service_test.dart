import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/spaces/create_space_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/spaces/update_space_request.dart';
import 'package:idile_mobile_app/features/account/data/service/spaces/space_remote_service.dart';

void main() {
  test('validates create and partial update space requests', () {
    expect(
      const CreateSpaceRequest(
        name: '  Lekki Apartment  ',
        icon: ' home ',
      ).toJson(),
      {'name': 'Lekki Apartment', 'icon': 'home'},
    );
    expect(const UpdateSpaceRequest(icon: 'work').toJson(), {'icon': 'work'});
    expect(() => const UpdateSpaceRequest().toJson(), throwsArgumentError);
  });

  test('uses the complete authenticated spaces API contract', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer access-token');
      final path = request.url.path;

      if (request.method == 'GET' && path == '/v1/spaces') {
        return _response([
          {
            '_id': 'space-id',
            'userId': 'user-id',
            'name': 'Lekki Apartment',
            'icon': 'home',
            'createdAt': '2026-09-01T08:30:00.000Z',
            'updatedAt': '2026-10-01T08:30:00.000Z',
            'itemCount': 12,
          },
        ]);
      }

      if (request.method == 'POST' && path == '/v1/spaces') {
        expect(jsonDecode(request.body), {
          'name': 'Lekki Apartment',
          'icon': 'home',
        });
        return _response({
          '_id': 'space-id',
          'userId': 'user-id',
          'name': 'Lekki Apartment',
          'icon': 'home',
          'createdAt': '2026-09-01T08:30:00.000Z',
          'updatedAt': '2026-09-01T08:30:00.000Z',
        }, statusCode: 201);
      }

      if (request.method == 'GET' && path == '/v1/spaces/space-id/summary') {
        return _response({
          'counts': {
            'bills': 4,
            'subscriptions': 3,
            'householdItems': 2,
            'maintenance': 1,
            'assets': 1,
            'documents': 1,
            'total': 12,
          },
          'attention': {
            'bills': [
              {
                '_id': 'bill-id',
                'title': 'Ikeja Electric',
                'status': 'upcoming',
                'amount': 25000,
              },
            ],
            'subscriptions': [],
            'maintenance': [],
            'assets': [],
            'documents': [],
          },
          'spendByCurrency': [
            {'currencyId': 'currency-id', 'total': 54400},
          ],
        });
      }

      if (request.method == 'PATCH' && path == '/v1/spaces/space-id') {
        expect(jsonDecode(request.body), {
          'name': 'Ikoyi Apartment',
          'icon': 'apartment',
        });
        return _response({
          '_id': 'space-id',
          'userId': 'user-id',
          'name': 'Ikoyi Apartment',
          'icon': 'apartment',
          'createdAt': '2026-09-01T08:30:00.000Z',
          'updatedAt': '2026-10-07T09:00:00.000Z',
        });
      }

      if (request.method == 'DELETE' && path == '/v1/spaces/space-id') {
        expect(request.body, isEmpty);
        return _response({'deleted': true});
      }

      return http.Response('Not found', 404);
    });
    final service = SpaceRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final spaces = await service.spaces();
    final created = await service.createSpace(
      const CreateSpaceRequest(name: 'Lekki Apartment', icon: 'home'),
    );
    final summary = await service.summary('space-id');
    final updated = await service.updateSpace(
      'space-id',
      const UpdateSpaceRequest(name: 'Ikoyi Apartment', icon: 'apartment'),
    );
    final deleted = await service.deleteSpace('space-id');

    expect(spaces.single.itemCount, 12);
    expect(created.name, 'Lekki Apartment');
    expect(summary.counts['total'], 12);
    expect(summary.attention.bills.single.title, 'Ikeja Electric');
    expect(summary.attention.bills.single.raw['amount'], 25000);
    expect(summary.spendByCurrency.single.total, 54400);
    expect(updated.name, 'Ikoyi Apartment');
    expect(updated.icon, 'apartment');
    expect(deleted, isTrue);
  });
}

http.Response _response(Object data, {int statusCode = 200}) =>
    http.Response(jsonEncode({'success': true, 'data': data}), statusCode);
