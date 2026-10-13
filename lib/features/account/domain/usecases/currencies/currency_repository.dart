import 'package:idile_mobile_app/features/account/data/dto/currencies/create_currency_request.dart';
import 'package:idile_mobile_app/features/account/data/dto/currencies/update_currency_request.dart';
import 'package:idile_mobile_app/features/account/data/model/currencies/currency.dart';

abstract interface class CurrencyRepository {
  Future<List<Currency>> currencies();
  Future<Currency> createCurrency(CreateCurrencyRequest request);
  Future<Currency> updateCurrency(
    String currencyId,
    UpdateCurrencyRequest request,
  );
  Future<bool> deleteCurrency(String currencyId);
}
