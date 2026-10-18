import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/notifications/get_notifications_request.dart';
import 'package:idile_mobile_app/features/account/domain/entities/notifications/in_app_notification.dart';
import 'package:idile_mobile_app/features/account/data/service/notifications/notification_remote_service.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/notification_state.dart';

void main() {
  test('builds the supported notification pagination query', () {
    const request = GetNotificationsRequest(
      page: 2,
      limit: 50,
      read: false,
      sort: 'createdAt:desc',
    );

    expect(request.toQueryParameters(), {
      'page': '2',
      'limit': '50',
      'read': 'false',
      'sort': 'createdAt:desc',
    });
    expect(
      () => const GetNotificationsRequest(limit: 101).toQueryParameters(),
      throwsArgumentError,
    );
    expect(
      () =>
          const GetNotificationsRequest(sort: 'createdAt descending')
              .toQueryParameters(),
      throwsArgumentError,
    );
  });

  test(
    'loads a notification page without discarding pagination metadata',
    () async {
      FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/v1/notifications');
        expect(request.url.queryParameters, {
          'page': '2',
          'limit': '20',
          'read': 'false',
          'sort': 'createdAt:desc',
        });
        expect(request.headers['authorization'], 'Bearer access-token');

        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                '_id': 'notification-21',
                'userId': 'user-id',
                'type': 'bill-reminder',
                'title': 'Electricity is due tomorrow',
                'message': 'Your bill is coming up.',
                'entityType': 'bill',
                'entityId': 'bill-id',
                'read': false,
                'createdAt': '2026-10-31T07:00:00.000Z',
                'updatedAt': '2026-10-31T07:00:00.000Z',
              },
            ],
            'meta': {
              'pagination': {
                'page': 2,
                'limit': 20,
                'total': 42,
                'totalPages': 3,
                'hasNextPage': true,
                'hasPrevPage': true,
              },
            },
          }),
          200,
        );
      });
      final service = NotificationRemoteService(
        ApiClient(
          client: client,
          store: SessionStore(storage: const FlutterSecureStorage()),
        ),
      );

      final page = await service.notifications(
        const GetNotificationsRequest(
          page: 2,
          read: false,
          sort: 'createdAt:desc',
        ),
      );

      expect(page.notifications, hasLength(1));
      expect(page.notifications.single.id, 'notification-21');
      expect(page.notifications.single.read, isFalse);
      expect(page.pagination.page, 2);
      expect(page.pagination.total, 42);
      expect(page.pagination.totalPages, 3);
      expect(page.pagination.hasNextPage, isTrue);
      expect(page.pagination.hasPrevPage, isTrue);
    },
  );

  test('marks a notification read with its authenticated id route', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.method, 'PATCH');
      expect(
        request.url.toString(),
        'https://api.idile.com.ng/v1/notifications/notification-21/read',
      );
      expect(request.headers['authorization'], 'Bearer access-token');
      expect(request.body, isEmpty);

      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            '_id': 'notification-21',
            'userId': 'user-id',
            'type': 'bill-reminder',
            'title': 'Electricity is due tomorrow',
            'message': 'Your bill is coming up.',
            'read': true,
            'createdAt': '2026-10-31T07:00:00.000Z',
            'updatedAt': '2026-10-31T08:00:00.000Z',
          },
        }),
        200,
      );
    });
    final service = NotificationRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final notification = await service.markRead('notification-21');

    expect(notification.id, 'notification-21');
    expect(notification.read, isTrue);
  });

  test('marks all notifications read with an authenticated PATCH', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.method, 'PATCH');
      expect(
        request.url.toString(),
        'https://api.idile.com.ng/v1/notifications/read-all',
      );
      expect(request.headers['authorization'], 'Bearer access-token');
      expect(request.body, isEmpty);

      return http.Response(
        jsonEncode({
          'success': true,
          'data': {'success': true},
        }),
        200,
      );
    });
    final service = NotificationRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    await service.markAllRead();
  });

  test('appends the next page and keeps each notification once', () {
    final firstPage = NotificationPage(
      notifications: [_notification('one'), _notification('two')],
      pagination: const NotificationPagination(
        page: 1,
        limit: 2,
        total: 3,
        totalPages: 2,
        hasNextPage: true,
        hasPrevPage: false,
      ),
    );
    final secondPage = NotificationPage(
      notifications: [_notification('two'), _notification('three')],
      pagination: const NotificationPagination(
        page: 2,
        limit: 2,
        total: 3,
        totalPages: 2,
        hasNextPage: false,
        hasPrevPage: true,
      ),
    );

    final state = NotificationState.fromPage(
      firstPage,
      readFilter: false,
    ).append(secondPage);

    expect(state.notifications.map((item) => item.id), ['one', 'two', 'three']);
    expect(state.page, 2);
    expect(state.hasNextPage, isFalse);
    expect(state.hasPrevPage, isTrue);
    expect(state.readFilter, isFalse);
    expect(state.isLoadingMore, isFalse);
  });

  test('tracks and replaces a notification being marked read', () {
    final page = NotificationPage(
      notifications: [_notification('one'), _notification('two')],
      pagination: const NotificationPagination(
        page: 1,
        limit: 20,
        total: 2,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      ),
    );

    final loading = NotificationState.fromPage(page)
        .setMarkingRead('one', true);
    final completed = loading.replaceNotification(
      _notification('one').copyWith(read: true),
    );

    expect(loading.isMarkingRead('one'), isTrue);
    expect(completed.isMarkingRead('one'), isFalse);
    expect(completed.notifications.first.read, isTrue);
    expect(completed.notifications.last.id, 'two');
  });

  test('marks every loaded notification read locally', () {
    final page = NotificationPage(
      notifications: [_notification('one'), _notification('two')],
      pagination: const NotificationPagination(
        page: 1,
        limit: 20,
        total: 2,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      ),
    );

    final completed = NotificationState.fromPage(page)
        .copyWith(isMarkingAllRead: true)
        .markAllReadLocally();

    expect(completed.notifications.every((item) => item.read), isTrue);
    expect(completed.isMarkingAllRead, isFalse);
  });
}

InAppNotification _notification(String id) => InAppNotification(
  id: id,
  userId: 'user-id',
  type: 'bill-reminder',
  title: 'Title $id',
  message: 'Message $id',
  read: false,
  createdAt: DateTime.utc(2026, 10, 7),
  updatedAt: DateTime.utc(2026, 10, 7),
);
