import 'package:idile_mobile_app/features/more/domain/entities/assets/asset_item.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/assets/create_asset_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/assets/get_assets_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/assets/update_asset_request.dart';
import 'package:idile_mobile_app/features/more/domain/repositories/assets/asset_repository.dart';

final class AssetUseCases {
  const AssetUseCases(this._repository);

  final AssetRepository _repository;

  Future<AssetPage> assets(GetAssetsRequest request) =>
      _repository.assets(request);

  Future<AssetItem> asset(String assetId) => _repository.asset(assetId);

  Future<AssetItem> createAsset(CreateAssetRequest request) =>
      _repository.createAsset(request);

  Future<AssetItem> updateAsset(String assetId, UpdateAssetRequest request) =>
      _repository.updateAsset(assetId, request);

  Future<bool> deleteAsset(String assetId) => _repository.deleteAsset(assetId);
}
