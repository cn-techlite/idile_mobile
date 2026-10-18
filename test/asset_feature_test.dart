import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/assets/create_asset_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/assets/get_assets_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/assets/update_asset_request.dart';
import 'package:idile_mobile_app/features/more/domain/entities/assets/asset_item.dart';
import 'package:idile_mobile_app/features/more/data/service/assets/asset_remote_service.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/asset_state.dart';

void main() {
  test('validates asset requests and pagination filters', () {
    expect(
      const CreateAssetRequest(
        title: ' MacBook Pro 14 ',
        spaceId: 'space-id',
        type: 'hardware',
        detail: ' Serial C02XK1YZ ',
        renewal: '2027-01-31',
        renewalDate: '2027-01-31T00:00:00.000Z',
      ).toFields(),
      {
        'title': 'MacBook Pro 14',
        'spaceId': 'space-id',
        'type': 'Hardware',
        'detail': 'Serial C02XK1YZ',
        'renewal': '2027-01-31',
        'renewalDate': '2027-01-31T00:00:00.000Z',
      },
    );
    expect(const UpdateAssetRequest(status: 'Expiring').toJson(), {
      'status': 'expiring',
    });
    expect(
      const GetAssetsRequest(
        page: 2,
        limit: 50,
        status: 'active',
        type: 'license',
        spaceId: 'space-id',
      ).toQueryParameters(),
      {
        'page': '2',
        'limit': '50',
        'sort': 'createdAt:desc',
        'status': 'active',
        'type': 'License',
        'spaceId': 'space-id',
      },
    );
    expect(() => const UpdateAssetRequest().toJson(), throwsArgumentError);
    expect(
      () => const GetAssetsRequest(status: 'expired').toQueryParameters(),
      throwsArgumentError,
    );
    expect(
      () => const CreateAssetRequest(
        title: 'Asset',
        spaceId: 'space-id',
        type: 'Hardware',
        detail: 'Detail',
        renewal: '2027-01-31',
        fileBytes: [1],
      ).toFields(),
      throwsArgumentError,
    );
  });

  test('uses the complete authenticated assets API contract', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer access-token');
      final path = request.url.path;

      if (request.method == 'GET' && path == '/v1/assets') {
        expect(request.url.queryParameters, {
          'page': '1',
          'limit': '20',
          'sort': 'createdAt:desc',
          'status': 'expiring',
          'type': 'License',
          'spaceId': 'space-id',
        });
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [_assetJson()],
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
      if (request.method == 'GET' && path == '/v1/assets/asset-id') {
        return _response(_assetJson());
      }
      if (request.method == 'POST' && path == '/v1/assets') {
        expect(
          request.headers['content-type'],
          startsWith('multipart/form-data; boundary='),
        );
        expect(request.body, contains('name="title"'));
        expect(request.body, contains('MacBook Pro 14'));
        expect(request.body, contains('name="file"'));
        expect(request.body, contains('filename="receipt.txt"'));
        return _response(_assetJson(), statusCode: 201);
      }
      if (request.method == 'PATCH' && path == '/v1/assets/asset-id') {
        expect(jsonDecode(request.body), {'status': 'expiring'});
        return _response(_assetJson(status: 'expiring'));
      }
      if (request.method == 'DELETE' && path == '/v1/assets/asset-id') {
        expect(request.body, isEmpty);
        return _response({'deleted': true});
      }
      return http.Response('Not found', 404);
    });
    final service = AssetRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final page = await service.assets(
      const GetAssetsRequest(
        status: 'expiring',
        type: 'License',
        spaceId: 'space-id',
      ),
    );
    final asset = await service.asset('asset-id');
    final created = await service.createAsset(
      const CreateAssetRequest(
        title: 'MacBook Pro 14',
        spaceId: 'space-id',
        type: 'Hardware',
        detail: 'Serial C02XK1YZ',
        renewal: '2027-01-31',
        fileBytes: [104, 101, 108, 108, 111],
        fileName: 'receipt.txt',
      ),
    );
    final updated = await service.updateAsset(
      'asset-id',
      const UpdateAssetRequest(status: 'expiring'),
    );
    final deleted = await service.deleteAsset('asset-id');

    expect(page.assets.single.id, 'asset-id');
    expect(page.pagination.total, 42);
    expect(page.pagination.hasNextPage, isTrue);
    expect(asset.title, 'MacBook Pro 14');
    expect(created.secureUrl, contains('cloudinary.com'));
    expect(updated.status, 'expiring');
    expect(deleted, isTrue);
  });

  test('appends paginated assets without duplicates', () {
    final first = AssetPage(
      assets: [
        AssetItem.fromJson(_assetJson()),
        AssetItem.fromJson(_assetJson(id: 'two')),
      ],
      pagination: const AssetPagination(
        page: 1,
        limit: 2,
        total: 3,
        totalPages: 2,
        hasNextPage: true,
        hasPrevPage: false,
      ),
    );
    final second = AssetPage(
      assets: [
        AssetItem.fromJson(_assetJson(id: 'two')),
        AssetItem.fromJson(_assetJson(id: 'three')),
      ],
      pagination: const AssetPagination(
        page: 2,
        limit: 2,
        total: 3,
        totalPages: 2,
        hasNextPage: false,
        hasPrevPage: true,
      ),
    );

    final state = AssetState.fromPage(first).append(second);

    expect(state.assets.map((asset) => asset.id), ['asset-id', 'two', 'three']);
    expect(state.page, 2);
    expect(state.hasNextPage, isFalse);
  });
}

Map<String, dynamic> _assetJson({
  String id = 'asset-id',
  String status = 'active',
}) => {
  '_id': id,
  'userId': 'user-id',
  'title': 'MacBook Pro 14',
  'spaceId': 'space-id',
  'type': 'Hardware',
  'detail': 'Serial C02XK1YZ',
  'renewal': '2027-01-31',
  'renewalDate': '2027-01-31T00:00:00.000Z',
  'status': status,
  'cloudinaryPublicId': 'idile/assets/abc123',
  'secureUrl':
      'https://res.cloudinary.com/demo/image/upload/v1/idile/assets/abc123.jpg',
  'resourceType': 'image',
  'createdAt': '2026-09-01T08:30:00.000Z',
  'updatedAt': '2026-10-01T08:30:00.000Z',
};

http.Response _response(Object data, {int statusCode = 200}) =>
    http.Response(jsonEncode({'success': true, 'data': data}), statusCode);
