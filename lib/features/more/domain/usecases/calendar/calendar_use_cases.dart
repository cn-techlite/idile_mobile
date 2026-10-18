import 'package:idile_mobile_app/features/more/domain/entities/calendar/calendar_entry.dart';
import 'package:idile_mobile_app/features/more/domain/entities/calendar/calendar_feed_token.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/calendar/get_calendar_entries_request.dart';
import 'package:idile_mobile_app/features/more/domain/repositories/calendar/calendar_repository.dart';

final class CalendarUseCases {
  const CalendarUseCases(this._repository);

  final CalendarRepository _repository;

  Future<List<CalendarEntry>> entries(GetCalendarEntriesRequest request) =>
      _repository.entries(request);

  Future<CalendarFeedToken> feedToken() => _repository.feedToken();

  Future<CalendarFeedToken> rotateFeedToken() => _repository.rotateFeedToken();

  Future<CalendarFeedToken> revokeFeedToken() => _repository.revokeFeedToken();
}
