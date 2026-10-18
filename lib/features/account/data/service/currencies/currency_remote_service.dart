import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/currencies/create_currency_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/currencies/update_currency_request.dart';
import 'package:idile_mobile_app/features/account/domain/entities/currencies/currency.dart';

class CurrencyRemoteService {
  const CurrencyRemoteService(this._api);

  final ApiClient _api;

  Future<List<Currency>> currencies() => _api.get(
    Endpoints.currenciesUrl,
    (value) => (value as List)
        .map(
          (item) => Currency.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false),
  );

  Future<Currency> createCurrency(CreateCurrencyRequest request) => _api.post(
    Endpoints.currenciesUrl,
    (value) => Currency.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<Currency> updateCurrency(
    String currencyId,
    UpdateCurrencyRequest request,
  ) => _api.patch(
    Endpoints.currencyUrl(_validId(currencyId)),
    (value) => Currency.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<bool> deleteCurrency(String currencyId) => _api.delete(
    Endpoints.currencyUrl(_validId(currencyId)),
    (value) => value is Map && value['deleted'] == true,
  );

  String _validId(String value) {
    final id = value.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(
        value,
        'currencyId',
        'Currency id cannot be empty.',
      );
    }
    return id;
  }
}
