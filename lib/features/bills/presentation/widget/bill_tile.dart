import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/features/account/data/model/catalog/account_catalog.dart';
import 'package:idile_mobile_app/features/bills/data/model/bills/bill.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';

class BillTile extends StatelessWidget {
  const BillTile({
    required this.bill,
    required this.catalog,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkPaid,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isMarkingPaid = false,
    super.key,
  });

  final Bill bill;
  final Catalog? catalog;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkPaid;
  final bool isUpdating;
  final bool isDeleting;
  final bool isMarkingPaid;

  bool get _isBusy => isUpdating || isDeleting || isMarkingPaid;

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
                  text: bill.title,
                  type: AppTextType.titleMedium,
                  fontWeight: FontWeight.w700,
                ),
              ),
              StatusPill(bill.status),
            ],
          ),
          addVerticalSpacing(0.875),
          AppText(
            text:
                '${money(bill.amount, bill.currencyId, catalog)} · ${bill.recurrence}',
            fontWeight: FontWeight.w700,
          ),
          AppText(
            text: '${bill.category} · due ${shortDate(bill.due)}',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          addVerticalSpacing(1.25),
          Row(
            children: [
              if (bill.status != 'paid')
                AppButton(
                  text: 'Mark paid',
                  onPressed: _isBusy ? null : onMarkPaid,
                  icon: const Icon(Icons.check),
                  isLoading: isMarkingPaid,
                  variant: AppButtonVariant.text,
                  compact: true,
                ),
              const Spacer(),
              IconButton(
                tooltip: 'Edit',
                onPressed: _isBusy ? null : onEdit,
                icon: isUpdating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: _isBusy ? null : onDelete,
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
