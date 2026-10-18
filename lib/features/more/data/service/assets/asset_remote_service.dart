import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/assets/create_asset_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/assets/get_assets_request.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/assets/update_asset_request.dart';
import 'package:idile_mobile_app/features/more/domain/entities/assets/asset_item.dart';

class AssetRemoteService {
  const AssetRemoteService(this._api);

  final ApiClient _api;

  Future<AssetPage> assets(GetAssetsRequest request) {
    final uri = Uri(
      path: Endpoints.assetsUrl,
      queryParameters: request.toQueryParameters(),
    );
    return _api.getEnvelope(
      uri.toString(),
      (value) =>
          AssetPage.fromEnvelope(Map<String, dynamic>.from(value as Map)),
    );
  }

  Future<AssetItem> asset(String assetId) => _api.get(
    Endpoints.assetUrl(_validId(assetId)),
    (value) => AssetItem.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<AssetItem> createAsset(CreateAssetRequest request) => _api.multipart(
    Endpoints.assetsUrl,
    (value) => AssetItem.fromJson(Map<String, dynamic>.from(value as Map)),
    fields: request.toFields(),
    fileBytes: request.fileBytes,
    fileName: request.fileName?.trim(),
  );

  Future<AssetItem> updateAsset(String assetId, UpdateAssetRequest request) =>
      _api.patch(
        Endpoints.assetUrl(_validId(assetId)),
        (value) => AssetItem.fromJson(Map<String, dynamic>.from(value as Map)),
        body: request.toJson(),
      );

  Future<bool> deleteAsset(String assetId) => _api.delete(
    Endpoints.assetUrl(_validId(assetId)),
    (value) => value is Map && value['deleted'] == true,
  );

  String _validId(String value) {
    final id = value.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(value, 'assetId', 'Asset id cannot be empty.');
    }
    return id;
  }
}
