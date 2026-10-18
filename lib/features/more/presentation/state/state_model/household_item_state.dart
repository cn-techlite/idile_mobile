import 'package:idile_mobile_app/features/more/domain/entities/household_items/household_item.dart';

class HouseholdItemState {
  const HouseholdItemState({
    this.items = const [],
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
    this.hasPrevPage = false,
    this.roomFilter,
    this.spaceIdFilter,
    this.sort = 'createdAt:desc',
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.isCreating = false,
    this.updatingIds = const {},
    this.deletingIds = const {},
    this.loadMoreError,
  });

  factory HouseholdItemState.fromPage(
    HouseholdItemPage page, {
    String? room,
    String? spaceId,
    String sort = 'createdAt:desc',
  }) => HouseholdItemState(
    items: page.items,
    page: page.pagination.page,
    limit: page.pagination.limit,
    total: page.pagination.total,
    totalPages: page.pagination.totalPages,
    hasNextPage: page.pagination.hasNextPage,
    hasPrevPage: page.pagination.hasPrevPage,
    roomFilter: room,
    spaceIdFilter: spaceId,
    sort: sort,
  );

  final List<HouseholdItem> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;
  final String? roomFilter;
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

  HouseholdItemState append(HouseholdItemPage nextPage) {
    final byId = <String, HouseholdItem>{
      for (final item in items) item.id: item,
      for (final item in nextPage.items) item.id: item,
    };
    return copyWith(
      items: byId.values.toList(growable: false),
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

  HouseholdItemState replace(HouseholdItem updated) => copyWith(
    items: [
      for (final item in items)
        if (item.id == updated.id) updated else item,
    ],
    updatingIds: Set.unmodifiable(updatingIds.where((id) => id != updated.id)),
  );

  HouseholdItemState copyWith({
    List<HouseholdItem>? items,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPrevPage,
    Object? roomFilter = _unset,
    Object? spaceIdFilter = _unset,
    String? sort,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? isCreating,
    Set<String>? updatingIds,
    Set<String>? deletingIds,
    Object? loadMoreError = _unset,
  }) => HouseholdItemState(
    items: items ?? this.items,
    page: page ?? this.page,
    limit: limit ?? this.limit,
    total: total ?? this.total,
    totalPages: totalPages ?? this.totalPages,
    hasNextPage: hasNextPage ?? this.hasNextPage,
    hasPrevPage: hasPrevPage ?? this.hasPrevPage,
    roomFilter: identical(roomFilter, _unset)
        ? this.roomFilter
        : roomFilter as String?,
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
