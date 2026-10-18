import 'package:idile_mobile_app/features/account/domain/entities/categories/category.dart';
import 'package:idile_mobile_app/features/account/domain/entities/currencies/currency.dart';
import 'package:idile_mobile_app/features/account/domain/entities/spaces/space.dart';

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
