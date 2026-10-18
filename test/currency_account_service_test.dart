import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/currencies/create_currency_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/currencies/update_currency_request.dart';
import 'package:idile_mobile_app/features/account/data/service/currencies/currency_remote_service.dart';

void main() {
  test('validates create and partial currency requests', () {
    expect(
      const CreateCurrencyRequest(
        name: ' NGN ',
        country: ' Nigeria ',
        flagUrl: ' https://flagcdn.com/ng.svg ',
        symbol: ' ₦ ',
      ).toJson(),
      {
        'name': 'NGN',
        'country': 'Nigeria',
        'flagUrl': 'https://flagcdn.com/ng.svg',
        'symbol': '₦',
      },
    );
    expect(const UpdateCurrencyRequest(symbol: r'N$').toJson(), {
      'symbol': r'N$',
    });
    expect(() => const UpdateCurrencyRequest().toJson(), throwsArgumentError);
    expect(
      () => const CreateCurrencyRequest(
        name: 'NGN',
        country: 'Nigeria',
        flagUrl: 'not-a-url',
        symbol: '₦',
      ).toJson(),
      throwsArgumentError,
    );
  });

  test('uses the complete authenticated currencies API contract', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer access-token');
      final path = request.url.path;

      if (request.method == 'GET' && path == '/v1/currencies') {
        return _response([
          {
            '_id': 'currency-id',
            'userId': 'user-id',
            'name': 'NGN',
            'country': 'Nigeria',
            'flagUrl': 'https://flagcdn.com/ng.svg',
            'symbol': '₦',
            'createdAt': '2026-09-01T08:30:00.000Z',
            'updatedAt': '2026-10-01T08:30:00.000Z',
            'itemCount': 3,
          },
        ]);
      }

      if (request.method == 'POST' && path == '/v1/currencies') {
        expect(jsonDecode(request.body), {
          'name': 'NGN',
          'country': 'Nigeria',
          'flagUrl': 'https://flagcdn.com/ng.svg',
          'symbol': '₦',
        });
        return _response({
          '_id': 'currency-id',
          'userId': 'user-id',
          'name': 'NGN',
          'country': 'Nigeria',
          'flagUrl': 'https://flagcdn.com/ng.svg',
          'symbol': '₦',
          'createdAt': '2026-09-01T08:30:00.000Z',
          'updatedAt': '2026-09-01T08:30:00.000Z',
        }, statusCode: 201);
      }

      if (request.method == 'PATCH' && path == '/v1/currencies/currency-id') {
        expect(jsonDecode(request.body), {'symbol': r'N$'});
        return _response({
          '_id': 'currency-id',
          'userId': 'user-id',
          'name': 'NGN',
          'country': 'Nigeria',
          'flagUrl': 'https://flagcdn.com/ng.svg',
          'symbol': r'N$',
          'createdAt': '2026-09-01T08:30:00.000Z',
          'updatedAt': '2026-10-07T09:00:00.000Z',
        });
      }

      if (request.method == 'DELETE' && path == '/v1/currencies/currency-id') {
        expect(request.body, isEmpty);
        return _response({'deleted': true});
      }

      return http.Response('Not found', 404);
    });
    final service = CurrencyRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final currencies = await service.currencies();
    final created = await service.createCurrency(
      const CreateCurrencyRequest(
        name: 'NGN',
        country: 'Nigeria',
        flagUrl: 'https://flagcdn.com/ng.svg',
        symbol: '₦',
      ),
    );
    final updated = await service.updateCurrency(
      'currency-id',
      const UpdateCurrencyRequest(symbol: r'N$'),
    );
    final deleted = await service.deleteCurrency('currency-id');

    expect(currencies.single.itemCount, 3);
    expect(created.name, 'NGN');
    expect(updated.symbol, r'N$');
    expect(deleted, isTrue);
  });
}

http.Response _response(Object data, {int statusCode = 200}) =>
    http.Response.bytes(
      utf8.encode(jsonEncode({'success': true, 'data': data})),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
