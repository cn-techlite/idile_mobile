import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/app/di/repository_providers.dart';
import 'package:idile_mobile_app/features/account/domain/entities/spaces/space.dart';
import 'package:idile_mobile_app/features/account/presentation/controller/spaces/space_controller.dart';
import 'package:idile_mobile_app/features/account/presentation/state/state_model/space_state.dart';

final selectedSpaceProvider =
    NotifierProvider<SelectedSpaceController, String?>(
      SelectedSpaceController.new,
    );

final spaceControllerProvider =
    AsyncNotifierProvider<SpaceController, SpaceState>(SpaceController.new);

final spaceSummaryProvider = FutureProvider.family<SpaceSummary, String>(
  (ref, id) => ref.read(spaceUseCasesProvider).summary(id),
);

final selectedSpaceSummaryProvider = FutureProvider<SpaceSummary?>((ref) {
  final id = ref.watch(selectedSpaceProvider);
  return id == null ? null : ref.read(spaceUseCasesProvider).summary(id);
});
