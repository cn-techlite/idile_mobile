import 'package:idile_mobile_app/features/more/domain/parameters/assets/create_asset_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/assets/get_assets_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/assets/update_asset_request.dart';
import 'package:idile_mobile_app/features/more/domain/entities/assets/asset_item.dart';
import 'package:idile_mobile_app/features/more/data/service/assets/asset_remote_service.dart';
import 'package:idile_mobile_app/features/more/domain/repositories/assets/asset_repository.dart';

class AssetRepositoryImpl implements AssetRepository {
  const AssetRepositoryImpl(this._remoteService);

  final AssetRemoteService _remoteService;

  @override
  Future<AssetPage> assets(GetAssetsRequest request) =>
      _remoteService.assets(request);

  @override
  Future<AssetItem> asset(String assetId) => _remoteService.asset(assetId);

  @override
  Future<AssetItem> createAsset(CreateAssetRequest request) =>
      _remoteService.createAsset(request);

  @override
  Future<AssetItem> updateAsset(String assetId, UpdateAssetRequest request) =>
      _remoteService.updateAsset(assetId, request);

  @override
  Future<bool> deleteAsset(String assetId) =>
      _remoteService.deleteAsset(assetId);
}
