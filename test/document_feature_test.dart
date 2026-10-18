import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/documents/create_document_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/documents/get_documents_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/documents/update_document_request.dart';
import 'package:idile_mobile_app/features/more/domain/entities/documents/document_item.dart';
import 'package:idile_mobile_app/features/more/data/service/documents/document_remote_service.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/document_state.dart';

void main() {
  test('validates document requests, empty fields and filters', () {
    expect(
      const CreateDocumentRequest(
        title: ' Fridge warranty card ',
        spaceId: 'space-id',
        type: 'warranty',
        expiry: '2027-03-12',
        related: ' Samsung Refrigerator ',
        householdItemId: ' household-item-id ',
        assetId: ' asset-id ',
      ).toFields(),
      {
        'title': 'Fridge warranty card',
        'spaceId': 'space-id',
        'type': 'Warranty',
        'expiry': '2027-03-12',
        'related': 'Samsung Refrigerator',
        'householdItemId': 'household-item-id',
        'assetId': 'asset-id',
      },
    );
    expect(
      const CreateDocumentRequest(
        title: 'Receipt',
        spaceId: 'space-id',
        type: 'Receipt',
      ).toFields(),
      containsPair('expiry', ''),
    );
    expect(
      const UpdateDocumentRequest(
        expiry: '',
        householdItemId: '',
        assetId: '',
      ).toJson(),
      {'expiry': '', 'householdItemId': '', 'assetId': ''},
    );
    expect(
      const GetDocumentsRequest(
        page: 2,
        limit: 50,
        status: 'active',
        type: 'warranty',
        spaceId: 'space-id',
        householdItemId: 'household-item-id',
        assetId: 'asset-id',
      ).toQueryParameters(),
      {
        'page': '2',
        'limit': '50',
        'sort': 'createdAt:desc',
        'status': 'active',
        'type': 'Warranty',
        'spaceId': 'space-id',
        'householdItemId': 'household-item-id',
        'assetId': 'asset-id',
      },
    );
    expect(() => const UpdateDocumentRequest().toJson(), throwsArgumentError);
    expect(
      () => const GetDocumentsRequest(type: 'Passport').toQueryParameters(),
      throwsArgumentError,
    );
    expect(
      () => const CreateDocumentRequest(
        title: 'Receipt',
        spaceId: 'space-id',
        type: 'Receipt',
        fileBytes: [1],
      ).toFields(),
      throwsArgumentError,
    );
  });

  test('uses the complete authenticated documents API contract', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer access-token');
      final path = request.url.path;

      if (request.method == 'GET' && path == '/v1/documents') {
        expect(request.url.queryParameters, {
          'page': '1',
          'limit': '20',
          'sort': 'createdAt:desc',
          'status': 'expiring',
          'type': 'Warranty',
          'spaceId': 'space-id',
          'householdItemId': 'household-item-id',
          'assetId': 'asset-id',
        });
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [_documentJson()],
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
      if (request.method == 'GET' && path == '/v1/documents/document-id') {
        return _response(_documentJson());
      }
      if (request.method == 'POST' && path == '/v1/documents') {
        expect(
          request.headers['content-type'],
          startsWith('multipart/form-data; boundary='),
        );
        expect(request.body, contains('name="title"'));
        expect(request.body, contains('Fridge warranty card'));
        expect(request.body, contains('name="householdItemId"'));
        expect(request.body, contains('name="assetId"'));
        expect(request.body, contains('filename="warranty.pdf"'));
        return _response(_documentJson(), statusCode: 201);
      }
      if (request.method == 'PATCH' && path == '/v1/documents/document-id') {
        expect(jsonDecode(request.body), {
          'expiry': '',
          'householdItemId': '',
          'assetId': '',
        });
        return _response(
          _documentJson(expiry: '', householdItemId: '', assetId: ''),
        );
      }
      if (request.method == 'DELETE' && path == '/v1/documents/document-id') {
        expect(request.body, isEmpty);
        return _response({'deleted': true});
      }
      return http.Response('Not found', 404);
    });
    final service = DocumentRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final page = await service.documents(
      const GetDocumentsRequest(
        status: 'expiring',
        type: 'Warranty',
        spaceId: 'space-id',
        householdItemId: 'household-item-id',
        assetId: 'asset-id',
      ),
    );
    final document = await service.document('document-id');
    final created = await service.createDocument(
      const CreateDocumentRequest(
        title: 'Fridge warranty card',
        spaceId: 'space-id',
        type: 'Warranty',
        expiry: '2027-03-12',
        related: 'Samsung Refrigerator',
        householdItemId: 'household-item-id',
        assetId: 'asset-id',
        fileBytes: [37, 80, 68, 70],
        fileName: 'warranty.pdf',
      ),
    );
    final updated = await service.updateDocument(
      'document-id',
      const UpdateDocumentRequest(expiry: '', householdItemId: '', assetId: ''),
    );
    final deleted = await service.deleteDocument('document-id');

    expect(page.documents.single.id, 'document-id');
    expect(page.pagination.total, 42);
    expect(page.pagination.hasNextPage, isTrue);
    expect(document.title, 'Fridge warranty card');
    expect(created.secureUrl, contains('cloudinary.com'));
    expect(updated.expiry, isEmpty);
    expect(updated.householdItemId, isEmpty);
    expect(updated.assetId, isEmpty);
    expect(deleted, isTrue);
  });

  test('appends paginated documents without duplicates', () {
    final first = DocumentPage(
      documents: [
        DocumentItem.fromJson(_documentJson()),
        DocumentItem.fromJson(_documentJson(id: 'two')),
      ],
      pagination: const DocumentPagination(
        page: 1,
        limit: 2,
        total: 3,
        totalPages: 2,
        hasNextPage: true,
        hasPrevPage: false,
      ),
    );
    final second = DocumentPage(
      documents: [
        DocumentItem.fromJson(_documentJson(id: 'two')),
        DocumentItem.fromJson(_documentJson(id: 'three')),
      ],
      pagination: const DocumentPagination(
        page: 2,
        limit: 2,
        total: 3,
        totalPages: 2,
        hasNextPage: false,
        hasPrevPage: true,
      ),
    );

    final state = DocumentState.fromPage(first).append(second);

    expect(state.documents.map((document) => document.id), [
      'document-id',
      'two',
      'three',
    ]);
    expect(state.page, 2);
    expect(state.hasNextPage, isFalse);
  });
}

Map<String, dynamic> _documentJson({
  String id = 'document-id',
  String expiry = '2027-03-12',
  String householdItemId = 'household-item-id',
  String assetId = 'asset-id',
}) => {
  '_id': id,
  'userId': 'user-id',
  'title': 'Fridge warranty card',
  'spaceId': 'space-id',
  'type': 'Warranty',
  'expiry': expiry,
  'related': 'Samsung Refrigerator',
  'householdItemId': householdItemId,
  'assetId': assetId,
  'status': 'active',
  'cloudinaryPublicId': 'idile/documents/abc123',
  'secureUrl': 'https://res.cloudinary.com/demo/image/upload/v1/idile/documents/abc123.pdf',
  'resourceType': 'image',
  'createdAt': '2026-09-01T08:30:00.000Z',
  'updatedAt': '2026-10-01T08:30:00.000Z',
};

http.Response _response(Object data, {int statusCode = 200}) =>
    http.Response(jsonEncode({'success': true, 'data': data}), statusCode);
