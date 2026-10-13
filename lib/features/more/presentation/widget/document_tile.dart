import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/features/more/data/model/documents/document_item.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';

class DocumentTile extends StatelessWidget {
  const DocumentTile({
    required this.document,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenFile,
    this.isUpdating = false,
    this.isDeleting = false,
    super.key,
  });

  final DocumentItem document;
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
              const CircleAvatar(child: Icon(Icons.description_outlined)),
              addHorizontalSpacing(3),
              Expanded(
                child: AppText.raw(
                  document.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusPill(document.status),
            ],
          ),
          addVerticalSpacing(1),
          AppText.raw(document.type),
          if (document.related.isNotEmpty)
            AppText.raw(
              document.related,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          AppText.raw(
            document.expiry.isEmpty
                ? 'No expiry'
                : 'Expires ${shortDate(document.expiry)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (document.householdItemId.isNotEmpty)
            AppText.raw(
              'Household item: ${document.householdItemId}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          if (document.assetId.isNotEmpty)
            AppText.raw(
              'Asset: ${document.assetId}',
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
