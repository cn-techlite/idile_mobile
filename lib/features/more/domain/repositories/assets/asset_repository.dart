import 'package:idile_mobile_app/features/more/domain/parameters/assets/create_asset_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/assets/get_assets_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/assets/update_asset_request.dart';
import 'package:idile_mobile_app/features/more/domain/entities/assets/asset_item.dart';

abstract interface class AssetRepository {
  Future<AssetPage> assets(GetAssetsRequest request);
  Future<AssetItem> asset(String assetId);
  Future<AssetItem> createAsset(CreateAssetRequest request);
  Future<AssetItem> updateAsset(String assetId, UpdateAssetRequest request);
  Future<bool> deleteAsset(String assetId);
}
