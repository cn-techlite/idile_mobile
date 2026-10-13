import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/data/model/categories/category.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isUpdating;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.signal.withValues(alpha: .22),
        foregroundColor: AppColors.ink,
        child: const Icon(Icons.category_outlined),
      ),
      title: AppText(
        text: category.name,
        type: AppTextType.titleMedium,
        fontWeight: FontWeight.w700,
      ),
      subtitle: AppText(
        text:
            '${category.itemCount} ${category.itemCount == 1 ? 'bill' : 'bills'}',
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      trailing: isUpdating || isDeleting
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : PopupMenuButton<_CategoryAction>(
              tooltip: 'Category actions',
              onSelected: (action) {
                if (action == _CategoryAction.edit) onEdit();
                if (action == _CategoryAction.delete) onDelete();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _CategoryAction.edit,
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      addHorizontalSpacing(2.5),
                      AppText(text: 'Rename'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _CategoryAction.delete,
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
    ),
  );
}

enum _CategoryAction { edit, delete }
