import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/create_household_item_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/get_household_items_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/update_household_item_request.dart';
import 'package:idile_mobile_app/features/more/data/model/household_items/household_item.dart';
import 'package:idile_mobile_app/features/more/data/service/household_items/household_item_remote_service.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/household_item_state.dart';

void main() {
  test('validates household item requests and pagination filters', () {
    expect(
      const CreateHouseholdItemRequest(
        title: ' Samsung Refrigerator ',
        spaceId: 'space-id',
        room: ' Kitchen ',
        purchased: '2025-03-12',
        warranty: '2027-03-12',
        value: 450000,
        currencyId: 'currency-id',
        maintenanceId: ' maintenance-id ',
      ).toJson(),
      {
        'title': 'Samsung Refrigerator',
        'spaceId': 'space-id',
        'room': 'Kitchen',
        'purchased': '2025-03-12',
        'warranty': '2027-03-12',
        'value': 450000,
        'currencyId': 'currency-id',
        'maintenanceId': 'maintenance-id',
      },
    );
    expect(const UpdateHouseholdItemRequest(room: 'Pantry').toJson(), {
      'room': 'Pantry',
    });
    expect(
      const GetHouseholdItemsRequest(
        room: 'Kitchen',
        spaceId: 'space-id',
        page: 2,
        limit: 50,
      ).toQueryParameters(),
      {
        'page': '2',
        'limit': '50',
        'room': 'Kitchen',
        'spaceId': 'space-id',
        'sort': 'createdAt:desc',
      },
    );
    expect(
      () => const UpdateHouseholdItemRequest().toJson(),
      throwsArgumentError,
    );
    expect(
      () => const GetHouseholdItemsRequest(page: 0).toQueryParameters(),
      throwsArgumentError,
    );
  });

  test(
    'uses the complete authenticated household items API contract',
    () async {
      FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
      final client = MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer access-token');
        final path = request.url.path;

        if (request.method == 'GET' && path == '/v1/household-items') {
          expect(request.url.queryParameters, {
            'page': '1',
            'limit': '20',
            'room': 'Kitchen',
            'spaceId': 'space-id',
            'sort': 'createdAt:desc',
          });
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [_householdItemJson()],
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
        if (request.method == 'GET' &&
            path == '/v1/household-items/household-item-id') {
          return _response(_householdItemJson());
        }
        if (request.method == 'POST' && path == '/v1/household-items') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['title'], 'Samsung Refrigerator');
          expect(body['maintenanceId'], 'maintenance-id');
          return _response(_householdItemJson(), statusCode: 201);
        }
        if (request.method == 'PATCH' &&
            path == '/v1/household-items/household-item-id') {
          expect(jsonDecode(request.body), {'room': 'Pantry'});
          return _response(_householdItemJson(room: 'Pantry'));
        }
        if (request.method == 'DELETE' &&
            path == '/v1/household-items/household-item-id') {
          expect(request.body, isEmpty);
          return _response({'deleted': true});
        }
        return http.Response('Not found', 404);
      });
      final service = HouseholdItemRemoteService(
        ApiClient(
          client: client,
          store: SessionStore(storage: const FlutterSecureStorage()),
        ),
      );

      final page = await service.householdItems(
        const GetHouseholdItemsRequest(room: 'Kitchen', spaceId: 'space-id'),
      );
      final item = await service.householdItem('household-item-id');
      final created = await service.createHouseholdItem(
        const CreateHouseholdItemRequest(
          title: 'Samsung Refrigerator',
          spaceId: 'space-id',
          room: 'Kitchen',
          purchased: '2025-03-12',
          warranty: '2027-03-12',
          value: 450000,
          currencyId: 'currency-id',
          maintenanceId: 'maintenance-id',
        ),
      );
      final updated = await service.updateHouseholdItem(
        'household-item-id',
        const UpdateHouseholdItemRequest(room: 'Pantry'),
      );
      final deleted = await service.deleteHouseholdItem('household-item-id');

      expect(page.items.single.id, 'household-item-id');
      expect(page.pagination.total, 42);
      expect(page.pagination.hasNextPage, isTrue);
      expect(item.title, 'Samsung Refrigerator');
      expect(created.maintenanceId, 'maintenance-id');
      expect(updated.room, 'Pantry');
      expect(deleted, isTrue);
    },
  );

  test('appends paginated household items without duplicates', () {
    final first = HouseholdItemPage(
      items: [
        HouseholdItem.fromJson(_householdItemJson()),
        HouseholdItem.fromJson(_householdItemJson(id: 'two')),
      ],
      pagination: const HouseholdItemPagination(
        page: 1,
        limit: 2,
        total: 3,
        totalPages: 2,
        hasNextPage: true,
        hasPrevPage: false,
      ),
    );
    final second = HouseholdItemPage(
      items: [
        HouseholdItem.fromJson(_householdItemJson(id: 'two')),
        HouseholdItem.fromJson(_householdItemJson(id: 'three')),
      ],
      pagination: const HouseholdItemPagination(
        page: 2,
        limit: 2,
        total: 3,
        totalPages: 2,
        hasNextPage: false,
        hasPrevPage: true,
      ),
    );

    final state = HouseholdItemState.fromPage(first).append(second);

    expect(state.items.map((item) => item.id), [
      'household-item-id',
      'two',
      'three',
    ]);
    expect(state.page, 2);
    expect(state.hasNextPage, isFalse);
  });
}

Map<String, dynamic> _householdItemJson({
  String id = 'household-item-id',
  String room = 'Kitchen',
}) => {
  '_id': id,
  'userId': 'user-id',
  'title': 'Samsung Refrigerator',
  'spaceId': 'space-id',
  'room': room,
  'purchased': '2025-03-12',
  'warranty': '2027-03-12',
  'value': 450000,
  'currencyId': 'currency-id',
  'maintenanceId': 'maintenance-id',
  'createdAt': '2026-09-01T08:30:00.000Z',
  'updatedAt': '2026-10-01T08:30:00.000Z',
};

http.Response _response(Object data, {int statusCode = 200}) =>
    http.Response(jsonEncode({'success': true, 'data': data}), statusCode);
