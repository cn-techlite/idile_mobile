import 'package:idile_mobile_app/features/more/data/model/maintenance/maintenance_task.dart';

class MaintenanceState {
  const MaintenanceState({
    this.tasks = const [],
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
    this.hasPrevPage = false,
    this.statusFilter,
    this.spaceIdFilter,
    this.sort = 'nextDue:asc',
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.isCreating = false,
    this.updatingIds = const {},
    this.deletingIds = const {},
    this.completingIds = const {},
    this.loadMoreError,
  });

  factory MaintenanceState.fromPage(
    MaintenancePage page, {
    String? status,
    String? spaceId,
    String sort = 'nextDue:asc',
  }) => MaintenanceState(
    tasks: page.tasks,
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

  final List<MaintenanceTask> tasks;
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
  final Set<String> completingIds;
  final String? loadMoreError;

  bool isUpdating(String id) => updatingIds.contains(id);
  bool isDeleting(String id) => deletingIds.contains(id);
  bool isCompleting(String id) => completingIds.contains(id);

  MaintenanceState append(MaintenancePage nextPage) {
    final byId = <String, MaintenanceTask>{
      for (final task in tasks) task.id: task,
      for (final task in nextPage.tasks) task.id: task,
    };
    return copyWith(
      tasks: byId.values.toList(growable: false),
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

  MaintenanceState replace(MaintenanceTask updated) => copyWith(
    tasks: [
      for (final task in tasks)
        if (task.id == updated.id) updated else task,
    ],
    updatingIds: Set.unmodifiable(updatingIds.where((id) => id != updated.id)),
    completingIds: Set.unmodifiable(
      completingIds.where((id) => id != updated.id),
    ),
  );

  MaintenanceState copyWith({
    List<MaintenanceTask>? tasks,
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
    Set<String>? completingIds,
    Object? loadMoreError = _unset,
  }) => MaintenanceState(
    tasks: tasks ?? this.tasks,
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
    completingIds: completingIds ?? this.completingIds,
    loadMoreError: identical(loadMoreError, _unset)
        ? this.loadMoreError
        : loadMoreError as String?,
  );
}

const _unset = Object();
