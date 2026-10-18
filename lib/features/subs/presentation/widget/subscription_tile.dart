import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/domain/entities/catalog/account_catalog.dart';
import 'package:idile_mobile_app/features/subs/domain/entities/subscriptions/subscription.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';

class SubscriptionTile extends StatelessWidget {
  const SubscriptionTile({
    required this.subscription,
    required this.catalog,
    required this.onEdit,
    required this.onDelete,
    this.isUpdating = false,
    this.isDeleting = false,
    super.key,
  });

  final SubscriptionItem subscription;
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
              Expanded(
                child: AppText(
                  text: subscription.title,
                  type: AppTextType.titleMedium,
                  fontWeight: FontWeight.w700,
                ),
              ),
              StatusPill(subscription.status),
            ],
          ),
          addVerticalSpacing(1),
          AppText(
            text:
                '${money(subscription.amount, subscription.currencyId, catalog)} / ${subscription.billing}',
            fontWeight: FontWeight.w800,
          ),
          AppText(
            text: 'Renews ${shortDate(subscription.renewal)}',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          if (subscription.warning?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: AppText(
                text: subscription.warning!,
                color: AppColors.danger,
              ),
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
