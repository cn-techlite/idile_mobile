import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/more/data/repository/household_items/household_item_repository_impl.dart';
import 'package:idile_mobile_app/features/more/data/service/household_items/household_item_remote_service.dart';
import 'package:idile_mobile_app/features/more/domain/controller/household_items/household_item_controller.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/household_items/household_item_repository.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/household_item_state.dart';

final householdItemRemoteServiceProvider = Provider<HouseholdItemRemoteService>(
  (ref) => HouseholdItemRemoteService(ref.read(apiClientProvider)),
);

final householdItemRepositoryProvider = Provider<HouseholdItemRepository>(
  (ref) =>
      HouseholdItemRepositoryImpl(ref.read(householdItemRemoteServiceProvider)),
);

final householdItemControllerProvider =
    AsyncNotifierProvider<HouseholdItemController, HouseholdItemState>(
      HouseholdItemController.new,
    );
