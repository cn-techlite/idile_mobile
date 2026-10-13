import 'package:idile_mobile_app/features/account/data/dto/spaces/create_space_request.dart';
import 'package:idile_mobile_app/features/account/data/dto/spaces/update_space_request.dart';
import 'package:idile_mobile_app/features/account/data/model/spaces/space.dart';
import 'package:idile_mobile_app/features/account/data/service/spaces/space_remote_service.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/spaces/space_repository.dart';

class SpaceRepositoryImpl implements SpaceRepository {
  const SpaceRepositoryImpl(this._remoteService);

  final SpaceRemoteService _remoteService;

  @override
  Future<List<Space>> spaces() => _remoteService.spaces();

  @override
  Future<Space> createSpace(CreateSpaceRequest request) =>
      _remoteService.createSpace(request);

  @override
  Future<Space> updateSpace(String spaceId, UpdateSpaceRequest request) =>
      _remoteService.updateSpace(spaceId, request);

  @override
  Future<SpaceSummary> summary(String spaceId) =>
      _remoteService.summary(spaceId);

  @override
  Future<bool> deleteSpace(String spaceId) =>
      _remoteService.deleteSpace(spaceId);
}
