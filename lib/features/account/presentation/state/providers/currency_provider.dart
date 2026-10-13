import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/account/data/repository/currencies/currency_repository_impl.dart';
import 'package:idile_mobile_app/features/account/data/service/currencies/currency_remote_service.dart';
import 'package:idile_mobile_app/features/account/domain/controller/currencies/currency_controller.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/currencies/currency_repository.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/currency_state.dart';

final currencyRemoteServiceProvider = Provider<CurrencyRemoteService>(
  (ref) => CurrencyRemoteService(ref.read(apiClientProvider)),
);

final currencyRepositoryProvider = Provider<CurrencyRepository>(
  (ref) => CurrencyRepositoryImpl(ref.read(currencyRemoteServiceProvider)),
);

final currencyControllerProvider =
    AsyncNotifierProvider<CurrencyController, CurrencyState>(
      CurrencyController.new,
    );
