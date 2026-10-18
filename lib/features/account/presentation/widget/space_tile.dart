import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/domain/entities/spaces/space.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';

class SpaceTile extends StatelessWidget {
  const SpaceTile({
    super.key,
    required this.space,
    required this.onOpen,
    required this.onEdit,
    this.onDelete,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  final Space space;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool isUpdating;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.signal.withValues(alpha: .22),
              foregroundColor: AppColors.ink,
              child: Icon(spaceIconData(space.icon)),
            ),
            addHorizontalSpacing(3.25),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: space.name,
                    type: AppTextType.titleMedium,
                    fontWeight: FontWeight.w700,
                  ),
                  addVerticalSpacing(0.375),
                  AppText(
                    text:
                        '${space.itemCount} ${space.itemCount == 1 ? 'item' : 'items'}',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  if (space.itemCount > 0)
                    AppText(
                      text: 'Remove its items before deleting this space.',
                      type: AppTextType.bodySmall,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
            if (isUpdating || isDeleting)
              const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              PopupMenuButton<_SpaceAction>(
                tooltip: 'Space actions',
                onSelected: (action) {
                  if (action == _SpaceAction.edit) onEdit();
                  if (action == _SpaceAction.delete) onDelete?.call();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _SpaceAction.edit,
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        addHorizontalSpacing(2.5),
                        AppText(text: 'Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _SpaceAction.delete,
                    enabled: onDelete != null,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppColors.danger),
                        addHorizontalSpacing(2.5),
                        AppText(text: 'Delete', color: AppColors.danger),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

enum _SpaceAction { edit, delete }

IconData spaceIconData(String icon) => switch (icon.toLowerCase()) {
  'work' || 'workspace' => Icons.work_outline,
  'apartment' => Icons.apartment,
  'business' => Icons.business_outlined,
  'family' || 'household' => Icons.family_restroom,
  'folder' => Icons.folder_outlined,
  _ => Icons.home_outlined,
};
