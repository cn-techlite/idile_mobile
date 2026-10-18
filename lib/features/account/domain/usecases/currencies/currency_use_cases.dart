import 'package:idile_mobile_app/features/account/domain/entities/currencies/currency.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/currencies/create_currency_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/currencies/update_currency_request.dart';
import 'package:idile_mobile_app/features/account/domain/repositories/currencies/currency_repository.dart';

final class CurrencyUseCases {
  const CurrencyUseCases(this._repository);

  final CurrencyRepository _repository;

  Future<List<Currency>> currencies() => _repository.currencies();

  Future<Currency> createCurrency(CreateCurrencyRequest request) =>
      _repository.createCurrency(request);

  Future<Currency> updateCurrency(
    String currencyId,
    UpdateCurrencyRequest request,
  ) => _repository.updateCurrency(currencyId, request);

  Future<bool> deleteCurrency(String currencyId) =>
      _repository.deleteCurrency(currencyId);
}
