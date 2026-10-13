import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/more/data/dto/calendar/get_calendar_entries_request.dart';
import 'package:idile_mobile_app/features/more/data/model/calendar/calendar_entry.dart';
import 'package:idile_mobile_app/features/more/data/model/calendar/calendar_feed_token.dart';

class CalendarRemoteService {
  const CalendarRemoteService(this._api);

  final ApiClient _api;

  Future<List<CalendarEntry>> entries(GetCalendarEntriesRequest request) {
    final uri = Uri(
      path: Endpoints.calendarUrl,
      queryParameters: request.toQueryParameters(),
    );
    return _api.get(
      uri.toString(),
      (value) => (value as List? ?? const [])
          .map(
            (item) =>
                CalendarEntry.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false),
    );
  }

  Future<CalendarFeedToken> feedToken() => _api.get(
    Endpoints.calendarFeedTokenUrl,
    (value) =>
        CalendarFeedToken.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<CalendarFeedToken> rotateFeedToken() => _api.post(
    Endpoints.calendarFeedTokenRotateUrl,
    (value) =>
        CalendarFeedToken.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<CalendarFeedToken> revokeFeedToken() => _api.delete(
    Endpoints.calendarFeedTokenUrl,
    (value) =>
        CalendarFeedToken.fromJson(Map<String, dynamic>.from(value as Map)),
  );
}
