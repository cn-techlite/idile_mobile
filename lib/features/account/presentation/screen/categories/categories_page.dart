import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/categories/create_category_request.dart';
import 'package:idile_mobile_app/features/account/domain/parameters/categories/update_category_request.dart';
import 'package:idile_mobile_app/features/account/domain/entities/categories/category.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/category_provider.dart';
import 'package:idile_mobile_app/features/account/presentation/widget/category_tile.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryControllerProvider);
    final value = categories.value;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const AppText(
          text: 'Categories',
          type: AppTextType.titleLarge,
          fontWeight: FontWeight.w800,
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh categories',
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
        heroTag: 'create-category',
        onPressed: value?.isCreating == true
            ? null
            : () => _create(context, ref),
        icon: value?.isCreating == true
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: const AppText(text: 'New category'),
      ),
      body: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _CategoryError(
          message: error.toString(),
          onRetry: () => ref.invalidate(categoryControllerProvider),
        ),
        data: (state) => RefreshIndicator(
          onRefresh: () => _refresh(context, ref),
          child: state.categories.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 120, 24, 100),
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 58,
                      color: colors.onSurfaceVariant,
                    ),
                    addVerticalSpacing(2),
                    AppText(
                      text: 'Create your first category',
                      type: AppTextType.titleMedium,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w700,
                    ),
                    addVerticalSpacing(0.875),
                    AppText(
                      text:
                          'Categories make bills easier to organise and find.',
                      textAlign: TextAlign.center,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return CategoryTile(
                      category: category,
                      isUpdating: state.isUpdating(category.id),
                      isDeleting: state.isDeleting(category.id),
                      onEdit: () => _rename(context, ref, category),
                      onDelete: () => _delete(context, ref, category),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(categoryControllerProvider.notifier).refreshCategories();
    } catch (error) {
      if (context.mounted) _showFailure(context, error);
    }
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = await _showNameDialog(context, title: 'Create category');
    if (name == null || !context.mounted) return;
    try {
      await ref
          .read(categoryControllerProvider.notifier)
          .createCategory(CreateCategoryRequest(name: name));
    } catch (error) {
      if (context.mounted) _showFailure(context, error);
    }
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final name = await _showNameDialog(
      context,
      title: 'Rename category',
      initialName: category.name,
      warning: category.itemCount > 0
          ? 'Existing bills using “${category.name}” will keep their current label.'
          : null,
    );
    if (name == null || !context.mounted) return;
    try {
      await ref
          .read(categoryControllerProvider.notifier)
          .updateCategory(category.id, UpdateCategoryRequest(name: name));
    } catch (error) {
      if (context.mounted) _showFailure(context, error);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText(
          text: 'Delete this category?',
          type: AppTextType.titleLarge,
          fontWeight: FontWeight.w700,
        ),
        content: AppText(
          text: category.itemCount == 0
              ? '${category.name} will be permanently removed.'
              : '${category.itemCount} bills currently use “${category.name}”. Their saved category names will remain after this category is deleted.',
        ),
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
      await ref
          .read(categoryControllerProvider.notifier)
          .deleteCategory(category.id);
    } catch (error) {
      if (context.mounted) _showFailure(context, error);
    }
  }

  Future<String?> _showNameDialog(
    BuildContext context, {
    required String title,
    String? initialName,
    String? warning,
  }) async {
    final controller = TextEditingController(text: initialName);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppText(
          text: title,
          type: AppTextType.titleLarge,
          fontWeight: FontWeight.w700,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlobalTextField(
              fieldName: 'Category name',
              keyBoardType: TextInputType.name,
              textController: controller,
              textInputAction: TextInputAction.done,
            ),
            if (warning != null) ...[
              addVerticalSpacing(1.5),
              AppText(
                text: warning,
                type: AppTextType.bodySmall,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
        actions: [
          AppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(dialogContext),
            variant: AppButtonVariant.text,
            compact: true,
          ),
          AppButton(
            text: 'Save',
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) Navigator.pop(dialogContext, name);
            },
            compact: true,
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  void _showFailure(BuildContext context, Object error) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppText(
            text: 'Unable to update categories: $error',
            color: AppColors.white,
          ),
        ),
      );
  }
}

class _CategoryError extends StatelessWidget {
  const _CategoryError({required this.message, required this.onRetry});

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
