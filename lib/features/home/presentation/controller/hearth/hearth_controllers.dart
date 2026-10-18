import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/app/di/repository_providers.dart';
import 'package:idile_mobile_app/features/account/domain/entities/catalog/account_catalog.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/category_provider.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/currency_provider.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/space_provider.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/category_state.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/currency_state.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/space_state.dart';
import 'package:idile_mobile_app/features/home/domain/entities/hearth/hearth_models.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/dashboard_attention_provider.dart';

class CatalogController extends AsyncNotifier<Catalog> {
  @override
  Future<Catalog> build() async {
    final results = await Future.wait<Object>([
      ref.watch(spaceControllerProvider.future),
      ref.watch(categoryControllerProvider.future),
      ref.watch(currencyControllerProvider.future),
    ]);
    final spaces = results[0] as SpaceState;
    final categories = results[1] as CategoryState;
    final currencies = results[2] as CurrencyState;
    return Catalog(
      spaces: spaces.spaces,
      categories: categories.categories,
      currencies: currencies.currencies,
    );
  }

  void refresh() => ref.invalidateSelf();
}

class WorkspaceController extends AsyncNotifier<List<WorkspaceAsset>> {
  @override
  FutureOr<List<WorkspaceAsset>> build() =>
      ref.read(hearthUseCasesProvider).assets(ref.watch(selectedSpaceProvider));
  Future<void> create(
    Map<String, String> fields, {
    List<int>? bytes,
    String? fileName,
  }) async {
    await ref
        .read(hearthUseCasesProvider)
        .createAsset(fields, bytes: bytes, fileName: fileName);
    _refresh();
  }

  Future<void> remove(String id) async {
    await ref.read(hearthUseCasesProvider).removeAsset(id);
    _refresh();
  }

  void _refresh() {
    ref.invalidateSelf();
    ref.invalidate(dashboardControllerProvider);
  }
}
