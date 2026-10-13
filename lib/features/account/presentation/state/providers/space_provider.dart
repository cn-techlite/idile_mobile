import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/account/data/model/spaces/space.dart';
import 'package:idile_mobile_app/features/account/data/repository/spaces/space_repository_impl.dart';
import 'package:idile_mobile_app/features/account/data/service/spaces/space_remote_service.dart';
import 'package:idile_mobile_app/features/account/domain/controller/spaces/space_controller.dart';
import 'package:idile_mobile_app/features/account/domain/usecases/spaces/space_repository.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/space_state.dart';

final spaceRemoteServiceProvider = Provider<SpaceRemoteService>(
  (ref) => SpaceRemoteService(ref.read(apiClientProvider)),
);

final spaceRepositoryProvider = Provider<SpaceRepository>(
  (ref) => SpaceRepositoryImpl(ref.read(spaceRemoteServiceProvider)),
);

final selectedSpaceProvider =
    NotifierProvider<SelectedSpaceController, String?>(
      SelectedSpaceController.new,
    );

final spaceControllerProvider =
    AsyncNotifierProvider<SpaceController, SpaceState>(SpaceController.new);

final spaceSummaryProvider = FutureProvider.family<SpaceSummary, String>(
  (ref, id) => ref.read(spaceRepositoryProvider).summary(id),
);

final selectedSpaceSummaryProvider = FutureProvider<SpaceSummary?>((ref) {
  final id = ref.watch(selectedSpaceProvider);
  return id == null ? null : ref.read(spaceRepositoryProvider).summary(id);
});
