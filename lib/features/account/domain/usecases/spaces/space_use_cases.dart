import 'package:idile_mobile_app/features/account/domain/entities/spaces/space.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/spaces/create_space_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/spaces/update_space_request.dart';
import 'package:idile_mobile_app/features/account/domain/repositories/spaces/space_repository.dart';

final class SpaceUseCases {
  const SpaceUseCases(this._repository);

  final SpaceRepository _repository;

  Future<List<Space>> spaces() => _repository.spaces();

  Future<Space> createSpace(CreateSpaceRequest request) =>
      _repository.createSpace(request);

  Future<Space> updateSpace(String spaceId, UpdateSpaceRequest request) =>
      _repository.updateSpace(spaceId, request);

  Future<SpaceSummary> summary(String spaceId) => _repository.summary(spaceId);

  Future<bool> deleteSpace(String spaceId) => _repository.deleteSpace(spaceId);
}
