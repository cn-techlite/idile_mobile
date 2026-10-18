import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/app/di/repository_providers.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/calendar/get_calendar_entries_request.dart';
import 'package:idile_mobile_app/features/more/domain/entities/calendar/calendar_entry.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/calendar/calendar_use_cases.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/calendar_state.dart';

class CalendarController extends AsyncNotifier<CalendarState> {
  CalendarUseCases get _useCases => ref.read(calendarUseCasesProvider);

  @override
  FutureOr<CalendarState> build() async {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final entries = await _entriesFor(month);
    try {
      final feed = await _useCases.feedToken();
      return CalendarState(month: month, entries: entries, feedUrl: feed.url);
    } catch (error) {
      return CalendarState(
        month: month,
        entries: entries,
        feedError: error.toString(),
      );
    }
  }

  Future<void> nextMonth() => _changeMonth(1);

  Future<void> previousMonth() => _changeMonth(-1);

  Future<void> goToToday() {
    final now = DateTime.now();
    return goToMonth(now);
  }

  Future<void> goToMonth(DateTime value) =>
      _loadMonth(DateTime(value.year, value.month));

  Future<void> _changeMonth(int offset) async {
    final current = state.value;
    if (current == null) return;
    final month = DateTime(current.month.year, current.month.month + offset);
    await _loadMonth(month);
  }

  Future<void> _loadMonth(DateTime month) async {
    final current = state.value;
    if (current == null) return;
    if (current.month.year == month.year &&
        current.month.month == month.month) {
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => current.copyWith(
        month: month,
        entries: await _entriesFor(month),
        isRefreshing: false,
      ),
    );
  }

  Future<void> refreshCalendar() async {
    final current = state.value;
    if (current == null) {
      ref.invalidateSelf();
      return;
    }
    state = AsyncData(current.copyWith(isRefreshing: true));
    try {
      final entries = await _entriesFor(current.month);
      String? feedUrl = current.feedUrl;
      String? feedError;
      try {
        feedUrl = (await _useCases.feedToken()).url;
      } catch (error) {
        feedError = error.toString();
      }
      state = AsyncData(
        current.copyWith(
          entries: entries,
          feedUrl: feedUrl,
          feedError: feedError,
          isRefreshing: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<String?> rotateFeedToken() async {
    final current = state.value;
    if (current == null || current.isChangingFeed) return null;
    state = AsyncData(current.copyWith(isRotatingFeed: true, feedError: null));
    try {
      final feed = await _useCases.rotateFeedToken();
      state = AsyncData(
        (state.value ?? current).copyWith(
          feedUrl: feed.url,
          isRotatingFeed: false,
        ),
      );
      return feed.url;
    } catch (error) {
      state = AsyncData(
        (state.value ?? current).copyWith(
          feedError: error.toString(),
          isRotatingFeed: false,
        ),
      );
      rethrow;
    }
  }

  Future<void> revokeFeedToken() async {
    final current = state.value;
    if (current == null || current.isChangingFeed) return;
    state = AsyncData(current.copyWith(isRevokingFeed: true, feedError: null));
    try {
      await _useCases.revokeFeedToken();
      state = AsyncData(
        (state.value ?? current).copyWith(feedUrl: null, isRevokingFeed: false),
      );
    } catch (error) {
      state = AsyncData(
        (state.value ?? current).copyWith(
          feedError: error.toString(),
          isRevokingFeed: false,
        ),
      );
      rethrow;
    }
  }

  Future<List<CalendarEntry>> _entriesFor(DateTime month) => _useCases.entries(
    GetCalendarEntriesRequest(
      from: DateTime(month.year, month.month),
      to: DateTime(month.year, month.month + 1, 0),
    ),
  );
}
