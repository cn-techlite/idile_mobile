import 'package:idile_mobile_app/features/more/domain/parameters/calendar/get_calendar_entries_request.dart';
import 'package:idile_mobile_app/features/more/domain/entities/calendar/calendar_entry.dart';
import 'package:idile_mobile_app/features/more/domain/entities/calendar/calendar_feed_token.dart';

abstract interface class CalendarRepository {
  Future<List<CalendarEntry>> entries(GetCalendarEntriesRequest request);
  Future<CalendarFeedToken> feedToken();
  Future<CalendarFeedToken> rotateFeedToken();
  Future<CalendarFeedToken> revokeFeedToken();
}
