import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/space_provider.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/dashboard_attention_provider.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/create_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/get_subscriptions_request.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/update_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/domain/usecases/subscriptions/subscription_repository.dart';
import 'package:idile_mobile_app/features/subs/presentation/state/providers/subscription_provider.dart';
import 'package:idile_mobile_app/features/subs/presentation/state/state_model/subscription_state.dart';

class SubscriptionController extends AsyncNotifier<SubscriptionState> {
  static const _pageSize = 20;

  SubscriptionRepository get _repository =>
      ref.read(subscriptionRepositoryProvider);

  @override
  FutureOr<SubscriptionState> build() =>
      _firstPage(spaceId: ref.watch(selectedSpaceProvider));

  Future<SubscriptionState> _firstPage({
    String? status,
    String? spaceId,
    String sort = 'renewal:asc',
  }) async {
    final page = await _repository.subscriptions(
      GetSubscriptionsRequest(
        status: status,
        spaceId: spaceId,
        page: 1,
        limit: _pageSize,
        sort: sort,
      ),
    );
    return SubscriptionState.fromPage(
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
      final page = await _repository.subscriptions(
        GetSubscriptionsRequest(
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

  Future<void> refreshSubscriptions() async {
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
        sort: current?.sort ?? 'renewal:asc',
      ),
    );
  }

  Future<void> createSubscription(CreateSubscriptionRequest request) async {
    final current = state.value ?? const SubscriptionState();
    if (current.isCreating) return;
    state = AsyncData(current.copyWith(isCreating: true));
    try {
      await _repository.createSubscription(request);
      await _reloadAfterMutation(current);
    } catch (error) {
      state = AsyncData((state.value ?? current).copyWith(isCreating: false));
      rethrow;
    }
  }

  Future<void> updateSubscription(
    String id,
    UpdateSubscriptionRequest request,
  ) async {
    final current = state.value;
    if (current == null || current.isUpdating(id)) return;
    state = AsyncData(
      current.copyWith(
        updatingIds: Set.unmodifiable({...current.updatingIds, id}),
      ),
    );
    try {
      final updated = await _repository.updateSubscription(id, request);
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

  Future<void> deleteSubscription(String id) async {
    final current = state.value;
    if (current == null || current.isDeleting(id)) return;
    state = AsyncData(
      current.copyWith(
        deletingIds: Set.unmodifiable({...current.deletingIds, id}),
      ),
    );
    try {
      final deleted = await _repository.deleteSubscription(id);
      if (!deleted) throw StateError('The subscription was not deleted.');
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

  Future<void> _reloadAfterMutation(SubscriptionState current) async {
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
