import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/data/model/spaces/space.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/space_provider.dart';
import 'package:idile_mobile_app/features/account/presentation/widget/space_tile.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:intl/intl.dart';

class SpaceSummaryPage extends ConsumerWidget {
  const SpaceSummaryPage({super.key, required this.space});

  final Space space;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(spaceSummaryProvider(space.id));
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: AppText(
          text: space.name,
          type: AppTextType.titleLarge,
          fontWeight: FontWeight.w800,
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh summary',
            onPressed: () => ref.invalidate(spaceSummaryProvider(space.id)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(text: error.toString(), textAlign: TextAlign.center),
                addVerticalSpacing(1.75),
                AppButton(
                  text: 'Try again',
                  onPressed: () =>
                      ref.invalidate(spaceSummaryProvider(space.id)),
                  icon: const Icon(Icons.refresh),
                  variant: AppButtonVariant.outlined,
                  compact: true,
                ),
              ],
            ),
          ),
        ),
        data: (value) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(spaceSummaryProvider(space.id));
            await ref.read(spaceSummaryProvider(space.id).future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.signal.withValues(alpha: .22),
                    child: Icon(
                      spaceIconData(space.icon),
                      color: AppColors.ink,
                    ),
                  ),
                  title: AppText(text: space.name, fontWeight: FontWeight.w700),
                  subtitle: AppText(
                    text:
                        '${value.counts['total'] ?? space.itemCount} total items',
                  ),
                ),
              ),
              addVerticalSpacing(1.75),
              const AppText(
                text: 'Overview',
                type: AppTextType.titleMedium,
                fontWeight: FontWeight.w700,
              ),
              addVerticalSpacing(1),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: value.counts.entries
                    .where((entry) => entry.key != 'total')
                    .length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, index) {
                  final entry = value.counts.entries
                      .where((item) => item.key != 'total')
                      .elementAt(index);
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            text: '${entry.value}',
                            type: AppTextType.titleLarge,
                            fontWeight: FontWeight.w800,
                          ),
                          AppText(
                            text: _label(entry.key),
                            type: AppTextType.bodySmall,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (value.spendByCurrency.isNotEmpty) ...[
                addVerticalSpacing(2.25),
                const AppText(
                  text: 'Unpaid spend',
                  type: AppTextType.titleMedium,
                  fontWeight: FontWeight.w700,
                ),
                addVerticalSpacing(1),
                Card(
                  child: Column(
                    children: value.spendByCurrency
                        .map(
                          (spend) => ListTile(
                            leading: const Icon(Icons.payments_outlined),
                            title: AppText(
                              text: NumberFormat('#,##0.00')
                                  .format(spend.total),
                              fontWeight: FontWeight.w700,
                            ),
                            subtitle: AppText(text: spend.currencyId),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
              ...value.attention.sections
                  .where((section) => section.items.isNotEmpty)
                  .expand(
                    (section) => [
                      addVerticalSpacing(2.25),
                      AppText(
                        text: '${section.label} needing attention',
                        type: AppTextType.titleMedium,
                        fontWeight: FontWeight.w700,
                      ),
                      addVerticalSpacing(1),
                      Card(
                        child: Column(
                          children: section.items
                              .map(
                                (item) => ListTile(
                                  title: AppText(
                                    text: item.title,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  subtitle: item.status.isEmpty
                                      ? null
                                      : AppText(text: _label(item.status)),
                                ),
                              )
                              .toList(),
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
}

String _label(String value) {
  final spaced = value.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (match) => '${match[1]} ${match[2]}',
  );
  return spaced.isEmpty
      ? spaced
      : '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}
