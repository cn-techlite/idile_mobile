import 'package:idile_mobile_app/features/more/domain/entities/calendar/calendar_entry.dart';

class CalendarState {
  const CalendarState({
    required this.month,
    this.entries = const [],
    this.feedUrl,
    this.feedError,
    this.isRefreshing = false,
    this.isRotatingFeed = false,
    this.isRevokingFeed = false,
  });

  final DateTime month;
  final List<CalendarEntry> entries;
  final String? feedUrl;
  final String? feedError;
  final bool isRefreshing;
  final bool isRotatingFeed;
  final bool isRevokingFeed;

  bool get isChangingFeed => isRotatingFeed || isRevokingFeed;

  CalendarState copyWith({
    DateTime? month,
    List<CalendarEntry>? entries,
    Object? feedUrl = _unset,
    Object? feedError = _unset,
    bool? isRefreshing,
    bool? isRotatingFeed,
    bool? isRevokingFeed,
  }) => CalendarState(
    month: month ?? this.month,
    entries: entries ?? this.entries,
    feedUrl: identical(feedUrl, _unset) ? this.feedUrl : feedUrl as String?,
    feedError: identical(feedError, _unset)
        ? this.feedError
        : feedError as String?,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isRotatingFeed: isRotatingFeed ?? this.isRotatingFeed,
    isRevokingFeed: isRevokingFeed ?? this.isRevokingFeed,
  );
}

const _unset = Object();
