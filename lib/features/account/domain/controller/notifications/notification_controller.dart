import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/account/data/dto/notifications/get_notifications_request.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/notifications/notification_repository.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/notification_provider.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/notification_state.dart';

class NotificationController extends AsyncNotifier<NotificationState> {
  static const _pageSize = 20;

  NotificationRepository get _repository =>
      ref.read(notificationRepositoryProvider);

  @override
  FutureOr<NotificationState> build() => _firstPage();

  Future<NotificationState> _firstPage({bool? read}) async {
    final page = await _repository.notifications(
      GetNotificationsRequest(page: 1, limit: _pageSize, read: read),
    );
    return NotificationState.fromPage(page, readFilter: read);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        current.isLoadingMore ||
        !current.hasNextPage ||
        current.loadMoreError != null) {
      return;
    }
    state = AsyncData(
      current.copyWith(isLoadingMore: true, loadMoreError: null),
    );
    try {
      final page = await _repository.notifications(
        GetNotificationsRequest(
          page: current.page + 1,
          limit: current.limit,
          read: current.readFilter,
        ),
      );
      final latest = state.value ?? current;
      state = AsyncData(latest.append(page));
    } catch (error) {
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(isLoadingMore: false, loadMoreError: error.toString()),
      );
    }
  }

  Future<void> retryLoadMore() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(loadMoreError: null));
    await loadMore();
  }

  Future<void> refreshNotifications() async {
    final current = state.value;
    if (current == null) {
      state = await AsyncValue.guard(_firstPage);
      return;
    }
    state = AsyncData(
      current.copyWith(isRefreshing: true, loadMoreError: null),
    );
    try {
      final fresh = await _firstPage(read: current.readFilter);
      state = AsyncData(fresh);
    } catch (_) {
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(isRefreshing: false));
    }
  }

  Future<void> setReadFilter(bool? read) async {
    final current = state.value;
    if (current?.readFilter == read && current?.hasLoadedInitially == true) {
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _firstPage(read: read));
  }

  Future<void> markRead(String notificationId) async {
    final current = state.value;
    if (current == null ||
        current.isMarkingAllRead ||
        current.isMarkingRead(notificationId)) {
      return;
    }
    final notification = current.notifications
        .where((item) => item.id == notificationId)
        .firstOrNull;
    if (notification == null || notification.read) return;

    state = AsyncData(current.setMarkingRead(notificationId, true));
    try {
      final response = await _repository.markRead(notificationId);
      final updated = response.copyWith(read: true);
      final latest = state.value ?? current;
      if (latest.readFilter == false) {
        state = AsyncData(latest.removeNotification(notificationId));
        try {
          state = AsyncData(await _firstPage(read: false));
        } catch (_) {
          // Marking the item succeeded; retain the locally corrected list when
          // refreshing the unread page is temporarily unavailable.
        }
      } else {
        state = AsyncData(latest.replaceNotification(updated));
      }
    } catch (error) {
      final latest = state.value ?? current;
      state = AsyncData(latest.setMarkingRead(notificationId, false));
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    final current = state.value;
    if (current == null ||
        current.isMarkingAllRead ||
        current.markingReadIds.isNotEmpty) {
      return;
    }

    state = AsyncData(current.copyWith(isMarkingAllRead: true));
    try {
      await _repository.markAllRead();
      final latest = state.value ?? current;
      if (latest.readFilter == false) {
        state = AsyncData(latest.clearUnreadLocally());
        try {
          state = AsyncData(await _firstPage(read: false));
        } catch (_) {
          // The PATCH succeeded. Keep the locally emptied unread list if the
          // follow-up refresh cannot be completed right now.
        }
      } else {
        state = AsyncData(latest.markAllReadLocally());
      }
    } catch (error) {
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(isMarkingAllRead: false));
      rethrow;
    }
  }
}
