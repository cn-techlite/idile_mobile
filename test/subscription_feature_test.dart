import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/create_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/get_subscriptions_request.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/update_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/data/model/subscriptions/subscription.dart';
import 'package:idile_mobile_app/features/subs/data/service/subscriptions/subscription_remote_service.dart';
import 'package:idile_mobile_app/features/subs/presentation/state/state_model/subscription_state.dart';

void main() {
  test('validates subscription requests and pagination filters', () {
    expect(
      const CreateSubscriptionRequest(
        title: ' Netflix ',
        spaceId: 'space-id',
        amount: 4400,
        currencyId: 'currency-id',
        billing: 'Monthly',
        renewal: '2026-11-15',
        warning: ' Free trial ends soon ',
      ).toJson(),
      {
        'title': 'Netflix',
        'spaceId': 'space-id',
        'amount': 4400,
        'currencyId': 'currency-id',
        'billing': 'monthly',
        'renewal': '2026-11-15',
        'warning': 'Free trial ends soon',
      },
    );
    expect(const UpdateSubscriptionRequest(status: 'Paused').toJson(), {
      'status': 'paused',
    });
    expect(
      const GetSubscriptionsRequest(
        status: 'active',
        spaceId: 'space-id',
        page: 2,
        limit: 50,
      ).toQueryParameters(),
      {
        'page': '2',
        'limit': '50',
        'status': 'active',
        'spaceId': 'space-id',
        'sort': 'renewal:asc',
      },
    );
    expect(
      () => const UpdateSubscriptionRequest().toJson(),
      throwsArgumentError,
    );
    expect(
      () =>
          const GetSubscriptionsRequest(status: 'expired').toQueryParameters(),
      throwsArgumentError,
    );
  });

  test('uses the complete authenticated subscriptions API contract', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer access-token');
      final path = request.url.path;

      if (request.method == 'GET' && path == '/v1/subscriptions') {
        expect(request.url.queryParameters, {
          'page': '1',
          'limit': '20',
          'status': 'active',
          'spaceId': 'space-id',
          'sort': 'renewal:asc',
        });
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [_subscriptionJson()],
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
          path == '/v1/subscriptions/subscription-id') {
        return _response(_subscriptionJson());
      }
      if (request.method == 'POST' && path == '/v1/subscriptions') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['billing'], 'monthly');
        expect(body.containsKey('status'), isFalse);
        return _response(_subscriptionJson(), statusCode: 201);
      }
      if (request.method == 'PATCH' &&
          path == '/v1/subscriptions/subscription-id') {
        expect(jsonDecode(request.body), {'status': 'paused'});
        return _response(_subscriptionJson(status: 'paused'));
      }
      if (request.method == 'DELETE' &&
          path == '/v1/subscriptions/subscription-id') {
        expect(request.body, isEmpty);
        return _response({'deleted': true});
      }
      return http.Response('Not found', 404);
    });
    final service = SubscriptionRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final page = await service.subscriptions(
      const GetSubscriptionsRequest(status: 'active', spaceId: 'space-id'),
    );
    final item = await service.subscription('subscription-id');
    final created = await service.createSubscription(
      const CreateSubscriptionRequest(
        title: 'Netflix',
        spaceId: 'space-id',
        amount: 4400,
        currencyId: 'currency-id',
        billing: 'monthly',
        renewal: '2026-11-15',
        warning: 'Free trial ends soon',
      ),
    );
    final updated = await service.updateSubscription(
      'subscription-id',
      const UpdateSubscriptionRequest(status: 'paused'),
    );
    final deleted = await service.deleteSubscription('subscription-id');

    expect(page.subscriptions.single.id, 'subscription-id');
    expect(page.pagination.total, 42);
    expect(page.pagination.hasNextPage, isTrue);
    expect(item.title, 'Netflix');
    expect(created.warning, 'Free trial ends soon');
    expect(updated.status, 'paused');
    expect(deleted, isTrue);
  });

  test('appends paginated subscriptions without duplicates', () {
    final first = SubscriptionPage(
      subscriptions: [
        SubscriptionItem.fromJson(_subscriptionJson()),
        SubscriptionItem.fromJson(_subscriptionJson(id: 'two')),
      ],
      pagination: const SubscriptionPagination(
        page: 1,
        limit: 2,
        total: 3,
        totalPages: 2,
        hasNextPage: true,
        hasPrevPage: false,
      ),
    );
    final second = SubscriptionPage(
      subscriptions: [
        SubscriptionItem.fromJson(_subscriptionJson(id: 'two')),
        SubscriptionItem.fromJson(_subscriptionJson(id: 'three')),
      ],
      pagination: const SubscriptionPagination(
        page: 2,
        limit: 2,
        total: 3,
        totalPages: 2,
        hasNextPage: false,
        hasPrevPage: true,
      ),
    );

    final state = SubscriptionState.fromPage(first).append(second);

    expect(state.subscriptions.map((subscription) => subscription.id), [
      'subscription-id',
      'two',
      'three',
    ]);
    expect(state.page, 2);
    expect(state.hasNextPage, isFalse);
  });
}

Map<String, dynamic> _subscriptionJson({
  String id = 'subscription-id',
  String status = 'active',
}) => {
  '_id': id,
  'userId': 'user-id',
  'title': 'Netflix',
  'spaceId': 'space-id',
  'amount': 4400,
  'currencyId': 'currency-id',
  'billing': 'monthly',
  'renewal': '2026-11-15',
  'status': status,
  'warning': 'Free trial ends soon',
  'createdAt': '2026-09-01T08:30:00.000Z',
  'updatedAt': '2026-10-01T08:30:00.000Z',
};

http.Response _response(Object data, {int statusCode = 200}) =>
    http.Response(jsonEncode({'success': true, 'data': data}), statusCode);
