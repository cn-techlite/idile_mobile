import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/space_provider.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/dashboard_attention_provider.dart';
import 'package:idile_mobile_app/features/more/data/dto/documents/create_document_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/documents/get_documents_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/documents/update_document_request.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/documents/document_repository.dart';
import 'package:idile_mobile_app/features/more/presentation/state/providers/document_provider.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/document_state.dart';

class DocumentController extends AsyncNotifier<DocumentState> {
  static const _pageSize = 20;

  DocumentRepository get _repository => ref.read(documentRepositoryProvider);

  @override
  FutureOr<DocumentState> build() =>
      _firstPage(spaceId: ref.watch(selectedSpaceProvider));

  Future<DocumentState> _firstPage({
    String? status,
    String? type,
    String? spaceId,
    String? householdItemId,
    String? assetId,
    String sort = 'createdAt:desc',
  }) async {
    final page = await _repository.documents(
      GetDocumentsRequest(
        page: 1,
        limit: _pageSize,
        sort: sort,
        status: status,
        type: type,
        spaceId: spaceId,
        householdItemId: householdItemId,
        assetId: assetId,
      ),
    );
    return DocumentState.fromPage(
      page,
      status: status,
      type: type,
      spaceId: spaceId,
      householdItemId: householdItemId,
      assetId: assetId,
      sort: sort,
    );
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
      final page = await _repository.documents(
        GetDocumentsRequest(
          page: current.page + 1,
          limit: current.limit,
          sort: current.sort,
          status: current.statusFilter,
          type: current.typeFilter,
          spaceId: current.spaceIdFilter,
          householdItemId: current.householdItemIdFilter,
          assetId: current.assetIdFilter,
        ),
      );
      state = AsyncData((state.value ?? current).append(page));
    } catch (error) {
      state = AsyncData(
        (state.value ?? current).copyWith(
          isLoadingMore: false,
          loadMoreError: error.toString(),
        ),
      );
    }
  }

  Future<void> retryLoadMore() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(loadMoreError: null));
    await loadMore();
  }

  Future<void> refreshDocuments() async {
    final current = state.value;
    if (current == null) {
      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () => _firstPage(spaceId: ref.read(selectedSpaceProvider)),
      );
      return;
    }
    state = AsyncData(
      current.copyWith(isRefreshing: true, loadMoreError: null),
    );
    try {
      state = AsyncData(
        await _firstPage(
          status: current.statusFilter,
          type: current.typeFilter,
          spaceId: current.spaceIdFilter,
          householdItemId: current.householdItemIdFilter,
          assetId: current.assetIdFilter,
          sort: current.sort,
        ),
      );
    } catch (error) {
      state = AsyncData(current.copyWith(isRefreshing: false));
      rethrow;
    }
  }

  Future<void> setStatus(String? status) => _setFilters(status: status);

  Future<void> setType(String? type) => _setFilters(type: type);

  Future<void> setLinkedItem({String? householdItemId, String? assetId}) =>
      _setFilters(householdItemId: householdItemId, assetId: assetId);

  Future<void> _setFilters({
    Object? status = _unchanged,
    Object? type = _unchanged,
    Object? householdItemId = _unchanged,
    Object? assetId = _unchanged,
  }) async {
    final current = state.value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _firstPage(
        status: identical(status, _unchanged)
            ? current?.statusFilter
            : status as String?,
        type: identical(type, _unchanged)
            ? current?.typeFilter
            : type as String?,
        householdItemId: identical(householdItemId, _unchanged)
            ? current?.householdItemIdFilter
            : householdItemId as String?,
        assetId: identical(assetId, _unchanged)
            ? current?.assetIdFilter
            : assetId as String?,
        spaceId: current?.spaceIdFilter ?? ref.read(selectedSpaceProvider),
        sort: current?.sort ?? 'createdAt:desc',
      ),
    );
  }

  Future<void> createDocument(CreateDocumentRequest request) async {
    final current = state.value ?? const DocumentState();
    if (current.isCreating) return;
    state = AsyncData(current.copyWith(isCreating: true));
    try {
      await _repository.createDocument(request);
      await _reloadAfterMutation(current);
    } catch (error) {
      state = AsyncData((state.value ?? current).copyWith(isCreating: false));
      rethrow;
    }
  }

  Future<void> updateDocument(String id, UpdateDocumentRequest request) async {
    final current = state.value;
    if (current == null || current.isUpdating(id)) return;
    state = AsyncData(
      current.copyWith(
        updatingIds: Set.unmodifiable({...current.updatingIds, id}),
      ),
    );
    try {
      final updated = await _repository.updateDocument(id, request);
      state = AsyncData((state.value ?? current).replace(updated));
      ref.invalidate(dashboardControllerProvider);
    } catch (error) {
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          updatingIds: Set.unmodifiable(
            latest.updatingIds.where((value) => value != id),
          ),
        ),
      );
      rethrow;
    }
  }

  Future<void> deleteDocument(String id) async {
    final current = state.value;
    if (current == null || current.isDeleting(id)) return;
    state = AsyncData(
      current.copyWith(
        deletingIds: Set.unmodifiable({...current.deletingIds, id}),
      ),
    );
    try {
      final deleted = await _repository.deleteDocument(id);
      if (!deleted) throw StateError('The document was not deleted.');
      await _reloadAfterMutation(current);
    } catch (error) {
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          deletingIds: Set.unmodifiable(
            latest.deletingIds.where((value) => value != id),
          ),
        ),
      );
      rethrow;
    }
  }

  Future<void> _reloadAfterMutation(DocumentState current) async {
    state = AsyncData(
      await _firstPage(
        status: current.statusFilter,
        type: current.typeFilter,
        spaceId: current.spaceIdFilter,
        householdItemId: current.householdItemIdFilter,
        assetId: current.assetIdFilter,
        sort: current.sort,
      ),
    );
    ref.invalidate(dashboardControllerProvider);
  }
}

const _unchanged = Object();
