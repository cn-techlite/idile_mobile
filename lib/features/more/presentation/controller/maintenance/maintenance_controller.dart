import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/app/di/repository_providers.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/space_provider.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/dashboard_attention_provider.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/maintenance/create_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/maintenance/get_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/maintenance/update_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/maintenance/maintenance_use_cases.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/maintenance_state.dart';

class MaintenanceController extends AsyncNotifier<MaintenanceState> {
  static const _pageSize = 20;

  MaintenanceUseCases get _useCases => ref.read(maintenanceUseCasesProvider);

  @override
  FutureOr<MaintenanceState> build() =>
      _firstPage(spaceId: ref.watch(selectedSpaceProvider));

  Future<MaintenanceState> _firstPage({
    String? status,
    String? spaceId,
    String sort = 'nextDue:asc',
  }) async {
    final page = await _useCases.maintenance(
      GetMaintenanceRequest(
        status: status,
        spaceId: spaceId,
        page: 1,
        limit: _pageSize,
        sort: sort,
      ),
    );
    return MaintenanceState.fromPage(
      page,
      status: status,
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
      final page = await _useCases.maintenance(
        GetMaintenanceRequest(
          status: current.statusFilter,
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

  Future<void> refreshMaintenance() async {
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
          spaceId: current.spaceIdFilter,
          sort: current.sort,
        ),
      );
    } catch (error) {
      state = AsyncData(current.copyWith(isRefreshing: false));
      rethrow;
    }
  }

  Future<void> setStatus(String? status) async {
    final current = state.value;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _firstPage(
        status: status,
        spaceId: current?.spaceIdFilter ?? ref.read(selectedSpaceProvider),
        sort: current?.sort ?? 'nextDue:asc',
      ),
    );
  }

  Future<void> createMaintenance(CreateMaintenanceRequest request) async {
    final current = state.value ?? const MaintenanceState();
    if (current.isCreating) return;
    state = AsyncData(current.copyWith(isCreating: true));
    try {
      await _useCases.createMaintenance(request);
      await _reloadAfterMutation(current);
    } catch (error) {
      state = AsyncData((state.value ?? current).copyWith(isCreating: false));
      rethrow;
    }
  }

  Future<void> updateMaintenance(
    String id,
    UpdateMaintenanceRequest request,
  ) async {
    final current = state.value;
    if (current == null || current.isUpdating(id)) return;
    state = AsyncData(
      current.copyWith(
        updatingIds: Set.unmodifiable({...current.updatingIds, id}),
      ),
    );
    try {
      final updated = await _useCases.updateMaintenance(id, request);
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

  Future<void> deleteMaintenance(String id) async {
    final current = state.value;
    if (current == null || current.isDeleting(id)) return;
    state = AsyncData(
      current.copyWith(
        deletingIds: Set.unmodifiable({...current.deletingIds, id}),
      ),
    );
    try {
      final deleted = await _useCases.deleteMaintenance(id);
      if (!deleted) throw StateError('The maintenance task was not deleted.');
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

  Future<void> markDone(String id) async {
    final current = state.value;
    if (current == null || current.isCompleting(id)) return;
    state = AsyncData(
      current.copyWith(
        completingIds: Set.unmodifiable({...current.completingIds, id}),
      ),
    );
    try {
      final updated = await _useCases.markDone(id);
      state = AsyncData((state.value ?? current).replace(updated));
      ref.invalidate(dashboardControllerProvider);
    } catch (error) {
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          completingIds: Set.unmodifiable(
            latest.completingIds.where((value) => value != id),
          ),
        ),
      );
      rethrow;
    }
  }

  Future<void> _reloadAfterMutation(MaintenanceState current) async {
    state = AsyncData(
      await _firstPage(
        status: current.statusFilter,
        spaceId: current.spaceIdFilter,
        sort: current.sort,
      ),
    );
    ref.invalidate(dashboardControllerProvider);
  }
}
