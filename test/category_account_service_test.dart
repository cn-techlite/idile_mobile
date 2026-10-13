import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/account/data/dto/categories/create_category_request.dart';
import 'package:idile_mobile_app/features/account/data/dto/categories/update_category_request.dart';
import 'package:idile_mobile_app/features/account/data/service/categories/category_remote_service.dart';

void main() {
  test('validates and normalizes category requests', () {
    expect(const CreateCategoryRequest(name: '  Utilities  ').toJson(), {
      'name': 'Utilities',
    });
    expect(const UpdateCategoryRequest(name: ' Household ').toJson(), {
      'name': 'Household',
    });
    expect(
      () => const CreateCategoryRequest(name: ' ').toJson(),
      throwsArgumentError,
    );
  });

  test('uses the complete authenticated categories API contract', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer access-token');
      final path = request.url.path;

      if (request.method == 'GET' && path == '/v1/categories') {
        return _response([
          {
            '_id': 'category-id',
            'userId': 'user-id',
            'name': 'Utilities',
            'createdAt': '2026-09-01T08:30:00.000Z',
            'updatedAt': '2026-10-01T08:30:00.000Z',
            'itemCount': 4,
          },
        ]);
      }

      if (request.method == 'POST' && path == '/v1/categories') {
        expect(jsonDecode(request.body), {'name': 'Utilities'});
        return _response({
          '_id': 'category-id',
          'userId': 'user-id',
          'name': 'Utilities',
          'createdAt': '2026-09-01T08:30:00.000Z',
          'updatedAt': '2026-09-01T08:30:00.000Z',
        }, statusCode: 201);
      }

      if (request.method == 'PATCH' && path == '/v1/categories/category-id') {
        expect(jsonDecode(request.body), {'name': 'Household'});
        return _response({
          '_id': 'category-id',
          'userId': 'user-id',
          'name': 'Household',
          'createdAt': '2026-09-01T08:30:00.000Z',
          'updatedAt': '2026-10-07T09:00:00.000Z',
        });
      }

      if (request.method == 'DELETE' && path == '/v1/categories/category-id') {
        expect(request.body, isEmpty);
        return _response({'deleted': true});
      }

      return http.Response('Not found', 404);
    });
    final service = CategoryRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final categories = await service.categories();
    final created = await service.createCategory(
      const CreateCategoryRequest(name: 'Utilities'),
    );
    final updated = await service.updateCategory(
      'category-id',
      const UpdateCategoryRequest(name: 'Household'),
    );
    final deleted = await service.deleteCategory('category-id');

    expect(categories.single.itemCount, 4);
    expect(created.name, 'Utilities');
    expect(updated.name, 'Household');
    expect(deleted, isTrue);
  });
}

http.Response _response(Object data, {int statusCode = 200}) =>
    http.Response(jsonEncode({'success': true, 'data': data}), statusCode);
