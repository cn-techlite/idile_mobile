import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/calendar/get_calendar_entries_request.dart';
import 'package:idile_mobile_app/features/more/data/service/calendar/calendar_remote_service.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/calendar_state.dart';

void main() {
  test('calendar range request formats and validates inclusive dates', () {
    expect(
      GetCalendarEntriesRequest(
        from: DateTime(2026, 10, 1, 18),
        to: DateTime(2026, 10, 31, 6),
      ).toQueryParameters(),
      {'from': '2026-10-01', 'to': '2026-10-31'},
    );
    expect(
      () => GetCalendarEntriesRequest(
        from: DateTime(2026, 11, 1),
        to: DateTime(2026, 10, 31),
      ).toQueryParameters(),
      throwsArgumentError,
    );
  });

  test('uses the authenticated calendar and feed-token API contract', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer access-token');
      final path = request.url.path;

      if (request.method == 'GET' && path == '/v1/calendar') {
        expect(request.url.queryParameters, {
          'from': '2026-10-01',
          'to': '2026-10-31',
        });
        return _response([
          {
            'date': '2026-10-15',
            'entityType': 'bill',
            'entityId': 'bill-id',
            'title': 'Ikeja Electric',
            'amount': 25000,
            'currencyId': 'currency-id',
            'status': 'upcoming',
          },
          {
            'date': '2026-10-20',
            'entityType': 'maintenance',
            'entityId': 'maintenance-id',
            'title': 'Service air conditioner',
            'amount': null,
            'currencyId': null,
            'status': 'soon',
          },
        ]);
      }
      if (request.method == 'GET' && path == '/v1/calendar/feed-token') {
        return _response({'url': _feedUrl});
      }
      if (request.method == 'POST' &&
          path == '/v1/calendar/feed-token/rotate') {
        expect(request.body, isEmpty);
        return _response({'url': '$_feedUrl-new'});
      }
      if (request.method == 'DELETE' && path == '/v1/calendar/feed-token') {
        expect(request.body, isEmpty);
        return _response({'url': null});
      }
      return http.Response('Not found', 404);
    });
    final service = CalendarRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final entries = await service.entries(
      GetCalendarEntriesRequest(
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 31),
      ),
    );
    final currentFeed = await service.feedToken();
    final rotatedFeed = await service.rotateFeedToken();
    final revokedFeed = await service.revokeFeedToken();

    expect(entries, hasLength(2));
    expect(entries.first.amount, 25000.0);
    expect(entries.last.amount, isNull);
    expect(entries.last.currencyId, isNull);
    expect(currentFeed.url, _feedUrl);
    expect(rotatedFeed.url, '$_feedUrl-new');
    expect(revokedFeed.url, isNull);
  });

  test('calendar state can explicitly clear a private feed URL', () {
    final state = CalendarState(month: DateTime(2026, 10), feedUrl: _feedUrl);

    expect(state.copyWith(feedUrl: null).feedUrl, isNull);
  });
}

const _feedUrl = 'https://api.idile.com.ng/v1/calendar/feed/secret.ics';

http.Response _response(Object data) =>
    http.Response(jsonEncode({'success': true, 'data': data}), 200);
