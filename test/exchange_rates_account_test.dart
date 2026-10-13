import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/account/data/model/exchange_rates/exchange_rates.dart';
import 'package:idile_mobile_app/features/account/data/service/account/account_remote_service.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/account_state.dart';

void main() {
  test('loads and maps authenticated cached exchange rates', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/v1/exchange-rates');
      expect(request.headers['authorization'], 'Bearer access-token');
      return http.Response(
        jsonEncode({'success': true, 'data': _exchangeRatesJson()}),
        200,
      );
    });
    final service = AccountRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final exchangeRates = await service.exchangeRates();

    expect(exchangeRates, isNotNull);
    expect(exchangeRates!.id, 'exchange-rate-id');
    expect(exchangeRates.baseCode, 'USD');
    expect(exchangeRates.rateFor('ngn'), 1520.5);
    expect(exchangeRates.rateFor('EUR'), 0.92);
    expect(exchangeRates.fetchedAt, DateTime.parse('2026-10-07T00:00:00.000Z'));
    expect(
      exchangeRates.nextUpdateAt,
      DateTime.parse('2026-10-08T00:00:00.000Z'),
    );
  });

  test('accepts a successful null exchange-rate cache', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final service = AccountRemoteService(
      ApiClient(
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode({'success': true, 'data': null}), 200),
        ),
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    expect(await service.exchangeRates(), isNull);
  });

  test('main account state owns exchange-rate loading and errors', () {
    final rates = ExchangeRates.fromJson(_exchangeRatesJson());
    const initial = AccountState();
    final loading = initial.copyWith(
      exchangeRates: rates,
      isLoadingExchangeRates: true,
      exchangeRatesError: null,
    );

    expect(loading.exchangeRates, same(rates));
    expect(loading.isLoadingExchangeRates, isTrue);
    expect(loading.exchangeRatesError, isNull);
    expect(loading.copyWith().exchangeRates, same(rates));
    expect(loading.copyWith(exchangeRates: null).exchangeRates, isNull);
  });
}

Map<String, dynamic> _exchangeRatesJson() => {
  '_id': 'exchange-rate-id',
  'baseCode': 'USD',
  'rates': {'USD': 1, 'NGN': 1520.5, 'EUR': 0.92},
  'fetchedAt': '2026-10-07T00:00:00.000Z',
  'nextUpdateAt': '2026-10-08T00:00:00.000Z',
  'createdAt': '2026-09-01T08:30:00.000Z',
  'updatedAt': '2026-10-01T08:30:00.000Z',
};
