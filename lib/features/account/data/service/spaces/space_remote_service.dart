import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/spaces/create_space_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/spaces/update_space_request.dart';
import 'package:idile_mobile_app/features/account/domain/entities/spaces/space.dart';

class SpaceRemoteService {
  const SpaceRemoteService(this._api);

  final ApiClient _api;

  Future<List<Space>> spaces() => _api.get(
    Endpoints.spacesUrl,
    (value) => (value as List)
        .map((item) => Space.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false),
  );

  Future<Space> createSpace(CreateSpaceRequest request) => _api.post(
    Endpoints.spacesUrl,
    (value) => Space.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<Space> updateSpace(String spaceId, UpdateSpaceRequest request) =>
      _api.patch(
        Endpoints.spaceUrl(_validId(spaceId)),
        (value) => Space.fromJson(Map<String, dynamic>.from(value as Map)),
        body: request.toJson(),
      );

  Future<SpaceSummary> summary(String spaceId) => _api.get(
    Endpoints.spaceSummaryUrl(_validId(spaceId)),
    (value) => SpaceSummary.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<bool> deleteSpace(String spaceId) => _api.delete(
    Endpoints.spaceUrl(_validId(spaceId)),
    (value) => value is Map && value['deleted'] == true,
  );

  String _validId(String value) {
    final id = value.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(value, 'spaceId', 'Space id cannot be empty.');
    }
    return id;
  }
}
