import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/more/presentation/controller/household_items/household_item_controller.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/household_item_state.dart';

final householdItemControllerProvider =
    AsyncNotifierProvider<HouseholdItemController, HouseholdItemState>(
      HouseholdItemController.new,
    );
