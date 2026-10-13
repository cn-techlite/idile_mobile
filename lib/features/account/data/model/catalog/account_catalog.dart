import 'package:idile_mobile_app/features/account/data/model/categories/category.dart';
import 'package:idile_mobile_app/features/account/data/model/currencies/currency.dart';
import 'package:idile_mobile_app/features/account/data/model/spaces/space.dart';

/// Account-owned reference data used by other features when creating items.
class Catalog {
  const Catalog({
    this.spaces = const [],
    this.categories = const [],
    this.currencies = const [],
  });

  final List<Space> spaces;
  final List<Category> categories;
  final List<Currency> currencies;
}
