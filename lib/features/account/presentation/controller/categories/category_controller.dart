import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/app/di/repository_providers.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/categories/create_category_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/categories/update_category_request.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/categories/category_use_cases.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/category_state.dart';

class CategoryController extends AsyncNotifier<CategoryState> {
  CategoryUseCases get _useCases => ref.read(categoryUseCasesProvider);

  @override
  FutureOr<CategoryState> build() => _load();

  Future<CategoryState> _load() async =>
      CategoryState(categories: await _useCases.categories());

  Future<void> refreshCategories() async {
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

  Future<void> createCategory(CreateCategoryRequest request) async {
    final current = state.value ?? const CategoryState();
    if (current.isCreating) return;
    state = AsyncData(current.copyWith(isCreating: true));
    try {
      final created = await _useCases.createCategory(request);
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          categories: [...latest.categories, created],
          isCreating: false,
        ),
      );
    } catch (error) {
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(isCreating: false));
      rethrow;
    }
  }

  Future<void> updateCategory(String id, UpdateCategoryRequest request) async {
    final current = state.value;
    if (current == null || current.isUpdating(id)) return;
    state = AsyncData(
      current.copyWith(
        updatingIds: Set.unmodifiable({...current.updatingIds, id}),
      ),
    );
    try {
      final response = await _useCases.updateCategory(id, request);
      final latest = state.value ?? current;
      final existing = latest.categories
          .where((category) => category.id == id)
          .firstOrNull;
      final updated = response.copyWith(itemCount: existing?.itemCount ?? 0);
      state = AsyncData(
        latest.copyWith(
          categories: [
            for (final category in latest.categories)
              if (category.id == id) updated else category,
          ],
          updatingIds: Set.unmodifiable(
            latest.updatingIds.where((value) => value != id),
          ),
        ),
      );
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

  Future<void> deleteCategory(String id) async {
    final current = state.value;
    if (current == null || current.isDeleting(id)) return;
    state = AsyncData(
      current.copyWith(
        deletingIds: Set.unmodifiable({...current.deletingIds, id}),
      ),
    );
    try {
      final deleted = await _useCases.deleteCategory(id);
      if (!deleted) throw StateError('The category was not deleted.');
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          categories: latest.categories
              .where((category) => category.id != id)
              .toList(growable: false),
          deletingIds: Set.unmodifiable(
            latest.deletingIds.where((value) => value != id),
          ),
        ),
      );
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
