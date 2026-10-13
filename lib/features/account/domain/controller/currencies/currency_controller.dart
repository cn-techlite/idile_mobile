import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/account/data/dto/currencies/create_currency_request.dart';
import 'package:idile_mobile_app/features/account/data/dto/currencies/update_currency_request.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/currencies/currency_repository.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/currency_provider.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/currency_state.dart';

class CurrencyController extends AsyncNotifier<CurrencyState> {
  CurrencyRepository get _repository => ref.read(currencyRepositoryProvider);

  @override
  FutureOr<CurrencyState> build() => _load();

  Future<CurrencyState> _load() async =>
      CurrencyState(currencies: await _repository.currencies());

  Future<void> refreshCurrencies() async {
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

  Future<void> createCurrency(CreateCurrencyRequest request) async {
    final current = state.value ?? const CurrencyState();
    if (current.isCreating) return;
    state = AsyncData(current.copyWith(isCreating: true));
    try {
      final created = await _repository.createCurrency(request);
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          currencies: [...latest.currencies, created],
          isCreating: false,
        ),
      );
    } catch (error) {
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(isCreating: false));
      rethrow;
    }
  }

  Future<void> updateCurrency(String id, UpdateCurrencyRequest request) async {
    final current = state.value;
    if (current == null || current.isUpdating(id)) return;
    state = AsyncData(
      current.copyWith(
        updatingIds: Set.unmodifiable({...current.updatingIds, id}),
      ),
    );
    try {
      final response = await _repository.updateCurrency(id, request);
      final latest = state.value ?? current;
      final existing = latest.currencies
          .where((currency) => currency.id == id)
          .firstOrNull;
      final updated = response.copyWith(itemCount: existing?.itemCount ?? 0);
      state = AsyncData(
        latest.copyWith(
          currencies: [
            for (final currency in latest.currencies)
              if (currency.id == id) updated else currency,
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

  Future<void> deleteCurrency(String id) async {
    final current = state.value;
    if (current == null || current.isDeleting(id)) return;
    state = AsyncData(
      current.copyWith(
        deletingIds: Set.unmodifiable({...current.deletingIds, id}),
      ),
    );
    try {
      final deleted = await _repository.deleteCurrency(id);
      if (!deleted) throw StateError('The currency was not deleted.');
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          currencies: latest.currencies
              .where((currency) => currency.id != id)
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
