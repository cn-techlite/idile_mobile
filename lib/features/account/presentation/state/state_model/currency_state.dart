import 'package:idile_mobile_app/features/account/data/model/currencies/currency.dart';

class CurrencyState {
  const CurrencyState({
    this.currencies = const [],
    this.isRefreshing = false,
    this.isCreating = false,
    this.updatingIds = const {},
    this.deletingIds = const {},
  });

  final List<Currency> currencies;
  final bool isRefreshing;
  final bool isCreating;
  final Set<String> updatingIds;
  final Set<String> deletingIds;

  bool isUpdating(String id) => updatingIds.contains(id);
  bool isDeleting(String id) => deletingIds.contains(id);

  CurrencyState copyWith({
    List<Currency>? currencies,
    bool? isRefreshing,
    bool? isCreating,
    Set<String>? updatingIds,
    Set<String>? deletingIds,
  }) => CurrencyState(
    currencies: currencies ?? this.currencies,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isCreating: isCreating ?? this.isCreating,
    updatingIds: updatingIds ?? this.updatingIds,
    deletingIds: deletingIds ?? this.deletingIds,
  );
}
