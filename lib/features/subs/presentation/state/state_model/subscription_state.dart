import 'package:idile_mobile_app/features/subs/domain/entities/subscriptions/subscription.dart';

class SubscriptionState {
  const SubscriptionState({
    this.subscriptions = const [],
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
    this.hasPrevPage = false,
    this.statusFilter,
    this.spaceIdFilter,
    this.sort = 'renewal:asc',
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.isCreating = false,
    this.updatingIds = const {},
    this.deletingIds = const {},
    this.loadMoreError,
  });

  factory SubscriptionState.fromPage(
    SubscriptionPage page, {
    String? status,
    String? spaceId,
    String sort = 'renewal:asc',
  }) => SubscriptionState(
    subscriptions: page.subscriptions,
    page: page.pagination.page,
    limit: page.pagination.limit,
    total: page.pagination.total,
    totalPages: page.pagination.totalPages,
    hasNextPage: page.pagination.hasNextPage,
    hasPrevPage: page.pagination.hasPrevPage,
    statusFilter: status,
    spaceIdFilter: spaceId,
    sort: sort,
  );

  final List<SubscriptionItem> subscriptions;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;
  final String? statusFilter;
  final String? spaceIdFilter;
  final String sort;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool isCreating;
  final Set<String> updatingIds;
  final Set<String> deletingIds;
  final String? loadMoreError;

  bool isUpdating(String id) => updatingIds.contains(id);
  bool isDeleting(String id) => deletingIds.contains(id);

  SubscriptionState append(SubscriptionPage nextPage) {
    final byId = <String, SubscriptionItem>{
      for (final item in subscriptions) item.id: item,
      for (final item in nextPage.subscriptions) item.id: item,
    };
    return copyWith(
      subscriptions: byId.values.toList(growable: false),
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

  SubscriptionState replace(SubscriptionItem updated) => copyWith(
    subscriptions: [
      for (final item in subscriptions)
        if (item.id == updated.id) updated else item,
    ],
    updatingIds: Set.unmodifiable(updatingIds.where((id) => id != updated.id)),
  );

  SubscriptionState copyWith({
    List<SubscriptionItem>? subscriptions,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPrevPage,
    Object? statusFilter = _unset,
    Object? spaceIdFilter = _unset,
    String? sort,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? isCreating,
    Set<String>? updatingIds,
    Set<String>? deletingIds,
    Object? loadMoreError = _unset,
  }) => SubscriptionState(
    subscriptions: subscriptions ?? this.subscriptions,
    page: page ?? this.page,
    limit: limit ?? this.limit,
    total: total ?? this.total,
    totalPages: totalPages ?? this.totalPages,
    hasNextPage: hasNextPage ?? this.hasNextPage,
    hasPrevPage: hasPrevPage ?? this.hasPrevPage,
    statusFilter: identical(statusFilter, _unset)
        ? this.statusFilter
        : statusFilter as String?,
    spaceIdFilter: identical(spaceIdFilter, _unset)
        ? this.spaceIdFilter
        : spaceIdFilter as String?,
    sort: sort ?? this.sort,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isCreating: isCreating ?? this.isCreating,
    updatingIds: updatingIds ?? this.updatingIds,
    deletingIds: deletingIds ?? this.deletingIds,
    loadMoreError: identical(loadMoreError, _unset)
        ? this.loadMoreError
        : loadMoreError as String?,
  );
}

const _unset = Object();
