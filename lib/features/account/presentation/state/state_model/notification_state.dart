import 'package:idile_mobile_app/features/account/data/model/notifications/in_app_notification.dart';

class NotificationState {
  const NotificationState({
    this.notifications = const [],
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
    this.hasPrevPage = false,
    this.readFilter,
    this.hasLoadedInitially = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.isMarkingAllRead = false,
    this.markingReadIds = const {},
    this.loadMoreError,
  });

  factory NotificationState.fromPage(
    NotificationPage page, {
    bool? readFilter,
  }) => NotificationState(
    notifications: page.notifications,
    page: page.pagination.page,
    limit: page.pagination.limit,
    total: page.pagination.total,
    totalPages: page.pagination.totalPages,
    hasNextPage: page.pagination.hasNextPage,
    hasPrevPage: page.pagination.hasPrevPage,
    readFilter: readFilter,
    hasLoadedInitially: true,
  );

  final List<InAppNotification> notifications;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;
  final bool? readFilter;
  final bool hasLoadedInitially;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool isMarkingAllRead;
  final Set<String> markingReadIds;
  final String? loadMoreError;

  bool isMarkingRead(String notificationId) =>
      markingReadIds.contains(notificationId);

  NotificationState append(NotificationPage nextPage) {
    final byId = <String, InAppNotification>{
      for (final notification in notifications) notification.id: notification,
      for (final notification in nextPage.notifications)
        notification.id: notification,
    };
    return copyWith(
      notifications: byId.values.toList(growable: false),
      page: nextPage.pagination.page,
      limit: nextPage.pagination.limit,
      total: nextPage.pagination.total,
      totalPages: nextPage.pagination.totalPages,
      hasNextPage: nextPage.pagination.hasNextPage,
      hasPrevPage: nextPage.pagination.hasPrevPage,
      isLoadingMore: false,
      loadMoreError: null,
    );
  }

  NotificationState setMarkingRead(String notificationId, bool loading) {
    final ids = {...markingReadIds};
    if (loading) {
      ids.add(notificationId);
    } else {
      ids.remove(notificationId);
    }
    return copyWith(markingReadIds: Set.unmodifiable(ids));
  }

  NotificationState replaceNotification(InAppNotification updated) => copyWith(
    notifications: [
      for (final notification in notifications)
        if (notification.id == updated.id) updated else notification,
    ],
    markingReadIds: Set.unmodifiable(
      markingReadIds.where((id) => id != updated.id),
    ),
  );

  NotificationState removeNotification(String notificationId) => copyWith(
    notifications: notifications
        .where((notification) => notification.id != notificationId)
        .toList(growable: false),
    total: total > 0 ? total - 1 : 0,
    markingReadIds: Set.unmodifiable(
      markingReadIds.where((id) => id != notificationId),
    ),
  );

  NotificationState markAllReadLocally() => copyWith(
    notifications: [
      for (final notification in notifications)
        notification.read ? notification : notification.copyWith(read: true),
    ],
    isMarkingAllRead: false,
    markingReadIds: const {},
  );

  NotificationState clearUnreadLocally() => copyWith(
    notifications: const [],
    page: 1,
    total: 0,
    totalPages: 0,
    hasNextPage: false,
    hasPrevPage: false,
    isMarkingAllRead: false,
    markingReadIds: const {},
  );

  NotificationState copyWith({
    List<InAppNotification>? notifications,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPrevPage,
    Object? readFilter = _unset,
    bool? hasLoadedInitially,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? isMarkingAllRead,
    Set<String>? markingReadIds,
    Object? loadMoreError = _unset,
  }) => NotificationState(
    notifications: notifications ?? this.notifications,
    page: page ?? this.page,
    limit: limit ?? this.limit,
    total: total ?? this.total,
    totalPages: totalPages ?? this.totalPages,
    hasNextPage: hasNextPage ?? this.hasNextPage,
    hasPrevPage: hasPrevPage ?? this.hasPrevPage,
    readFilter: identical(readFilter, _unset)
        ? this.readFilter
        : readFilter as bool?,
    hasLoadedInitially: hasLoadedInitially ?? this.hasLoadedInitially,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isMarkingAllRead: isMarkingAllRead ?? this.isMarkingAllRead,
    markingReadIds: markingReadIds ?? this.markingReadIds,
    loadMoreError: identical(loadMoreError, _unset)
        ? this.loadMoreError
        : loadMoreError as String?,
  );
}

const _unset = Object();
