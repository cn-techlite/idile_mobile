import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/app/di/repository_providers.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/spaces/create_space_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/spaces/update_space_request.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/spaces/space_use_cases.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/space_provider.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/space_state.dart';

class SelectedSpaceController extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

class SpaceController extends AsyncNotifier<SpaceState> {
  SpaceUseCases get _useCases => ref.read(spaceUseCasesProvider);

  @override
  FutureOr<SpaceState> build() => _load();

  Future<SpaceState> _load() async =>
      SpaceState(spaces: await _useCases.spaces());

  Future<void> refreshSpaces() async {
    final current = state.value;
    if (current == null) {
      state = const AsyncLoading();
      state = await AsyncValue.guard(_load);
      return;
    }
    state = AsyncData(current.copyWith(isRefreshing: true));
    try {
      state = AsyncData(await _load());
    } catch (error) {
      state = AsyncData(current.copyWith(isRefreshing: false));
      rethrow;
    }
  }

  Future<void> createSpace(CreateSpaceRequest request) async {
    final current = state.value ?? const SpaceState();
    if (current.isCreating) return;
    state = AsyncData(current.copyWith(isCreating: true));
    try {
      final created = await _useCases.createSpace(request);
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(spaces: [...latest.spaces, created], isCreating: false),
      );
    } catch (error) {
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(isCreating: false));
      rethrow;
    }
  }

  Future<void> updateSpace(String id, UpdateSpaceRequest request) async {
    final current = state.value;
    if (current == null || current.isUpdating(id)) return;
    state = AsyncData(
      current.copyWith(
        updatingIds: Set.unmodifiable({...current.updatingIds, id}),
      ),
    );
    try {
      final response = await _useCases.updateSpace(id, request);
      final latest = state.value ?? current;
      final existing = latest.spaces
          .where((space) => space.id == id)
          .firstOrNull;
      final updated = response.copyWith(itemCount: existing?.itemCount ?? 0);
      state = AsyncData(
        latest.copyWith(
          spaces: [
            for (final space in latest.spaces)
              if (space.id == id) updated else space,
          ],
          updatingIds: Set.unmodifiable(
            latest.updatingIds.where((value) => value != id),
          ),
        ),
      );
      ref.invalidate(spaceSummaryProvider(id));
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

  Future<void> deleteSpace(String id) async {
    final current = state.value;
    if (current == null || current.isDeleting(id)) return;
    state = AsyncData(
      current.copyWith(
        deletingIds: Set.unmodifiable({...current.deletingIds, id}),
      ),
    );
    try {
      final deleted = await _useCases.deleteSpace(id);
      if (!deleted) throw StateError('The space was not deleted.');
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          spaces: latest.spaces
              .where((space) => space.id != id)
              .toList(growable: false),
          deletingIds: Set.unmodifiable(
            latest.deletingIds.where((value) => value != id),
          ),
        ),
      );
      if (ref.read(selectedSpaceProvider) == id) {
        ref.read(selectedSpaceProvider.notifier).select(null);
      }
      ref.invalidate(spaceSummaryProvider(id));
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
}
