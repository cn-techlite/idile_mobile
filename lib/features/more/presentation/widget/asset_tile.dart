import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/features/more/domain/entities/assets/asset_item.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';

class AssetTile extends StatelessWidget {
  const AssetTile({
    required this.asset,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenFile,
    this.isUpdating = false,
    this.isDeleting = false,
    super.key,
  });

  final AssetItem asset;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onOpenFile;
  final bool isUpdating;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Icon(
                  asset.type == 'Hardware'
                      ? Icons.devices_other
                      : Icons.key_outlined,
                ),
              ),
              addHorizontalSpacing(3),
              Expanded(
                child: AppText.raw(
                  asset.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusPill(asset.status),
            ],
          ),
          addVerticalSpacing(1),
          AppText.raw(asset.type),
          AppText.raw(
            asset.detail,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          AppText.raw(
            'Renewal ${shortDate(asset.renewal)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              if (onOpenFile != null)
                AppButton(
                  text: 'Open attachment',
                  onPressed: isUpdating || isDeleting ? null : onOpenFile,
                  icon: const Icon(Icons.attach_file),
                  variant: AppButtonVariant.text,
                  compact: true,
                ),
              const Spacer(),
              IconButton(
                tooltip: 'Edit',
                onPressed: isUpdating || isDeleting ? null : onEdit,
                icon: isUpdating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: isUpdating || isDeleting ? null : onDelete,
                icon: isDeleting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
