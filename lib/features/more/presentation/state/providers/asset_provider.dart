import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/more/data/repository/assets/asset_repository_impl.dart';
import 'package:idile_mobile_app/features/more/data/service/assets/asset_remote_service.dart';
import 'package:idile_mobile_app/features/more/domain/controller/assets/asset_controller.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/assets/asset_repository.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/asset_state.dart';

final assetRemoteServiceProvider = Provider<AssetRemoteService>(
  (ref) => AssetRemoteService(ref.read(apiClientProvider)),
);

final assetRepositoryProvider = Provider<AssetRepository>(
  (ref) => AssetRepositoryImpl(ref.read(assetRemoteServiceProvider)),
);

final assetControllerProvider =
    AsyncNotifierProvider<AssetController, AssetState>(AssetController.new);
