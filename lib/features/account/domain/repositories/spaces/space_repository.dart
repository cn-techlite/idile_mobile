import 'package:idile_mobile_app/features/account/domain/parameters/spaces/create_space_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/spaces/update_space_request.dart';
import 'package:idile_mobile_app/features/account/domain/entities/spaces/space.dart';

abstract interface class SpaceRepository {
  Future<List<Space>> spaces();
  Future<Space> createSpace(CreateSpaceRequest request);
  Future<Space> updateSpace(String spaceId, UpdateSpaceRequest request);
  Future<SpaceSummary> summary(String spaceId);
  Future<bool> deleteSpace(String spaceId);
}
