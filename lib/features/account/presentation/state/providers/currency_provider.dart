import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/account/presentation/controller/currencies/currency_controller.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/currency_state.dart';

final currencyControllerProvider =
    AsyncNotifierProvider<CurrencyController, CurrencyState>(
      CurrencyController.new,
    );
