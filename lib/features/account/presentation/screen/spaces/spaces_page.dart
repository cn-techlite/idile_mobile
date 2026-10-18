import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/spaces/create_space_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/spaces/update_space_request.dart';
import 'package:idile_mobile_app/features/account/domain/entities/spaces/space.dart';
import 'package:idile_mobile_app/features/account/presentation/screen/spaces/space_summary_page.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/space_provider.dart';
import 'package:idile_mobile_app/features/account/presentation/widget/space_tile.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';

class SpacesPage extends ConsumerWidget {
  const SpacesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = ref.watch(spaceControllerProvider);
    final value = spaces.value;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const AppText(
          text: 'Spaces',
          type: AppTextType.titleLarge,
          fontWeight: FontWeight.w800,
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh spaces',
            onPressed: value?.isRefreshing == true
                ? null
                : () => _refresh(context, ref),
            icon: value?.isRefreshing == true
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'create-space',
        onPressed: value?.isCreating == true
            ? null
            : () => _create(context, ref),
        icon: value?.isCreating == true
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: const AppText(text: 'New space'),
      ),
      body: spaces.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _SpaceError(
          message: error.toString(),
          onRetry: () => ref.invalidate(spaceControllerProvider),
        ),
        data: (state) => RefreshIndicator(
          onRefresh: () => _refresh(context, ref),
          child: state.spaces.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 120, 24, 100),
                  children: [
                    Icon(
                      Icons.home_work_outlined,
                      size: 58,
                      color: colors.onSurfaceVariant,
                    ),
                    addVerticalSpacing(2),
                    AppText(
                      text: 'Create your first space',
                      type: AppTextType.titleMedium,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w700,
                    ),
                    addVerticalSpacing(0.875),
                    AppText(
                      text: 'Group bills, subscriptions, items and documents by place.',
                      textAlign: TextAlign.center,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  itemCount: state.spaces.length,
                  itemBuilder: (context, index) {
                    final space = state.spaces[index];
                    return SpaceTile(
                      space: space,
                      isUpdating: state.isUpdating(space.id),
                      isDeleting: state.isDeleting(space.id),
                      onOpen: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => SpaceSummaryPage(space: space),
                        ),
                      ),
                      onEdit: () => _edit(context, ref, space),
                      onDelete: space.itemCount == 0
                          ? () => _delete(context, ref, space)
                          : null,
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(spaceControllerProvider.notifier).refreshSpaces();
    } catch (error) {
      if (context.mounted) _showFailure(context, error);
    }
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final result = await _showSpaceForm(context);
    if (result == null || !context.mounted) return;
    try {
      await ref
          .read(spaceControllerProvider.notifier)
          .createSpace(
            CreateSpaceRequest(name: result.name, icon: result.icon),
          );
    } catch (error) {
      if (context.mounted) _showFailure(context, error);
    }
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Space space) async {
    final result = await _showSpaceForm(context, space: space);
    if (result == null || !context.mounted) return;
    try {
      await ref
          .read(spaceControllerProvider.notifier)
          .updateSpace(
            space.id,
            UpdateSpaceRequest(name: result.name, icon: result.icon),
          );
    } catch (error) {
      if (context.mounted) _showFailure(context, error);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Space space) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText(
          text: 'Delete this space?',
          type: AppTextType.titleLarge,
          fontWeight: FontWeight.w700,
        ),
        content: AppText(text: '${space.name} will be permanently removed.'),
        actions: [
          AppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(dialogContext, false),
            variant: AppButtonVariant.text,
            compact: true,
          ),
          AppButton(
            text: 'Delete',
            onPressed: () => Navigator.pop(dialogContext, true),
            compact: true,
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(spaceControllerProvider.notifier).deleteSpace(space.id);
    } catch (error) {
      if (context.mounted) _showFailure(context, error);
    }
  }

  Future<_SpaceFormResult?> _showSpaceForm(
    BuildContext context, {
    Space? space,
  }) async {
    final nameController = TextEditingController(text: space?.name);
    var icon = space?.icon ?? 'home';
    final result = await showDialog<_SpaceFormResult>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: AppText(
            text: space == null ? 'Create space' : 'Edit space',
            type: AppTextType.titleLarge,
            fontWeight: FontWeight.w700,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlobalTextField(
                  fieldName: 'Space name',
                  keyBoardType: TextInputType.name,
                  textController: nameController,
                  textInputAction: TextInputAction.done,
                ),
                addVerticalSpacing(2.25),
                const AppText(
                  text: 'Choose an icon',
                  fontWeight: FontWeight.w700,
                ),
                addVerticalSpacing(1),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _spaceIcons
                      .map(
                        (value) => ChoiceChip(
                          avatar: Icon(spaceIconData(value), size: 18),
                          label: AppText(text: _iconLabel(value)),
                          selected: icon == value,
                          onSelected: (_) => setDialogState(() => icon = value),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            AppButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext),
              variant: AppButtonVariant.text,
              compact: true,
            ),
            AppButton(
              text: space == null ? 'Create' : 'Save',
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(
                  dialogContext,
                  _SpaceFormResult(name: name, icon: icon),
                );
              },
              compact: true,
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    return result;
  }

  void _showFailure(BuildContext context, Object error) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppText(
            text: 'Unable to update spaces: $error',
            color: AppColors.white,
          ),
        ),
      );
  }
}

class _SpaceError extends StatelessWidget {
  const _SpaceError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          addVerticalSpacing(1.5),
          AppText(text: message, textAlign: TextAlign.center),
          addVerticalSpacing(2),
          AppButton(
            text: 'Try again',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            variant: AppButtonVariant.outlined,
            compact: true,
          ),
        ],
      ),
    ),
  );
}

class _SpaceFormResult {
  const _SpaceFormResult({required this.name, required this.icon});
  final String name;
  final String icon;
}

const _spaceIcons = [
  'home',
  'apartment',
  'work',
  'business',
  'family',
  'folder',
];

String _iconLabel(String value) => switch (value) {
  'work' => 'Work',
  'apartment' => 'Apartment',
  'business' => 'Business',
  'family' => 'Family',
  'folder' => 'Other',
  _ => 'Home',
};
