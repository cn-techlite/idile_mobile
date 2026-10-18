import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/domain/entities/catalog/account_catalog.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/space_provider.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/hearth_providers.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';
import 'package:intl/intl.dart';

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.raw(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w200,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                addVerticalSpacing(0.5),
                AppText.raw(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          addVerticalSpacing(1.75),
          AppText.raw(title, style: Theme.of(context).textTheme.titleLarge),
          addVerticalSpacing(0.75),
          AppText.raw(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

class ErrorState extends StatelessWidget {
  const ErrorState({required this.error, required this.onRetry, super.key});
  final Object error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 44),
          addVerticalSpacing(1.5),
          AppText.raw('$error', textAlign: TextAlign.center),
          addVerticalSpacing(1.75),
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

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) {
    final urgent = const [
      'overdue',
      'due',
      'expiring',
    ].contains(label.toLowerCase());
    return DecoratedBox(
      decoration: BoxDecoration(
        color: urgent
            ? AppColors.signal
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: AppText.raw(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class SpaceSelector extends ConsumerWidget {
  const SpaceSelector({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(catalogControllerProvider)
      .maybeWhen(
        data: (catalog) => SizedBox(
          width: 142,
          child: GlobalSearchableDropdown<String?>(
            title: 'Space',
            hintText: 'All spaces',
            value: ref.watch(selectedSpaceProvider),
            options: [
              const SearchableDropdownOption<String?>(
                value: null,
                label: 'All spaces',
              ),
              ...catalog.spaces.map(
                (s) => SearchableDropdownOption<String?>(
                  value: s.id,
                  label: s.name,
                ),
              ),
            ],
            onChanged: ref.read(selectedSpaceProvider.notifier).select,
            showSearch: catalog.spaces.length > 5,
          ),
        ),
        orElse: () => const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
}

String money(double amount, String currencyId, Catalog? catalog) {
  var symbol = '₦';
  final currencies = catalog?.currencies;
  if (currencies != null) {
    for (final item in currencies) {
      if (item.id == currencyId) {
        symbol = item.symbol;
        break;
      }
    }
  }
  return '$symbol${NumberFormat('#,##0.00').format(amount)}';
}

String shortDate(String value) {
  final date = DateTime.tryParse(value);
  return date == null ? value : DateFormat('d MMM yyyy').format(date.toLocal());
}

Future<bool> confirmDelete(BuildContext context, String item) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText.raw('Remove item?'),
        content: AppText.raw('$item will be permanently removed.'),
        actions: [
          AppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            variant: AppButtonVariant.text,
            compact: true,
          ),
          AppButton(
            text: 'Remove',
            onPressed: () => Navigator.pop(context, true),
            compact: true,
          ),
        ],
      ),
    ) ??
    false;

void showFailure(BuildContext context, Object error) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: AppText.raw('$error')));
}
