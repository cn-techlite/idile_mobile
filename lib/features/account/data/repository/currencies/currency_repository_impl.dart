import 'package:idile_mobile_app/features/account/data/dto/currencies/create_currency_request.dart';
import 'package:idile_mobile_app/features/account/data/dto/currencies/update_currency_request.dart';
import 'package:idile_mobile_app/features/account/data/model/currencies/currency.dart';
import 'package:idile_mobile_app/features/account/data/service/currencies/currency_remote_service.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/currencies/currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  const CurrencyRepositoryImpl(this._remoteService);

  final CurrencyRemoteService _remoteService;

  @override
  Future<List<Currency>> currencies() => _remoteService.currencies();

  @override
  Future<Currency> createCurrency(CreateCurrencyRequest request) =>
      _remoteService.createCurrency(request);

  @override
  Future<Currency> updateCurrency(
    String currencyId,
    UpdateCurrencyRequest request,
  ) => _remoteService.updateCurrency(currencyId, request);

  @override
  Future<bool> deleteCurrency(String currencyId) =>
      _remoteService.deleteCurrency(currencyId);
}
