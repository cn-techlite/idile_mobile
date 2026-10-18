import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/features/more/domain/entities/maintenance/maintenance_task.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';

class MaintenanceTaskTile extends StatelessWidget {
  const MaintenanceTaskTile({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkDone,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isCompleting = false,
    super.key,
  });

  final MaintenanceTask task;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkDone;
  final bool isUpdating;
  final bool isDeleting;
  final bool isCompleting;

  bool get _isBusy => isUpdating || isDeleting || isCompleting;

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
                child: AppText.raw(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusPill(task.status),
            ],
          ),
          addVerticalSpacing(0.75),
          AppText.raw(
            '${task.item} · every ${task.intervalMonths} month${task.intervalMonths == 1 ? '' : 's'}',
          ),
          AppText.raw(
            'Last done ${shortDate(task.lastDone)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          AppText.raw(
            'Next due ${shortDate(task.nextDue)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              AppButton(
                text: 'Mark done',
                onPressed: _isBusy ? null : onMarkDone,
                icon: const Icon(Icons.check),
                isLoading: isCompleting,
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
