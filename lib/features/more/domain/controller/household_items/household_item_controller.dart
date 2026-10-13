import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/space_provider.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/dashboard_attention_provider.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/create_household_item_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/get_household_items_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/update_household_item_request.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/household_items/household_item_repository.dart';
import 'package:idile_mobile_app/features/more/presentation/state/providers/household_item_provider.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/household_item_state.dart';

class HouseholdItemController extends AsyncNotifier<HouseholdItemState> {
  static const _pageSize = 20;

  HouseholdItemRepository get _repository =>
      ref.read(householdItemRepositoryProvider);

  @override
  FutureOr<HouseholdItemState> build() =>
      _firstPage(spaceId: ref.watch(selectedSpaceProvider));

  Future<HouseholdItemState> _firstPage({
    String? room,
    String? spaceId,
    String sort = 'createdAt:desc',
  }) async {
    final page = await _repository.householdItems(
      GetHouseholdItemsRequest(
        room: room,
        spaceId: spaceId,
        page: 1,
        limit: _pageSize,
        sort: sort,
      ),
    );
    return HouseholdItemState.fromPage(
      page,
      room: room,
      spaceId: spaceId,
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
      final page = await _repository.householdItems(
        GetHouseholdItemsRequest(
          room: current.roomFilter,
          spaceId: current.spaceIdFilter,
          page: current.page + 1,
          limit: current.limit,
          sort: current.sort,
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

  Future<void> refreshHouseholdItems() async {
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
          room: current.roomFilter,
          spaceId: current.spaceIdFilter,
          sort: current.sort,
        ),
      );
    } catch (error) {
      state = AsyncData(current.copyWith(isRefreshing: false));
      rethrow;
    }
  }

  Future<void> setRoom(String? room) async {
    final current = state.value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _firstPage(
        room: room,
        spaceId: current?.spaceIdFilter ?? ref.read(selectedSpaceProvider),
        sort: current?.sort ?? 'createdAt:desc',
      ),
    );
  }

  Future<void> createHouseholdItem(CreateHouseholdItemRequest request) async {
    final current = state.value ?? const HouseholdItemState();
    if (current.isCreating) return;
    state = AsyncData(current.copyWith(isCreating: true));
    try {
      await _repository.createHouseholdItem(request);
      await _reloadAfterMutation(current);
    } catch (error) {
      state = AsyncData((state.value ?? current).copyWith(isCreating: false));
      rethrow;
    }
  }

  Future<void> updateHouseholdItem(
    String id,
    UpdateHouseholdItemRequest request,
  ) async {
    final current = state.value;
    if (current == null || current.isUpdating(id)) return;
    state = AsyncData(
      current.copyWith(
        updatingIds: Set.unmodifiable({...current.updatingIds, id}),
      ),
    );
    try {
      final updated = await _repository.updateHouseholdItem(id, request);
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

  Future<void> deleteHouseholdItem(String id) async {
    final current = state.value;
    if (current == null || current.isDeleting(id)) return;
    state = AsyncData(
      current.copyWith(
        deletingIds: Set.unmodifiable({...current.deletingIds, id}),
      ),
    );
    try {
      final deleted = await _repository.deleteHouseholdItem(id);
      if (!deleted) throw StateError('The household item was not deleted.');
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

  Future<void> _reloadAfterMutation(HouseholdItemState current) async {
    state = AsyncData(
      await _firstPage(
        room: current.roomFilter,
        spaceId: current.spaceIdFilter,
        sort: current.sort,
      ),
    );
    ref.invalidate(dashboardControllerProvider);
  }
}
