import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/features/account/domain/entities/catalog/account_catalog.dart';
import 'package:idile_mobile_app/features/more/domain/entities/household_items/household_item.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';

class HouseholdItemTile extends StatelessWidget {
  const HouseholdItemTile({
    required this.item,
    required this.catalog,
    required this.onEdit,
    required this.onDelete,
    this.isUpdating = false,
    this.isDeleting = false,
    super.key,
  });

  final HouseholdItem item;
  final Catalog? catalog;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
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
              const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
              addHorizontalSpacing(3),
              Expanded(
                child: AppText(
                  text: item.title,
                  type: AppTextType.titleMedium,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          addVerticalSpacing(1),
          AppText(
            text: money(item.value, item.currencyId, catalog),
            fontWeight: FontWeight.w800,
          ),
          AppText(
            text: item.room,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          AppText(
            text: 'Purchased ${shortDate(item.purchased)}',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          AppText(
            text: 'Warranty ${shortDate(item.warranty)}',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
          ),
        ],
      ),
    ),
  );
}
