import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/account/presentation/controller/account/account_controller.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/account_state.dart';

final accountControllerProvider =
    AsyncNotifierProvider<AccountController, AccountState>(
      AccountController.new,
    );
