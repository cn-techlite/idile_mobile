import 'package:idile_mobile_app/features/account/domain/entities/spaces/space.dart';

class SpaceState {
  const SpaceState({
    this.spaces = const [],
    this.isRefreshing = false,
    this.isCreating = false,
    this.updatingIds = const {},
    this.deletingIds = const {},
  });

  final List<Space> spaces;
  final bool isRefreshing;
  final bool isCreating;
  final Set<String> updatingIds;
  final Set<String> deletingIds;

  bool isUpdating(String id) => updatingIds.contains(id);
  bool isDeleting(String id) => deletingIds.contains(id);

  SpaceState copyWith({
    List<Space>? spaces,
    bool? isRefreshing,
    bool? isCreating,
    Set<String>? updatingIds,
    Set<String>? deletingIds,
  }) => SpaceState(
    spaces: spaces ?? this.spaces,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isCreating: isCreating ?? this.isCreating,
    updatingIds: updatingIds ?? this.updatingIds,
    deletingIds: deletingIds ?? this.deletingIds,
  );
}
