import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/home/data/service/dashboard/dashboard_attention_remote_service.dart';

void main() {
  test('loads and maps every dashboard attention group', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/v1/dashboard/attention');
      expect(request.headers['authorization'], 'Bearer access-token');
      return http.Response(
        jsonEncode({'success': true, 'data': _attentionJson()}),
        200,
      );
    });
    final service = DashboardAttentionRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final attention = await service.attention();

    expect(attention.total, 5);
    expect(attention.bills.single.title, 'Ikeja Electric');
    expect(attention.bills.single.payments.single.amount, 25000);
    expect(attention.subscriptions.single.warning, 'Free trial ends soon');
    expect(attention.maintenance.single.intervalMonths, 3);
    expect(attention.assets.single.renewalDate, '2027-01-31T00:00:00.000Z');
    expect(attention.documents.single.householdItemId, 'household-item-id');
    expect(attention.documents.single.assetId, 'asset-id');
  });

  test('uses empty lists for missing dashboard groups', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final service = DashboardAttentionRemoteService(
      ApiClient(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({'success': true, 'data': <String, dynamic>{}}),
            200,
          ),
        ),
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final attention = await service.attention();

    expect(attention.total, 0);
    expect(attention.bills, isEmpty);
    expect(attention.subscriptions, isEmpty);
    expect(attention.maintenance, isEmpty);
    expect(attention.assets, isEmpty);
    expect(attention.documents, isEmpty);
  });
}

Map<String, dynamic> _attentionJson() => {
  'bills': [
    {
      '_id': 'bill-id',
      'userId': 'user-id',
      'title': 'Ikeja Electric',
      'category': 'Utilities',
      'spaceId': 'space-id',
      'amount': 25000,
      'currencyId': 'currency-id',
      'due': '2026-11-01',
      'status': 'upcoming',
      'recurrence': 'monthly',
      'payments': [
        {'paidOn': '2026-10-01', 'amount': 25000, 'currencyId': 'currency-id'},
      ],
      'createdAt': '2026-09-01T08:30:00.000Z',
      'updatedAt': '2026-10-01T08:30:00.000Z',
    },
  ],
  'subscriptions': [
    {
      '_id': 'subscription-id',
      'userId': 'user-id',
      'title': 'Netflix',
      'spaceId': 'space-id',
      'amount': 4400,
      'currencyId': 'currency-id',
      'billing': 'monthly',
      'renewal': '2026-11-15',
      'status': 'active',
      'warning': 'Free trial ends soon',
      'createdAt': '2026-09-01T08:30:00.000Z',
      'updatedAt': '2026-10-01T08:30:00.000Z',
    },
  ],
  'maintenance': [
    {
      '_id': 'maintenance-id',
      'userId': 'user-id',
      'title': 'Service air conditioner',
      'spaceId': 'space-id',
      'item': 'Living room AC',
      'lastDone': '2026-07-01',
      'nextDue': '2026-10-15',
      'status': 'soon',
      'intervalMonths': 3,
      'createdAt': '2026-09-01T08:30:00.000Z',
      'updatedAt': '2026-10-01T08:30:00.000Z',
    },
  ],
  'assets': [
    {
      '_id': 'asset-id',
      'userId': 'user-id',
      'title': 'MacBook Pro 14',
      'spaceId': 'space-id',
      'type': 'Hardware',
      'detail': 'Serial C02XK1YZ',
      'renewal': '2027-01-31',
      'renewalDate': '2027-01-31T00:00:00.000Z',
      'status': 'active',
      'secureUrl': 'https://example.com/asset.jpg',
      'createdAt': '2026-09-01T08:30:00.000Z',
      'updatedAt': '2026-10-01T08:30:00.000Z',
    },
  ],
  'documents': [
    {
      '_id': 'document-id',
      'userId': 'user-id',
      'title': 'Fridge warranty card',
      'spaceId': 'space-id',
      'type': 'Warranty',
      'expiry': '2027-03-12',
      'related': 'Samsung Refrigerator',
      'householdItemId': 'household-item-id',
      'assetId': 'asset-id',
      'status': 'active',
      'secureUrl': 'https://example.com/document.pdf',
      'createdAt': '2026-09-01T08:30:00.000Z',
      'updatedAt': '2026-10-01T08:30:00.000Z',
    },
  ],
};
