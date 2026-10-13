import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/account/data/repository/account/account_repository_impl.dart';
import 'package:idile_mobile_app/features/account/data/service/account/account_remote_service.dart';
import 'package:idile_mobile_app/features/account/domain/controller/account/account_controller.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/account/account_repository.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/account_state.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_local_storage_service.dart';

final accountRemoteServiceProvider = Provider<AccountRemoteService>(
  (ref) => AccountRemoteService(ref.read(apiClientProvider)),
);

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepositoryImpl(
    ref.read(accountRemoteServiceProvider),
    AuthLocalStorageService(),
  ),
);

final accountControllerProvider =
    AsyncNotifierProvider<AccountController, AccountState>(
      AccountController.new,
    );
