import 'package:idile_mobile_app/features/bills/domain/entities/bills/bill.dart';

class BillState {
  const BillState({
    this.bills = const [],
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
    this.hasPrevPage = false,
    this.statusFilter,
    this.spaceIdFilter,
    this.categoryFilter,
    this.sort = 'due:asc',
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.isCreating = false,
    this.updatingIds = const {},
    this.deletingIds = const {},
    this.markingPaidIds = const {},
    this.loadMoreError,
  });

  factory BillState.fromPage(
    BillPage page, {
    String? status,
    String? spaceId,
    String? category,
    String sort = 'due:asc',
  }) => BillState(
    bills: page.bills,
    page: page.pagination.page,
    limit: page.pagination.limit,
    total: page.pagination.total,
    totalPages: page.pagination.totalPages,
    hasNextPage: page.pagination.hasNextPage,
    hasPrevPage: page.pagination.hasPrevPage,
    statusFilter: status,
    spaceIdFilter: spaceId,
    categoryFilter: category,
    sort: sort,
  );

  final List<Bill> bills;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;
  final String? statusFilter;
  final String? spaceIdFilter;
  final String? categoryFilter;
  final String sort;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool isCreating;
  final Set<String> updatingIds;
  final Set<String> deletingIds;
  final Set<String> markingPaidIds;
  final String? loadMoreError;

  bool isUpdating(String id) => updatingIds.contains(id);
  bool isDeleting(String id) => deletingIds.contains(id);
  bool isMarkingPaid(String id) => markingPaidIds.contains(id);

  BillState append(BillPage nextPage) {
    final byId = <String, Bill>{
      for (final bill in bills) bill.id: bill,
      for (final bill in nextPage.bills) bill.id: bill,
    };
    return copyWith(
      bills: byId.values.toList(growable: false),
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

  BillState replace(Bill bill) => copyWith(
    bills: [
      for (final current in bills)
        if (current.id == bill.id) bill else current,
    ],
    updatingIds: Set.unmodifiable(updatingIds.where((id) => id != bill.id)),
    markingPaidIds: Set.unmodifiable(
      markingPaidIds.where((id) => id != bill.id),
    ),
  );

  BillState copyWith({
    List<Bill>? bills,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPrevPage,
    Object? statusFilter = _unset,
    Object? spaceIdFilter = _unset,
    Object? categoryFilter = _unset,
    String? sort,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? isCreating,
    Set<String>? updatingIds,
    Set<String>? deletingIds,
    Set<String>? markingPaidIds,
    Object? loadMoreError = _unset,
  }) => BillState(
    bills: bills ?? this.bills,
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
    categoryFilter: identical(categoryFilter, _unset)
        ? this.categoryFilter
        : categoryFilter as String?,
    sort: sort ?? this.sort,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isCreating: isCreating ?? this.isCreating,
    updatingIds: updatingIds ?? this.updatingIds,
    deletingIds: deletingIds ?? this.deletingIds,
    markingPaidIds: markingPaidIds ?? this.markingPaidIds,
    loadMoreError: identical(loadMoreError, _unset)
        ? this.loadMoreError
        : loadMoreError as String?,
  );
}

const _unset = Object();
