import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/more/presentation/controller/assets/asset_controller.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/asset_state.dart';

final assetControllerProvider =
    AsyncNotifierProvider<AssetController, AssetState>(AssetController.new);
