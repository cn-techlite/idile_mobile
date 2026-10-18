import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/app/di/repository_providers.dart';
import 'package:idile_mobile_app/features/home/domain/usecases/dashboard/dashboard_attention_use_cases.dart';
import 'package:idile_mobile_app/features/home/presentation/state/state_model/dashboard_attention_state.dart';

class DashboardAttentionController
    extends AsyncNotifier<DashboardAttentionState> {
  DashboardAttentionUseCases get _useCases =>
      ref.read(dashboardAttentionUseCasesProvider);

  @override
  FutureOr<DashboardAttentionState> build() async =>
      DashboardAttentionState(attention: await _useCases.attention());

  Future<void> refreshAttention() async {
    final current = state.value;
    if (current == null) {
      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () async =>
            DashboardAttentionState(attention: await _useCases.attention()),
      );
      return;
    }
    state = AsyncData(current.copyWith(isRefreshing: true));
    try {
      state = AsyncData(
        DashboardAttentionState(attention: await _useCases.attention()),
      );
    } catch (error) {
      state = AsyncData(current);
      rethrow;
    }
  }
}
