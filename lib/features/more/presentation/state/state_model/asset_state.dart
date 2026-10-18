import 'package:idile_mobile_app/features/more/domain/entities/assets/asset_item.dart';

class AssetState {
  const AssetState({
    this.assets = const [],
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
    this.hasPrevPage = false,
    this.statusFilter,
    this.typeFilter,
    this.spaceIdFilter,
    this.sort = 'createdAt:desc',
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.isCreating = false,
    this.updatingIds = const {},
    this.deletingIds = const {},
    this.loadMoreError,
  });

  factory AssetState.fromPage(
    AssetPage page, {
    String? status,
    String? type,
    String? spaceId,
    String sort = 'createdAt:desc',
  }) => AssetState(
    assets: page.assets,
    page: page.pagination.page,
    limit: page.pagination.limit,
    total: page.pagination.total,
    totalPages: page.pagination.totalPages,
    hasNextPage: page.pagination.hasNextPage,
    hasPrevPage: page.pagination.hasPrevPage,
    statusFilter: status,
    typeFilter: type,
    spaceIdFilter: spaceId,
    sort: sort,
  );

  final List<AssetItem> assets;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;
  final String? statusFilter;
  final String? typeFilter;
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

  AssetState append(AssetPage nextPage) {
    final byId = <String, AssetItem>{
      for (final asset in assets) asset.id: asset,
      for (final asset in nextPage.assets) asset.id: asset,
    };
    return copyWith(
      assets: byId.values.toList(growable: false),
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

  AssetState replace(AssetItem updated) => copyWith(
    assets: [
      for (final asset in assets)
        if (asset.id == updated.id) updated else asset,
    ],
    updatingIds: Set.unmodifiable(updatingIds.where((id) => id != updated.id)),
  );

  AssetState copyWith({
    List<AssetItem>? assets,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPrevPage,
    Object? statusFilter = _unset,
    Object? typeFilter = _unset,
    Object? spaceIdFilter = _unset,
    String? sort,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? isCreating,
    Set<String>? updatingIds,
    Set<String>? deletingIds,
    Object? loadMoreError = _unset,
  }) => AssetState(
    assets: assets ?? this.assets,
    page: page ?? this.page,
    limit: limit ?? this.limit,
    total: total ?? this.total,
    totalPages: totalPages ?? this.totalPages,
    hasNextPage: hasNextPage ?? this.hasNextPage,
    hasPrevPage: hasPrevPage ?? this.hasPrevPage,
    statusFilter: identical(statusFilter, _unset)
        ? this.statusFilter
        : statusFilter as String?,
    typeFilter: identical(typeFilter, _unset)
        ? this.typeFilter
        : typeFilter as String?,
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
