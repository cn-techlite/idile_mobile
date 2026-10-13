import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/space_provider.dart';
import 'package:idile_mobile_app/features/bills/data/dto/bills/create_bill_request.dart';
import 'package:idile_mobile_app/features/bills/data/dto/bills/get_bills_request.dart';
import 'package:idile_mobile_app/features/bills/data/dto/bills/update_bill_request.dart';
import 'package:idile_mobile_app/features/bills/data/dto/payments/get_bill_payments_request.dart';
import 'package:idile_mobile_app/features/bills/data/model/payments/payment_record.dart';
import 'package:idile_mobile_app/features/bills/domain/usecases/bills/bill_repository.dart';
import 'package:idile_mobile_app/features/bills/presentation/state/providers/bill_provider.dart';
import 'package:idile_mobile_app/features/bills/presentation/state/state_model/bill_state.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/dashboard_attention_provider.dart';

class BillController extends AsyncNotifier<BillState> {
  static const _pageSize = 20;

  BillRepository get _repository => ref.read(billRepositoryProvider);

  @override
  FutureOr<BillState> build() {
    final spaceId = ref.watch(selectedSpaceProvider);
    return _firstPage(spaceId: spaceId);
  }

  Future<BillState> _firstPage({
    String? status,
    String? spaceId,
    String? category,
    String sort = 'due:asc',
  }) async {
    final page = await _repository.bills(
      GetBillsRequest(
        status: status,
        spaceId: spaceId,
        category: category,
        page: 1,
        limit: _pageSize,
        sort: sort,
      ),
    );
    return BillState.fromPage(
      page,
      status: status,
      spaceId: spaceId,
      category: category,
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
      final page = await _repository.bills(
        GetBillsRequest(
          status: current.statusFilter,
          spaceId: current.spaceIdFilter,
          category: current.categoryFilter,
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

  Future<void> refreshBills() async {
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
          category: current.categoryFilter,
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
    final spaceId = current?.spaceIdFilter ?? ref.read(selectedSpaceProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _firstPage(
        status: status,
        spaceId: spaceId,
        category: current?.categoryFilter,
        sort: current?.sort ?? 'due:asc',
      ),
    );
  }

  Future<void> createBill(CreateBillRequest request) async {
    final current = state.value ?? const BillState();
    if (current.isCreating) return;
    state = AsyncData(current.copyWith(isCreating: true));
    try {
      await _repository.createBill(request);
      await _reloadAfterMutation(current);
    } catch (error) {
      state = AsyncData((state.value ?? current).copyWith(isCreating: false));
      rethrow;
    }
  }

  Future<void> updateBill(String id, UpdateBillRequest request) async {
    final current = state.value;
    if (current == null || current.isUpdating(id)) return;
    state = AsyncData(
      current.copyWith(
        updatingIds: Set.unmodifiable({...current.updatingIds, id}),
      ),
    );
    try {
      final updated = await _repository.updateBill(id, request);
      state = AsyncData((state.value ?? current).replace(updated));
      _invalidateRelated();
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

  Future<void> deleteBill(String id) async {
    final current = state.value;
    if (current == null || current.isDeleting(id)) return;
    state = AsyncData(
      current.copyWith(
        deletingIds: Set.unmodifiable({...current.deletingIds, id}),
      ),
    );
    try {
      final deleted = await _repository.deleteBill(id);
      if (!deleted) throw StateError('The bill was not deleted.');
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

  Future<void> markPaid(String id) async {
    final current = state.value;
    if (current == null || current.isMarkingPaid(id)) return;
    state = AsyncData(
      current.copyWith(
        markingPaidIds: Set.unmodifiable({...current.markingPaidIds, id}),
      ),
    );
    try {
      final updated = await _repository.markPaid(id);
      state = AsyncData((state.value ?? current).replace(updated));
      _invalidateRelated();
    } catch (error) {
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          markingPaidIds: Set.unmodifiable(
            latest.markingPaidIds.where((value) => value != id),
          ),
        ),
      );
      rethrow;
    }
  }

  Future<void> _reloadAfterMutation(BillState current) async {
    state = AsyncData(
      await _firstPage(
        status: current.statusFilter,
        spaceId: current.spaceIdFilter,
        category: current.categoryFilter,
        sort: current.sort,
      ),
    );
    _invalidateRelated();
  }

  void _invalidateRelated() {
    ref.invalidate(dashboardControllerProvider);
    ref.invalidate(billPaymentControllerProvider);
  }
}

class BillPaymentController extends AsyncNotifier<List<PaymentRecord>> {
  @override
  FutureOr<List<PaymentRecord>> build() => ref
      .read(billRepositoryProvider)
      .payments(
        GetBillPaymentsRequest(spaceId: ref.watch(selectedSpaceProvider)),
      );
}
