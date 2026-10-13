import 'package:idile_mobile_app/features/more/data/model/documents/document_item.dart';

class DocumentState {
  const DocumentState({
    this.documents = const [],
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
    this.hasPrevPage = false,
    this.statusFilter,
    this.typeFilter,
    this.spaceIdFilter,
    this.householdItemIdFilter,
    this.assetIdFilter,
    this.sort = 'createdAt:desc',
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.isCreating = false,
    this.updatingIds = const {},
    this.deletingIds = const {},
    this.loadMoreError,
  });

  factory DocumentState.fromPage(
    DocumentPage page, {
    String? status,
    String? type,
    String? spaceId,
    String? householdItemId,
    String? assetId,
    String sort = 'createdAt:desc',
  }) => DocumentState(
    documents: page.documents,
    page: page.pagination.page,
    limit: page.pagination.limit,
    total: page.pagination.total,
    totalPages: page.pagination.totalPages,
    hasNextPage: page.pagination.hasNextPage,
    hasPrevPage: page.pagination.hasPrevPage,
    statusFilter: status,
    typeFilter: type,
    spaceIdFilter: spaceId,
    householdItemIdFilter: householdItemId,
    assetIdFilter: assetId,
    sort: sort,
  );

  final List<DocumentItem> documents;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;
  final String? statusFilter;
  final String? typeFilter;
  final String? spaceIdFilter;
  final String? householdItemIdFilter;
  final String? assetIdFilter;
  final String sort;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool isCreating;
  final Set<String> updatingIds;
  final Set<String> deletingIds;
  final String? loadMoreError;

  bool isUpdating(String id) => updatingIds.contains(id);
  bool isDeleting(String id) => deletingIds.contains(id);

  DocumentState append(DocumentPage nextPage) {
    final byId = <String, DocumentItem>{
      for (final document in documents) document.id: document,
      for (final document in nextPage.documents) document.id: document,
    };
    return copyWith(
      documents: byId.values.toList(growable: false),
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

  DocumentState replace(DocumentItem updated) => copyWith(
    documents: [
      for (final document in documents)
        if (document.id == updated.id) updated else document,
    ],
    updatingIds: Set.unmodifiable(updatingIds.where((id) => id != updated.id)),
  );

  DocumentState copyWith({
    List<DocumentItem>? documents,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPrevPage,
    Object? statusFilter = _unset,
    Object? typeFilter = _unset,
    Object? spaceIdFilter = _unset,
    Object? householdItemIdFilter = _unset,
    Object? assetIdFilter = _unset,
    String? sort,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? isCreating,
    Set<String>? updatingIds,
    Set<String>? deletingIds,
    Object? loadMoreError = _unset,
  }) => DocumentState(
    documents: documents ?? this.documents,
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
    householdItemIdFilter: identical(householdItemIdFilter, _unset)
        ? this.householdItemIdFilter
        : householdItemIdFilter as String?,
    assetIdFilter: identical(assetIdFilter, _unset)
        ? this.assetIdFilter
        : assetIdFilter as String?,
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
