import 'package:idile_mobile_app/features/more/data/dto/calendar/get_calendar_entries_request.dart';
import 'package:idile_mobile_app/features/more/data/model/calendar/calendar_entry.dart';
import 'package:idile_mobile_app/features/more/data/model/calendar/calendar_feed_token.dart';
import 'package:idile_mobile_app/features/more/data/service/calendar/calendar_remote_service.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/calendar/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  const CalendarRepositoryImpl(this._remoteService);

  final CalendarRemoteService _remoteService;

  @override
  Future<List<CalendarEntry>> entries(GetCalendarEntriesRequest request) =>
      _remoteService.entries(request);

  @override
  Future<CalendarFeedToken> feedToken() => _remoteService.feedToken();

  @override
  Future<CalendarFeedToken> rotateFeedToken() =>
      _remoteService.rotateFeedToken();

  @override
  Future<CalendarFeedToken> revokeFeedToken() =>
      _remoteService.revokeFeedToken();
}
