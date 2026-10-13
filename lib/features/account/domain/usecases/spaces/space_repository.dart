import 'package:idile_mobile_app/features/account/data/dto/spaces/create_space_request.dart';
import 'package:idile_mobile_app/features/account/data/dto/spaces/update_space_request.dart';
import 'package:idile_mobile_app/features/account/data/model/spaces/space.dart';

abstract interface class SpaceRepository {
  Future<List<Space>> spaces();
  Future<Space> createSpace(CreateSpaceRequest request);
  Future<Space> updateSpace(String spaceId, UpdateSpaceRequest request);
  Future<SpaceSummary> summary(String spaceId);
  Future<bool> deleteSpace(String spaceId);
}
