import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/features/account/data/model/catalog/account_catalog.dart';
import 'package:idile_mobile_app/features/account/data/model/spaces/space.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/account_provider.dart';
import 'package:idile_mobile_app/features/account/presentation/state/providers/space_provider.dart';
import 'package:idile_mobile_app/features/bills/data/model/bills/bill.dart';
import 'package:idile_mobile_app/features/bills/presentation/state/providers/bill_provider.dart';
import 'package:idile_mobile_app/features/home/data/model/dashboard/dashboard_attention.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/dashboard_attention_provider.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/hearth_providers.dart';
import 'package:idile_mobile_app/features/home/presentation/widget/dashboard/home_empty_state.dart';
import 'package:idile_mobile_app/features/more/presentation/screen/calendar/calendar_page.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';
import 'package:intl/intl.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(accountControllerProvider).value?.profile;
    final dashboard = ref.watch(dashboardControllerProvider);
    final catalog = ref.watch(catalogControllerProvider).value;
    final summary = ref.watch(selectedSpaceSummaryProvider).value;
    final selectedSpaceId = ref.watch(selectedSpaceProvider);
    final billState = ref.watch(billControllerProvider).value;
    final refresh = ref
        .read(dashboardControllerProvider.notifier)
        .refreshAttention;

    return dashboard.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorState(
        error: error,
        onRetry: () => ref.invalidate(dashboardControllerProvider),
      ),
      data: (dashboardState) {
        final attention = _attentionForSpace(
          dashboardState.attention,
          selectedSpaceId,
        );
        if (_hasNoHomeData(
          attentionTotal: attention.total,
          spaces: catalog?.spaces,
          summary: summary,
        )) {
          return HomeEmptyState(name: profile?.name ?? '', onRefresh: refresh);
        }

        final datedItems = _datedItems(attention);
        final weekItems = _thisWeekItems(datedItems);
        final nextThirtyDays = _nextThirtyDays(datedItems);
        final primaryCurrencyId = _primaryCurrencyId(attention);

        return RefreshIndicator(
          onRefresh: () async {
            await refresh();
            ref.invalidate(selectedSpaceSummaryProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 124),
                sliver: SliverList.list(
                  children: [
                    _DashboardGreeting(
                      name: _displayName(profile?.name),
                      now: DateTime.now(),
                    ),
                    addVerticalSpacing(2.5),
                    _AttentionOverview(
                      total: attention.total,
                      thisWeek: weekItems.length,
                      toPay: money(
                        _toPayThisWeek(attention, primaryCurrencyId),
                        primaryCurrencyId,
                        catalog,
                      ),
                      monthlyCommitments: money(
                        _monthlyCommitments(attention, primaryCurrencyId),
                        primaryCurrencyId,
                        catalog,
                      ),
                    ),
                    addVerticalSpacing(3),
                    _SectionTitle(title: 'THIS WEEK', count: weekItems.length),
                    addVerticalSpacing(1.25),
                    if (weekItems.isEmpty)
                      const _DashboardPanel(
                        child: _EmptyDashboardSection(
                          icon: Icons.event_available_outlined,
                          message: 'Nothing needs action this week.',
                        ),
                      )
                    else
                      for (final item in weekItems.take(3)) ...[
                        _WeekActionCard(
                          item: item,
                          catalog: catalog,
                          isLoading:
                              item.bill != null &&
                              billState?.isMarkingPaid(item.bill!.id) == true,
                          onMarkPaid: item.bill == null
                              ? null
                              : () => _markPaid(context, ref, item.bill!),
                        ),
                        addVerticalSpacing(1.5),
                      ],
                    addVerticalSpacing(1.25),
                    _SpendingBreakdown(
                      attention: attention,
                      currencyId: primaryCurrencyId,
                      catalog: catalog,
                    ),
                    addVerticalSpacing(2),
                    _TimelinePanel(
                      items: nextThirtyDays,
                      onOpenCalendar: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CalendarPage(),
                        ),
                      ),
                    ),
                    addVerticalSpacing(2),
                    _SummaryGrid(
                      bills: _summaryCount(summary, const [
                        'bills',
                      ], attention.bills.length),
                      subscriptions: _summaryCount(summary, const [
                        'subscriptions',
                        'subscription',
                      ], attention.subscriptions.length),
                      maintenance: _summaryCount(summary, const [
                        'maintenance',
                      ], attention.maintenance.length),
                      documents: _summaryCount(summary, const [
                        'documents',
                        'document',
                      ], attention.documents.length),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _markPaid(BuildContext context, WidgetRef ref, Bill bill) async {
    try {
      await ref.read(billControllerProvider.notifier).markPaid(bill.id);
    } catch (error) {
      if (context.mounted) showFailure(context, error);
    }
  }
}

class _DashboardGreeting extends StatelessWidget {
  const _DashboardGreeting({required this.name, required this.now});

  final String name;
  final DateTime now;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText.raw(
        'Good ${_greeting()}, $name',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(fontSize: 26, height: 1.05, fontWeight: FontWeight.w800),
      ),
      addVerticalSpacing(0.75),
      AppText.raw(
        DateFormat('EEEE d MMMM').format(now),
        style: Theme.of(context).textTheme.bodyLarge
            ?.copyWith(color: _mutedColor(context)),
      ),
    ],
  );
}

class _AttentionOverview extends StatelessWidget {
  const _AttentionOverview({
    required this.total,
    required this.thisWeek,
    required this.toPay,
    required this.monthlyCommitments,
  });

  final int total;
  final int thisWeek;
  final String toPay;
  final String monthlyCommitments;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final panel = dark ? AppColors.surfaceDark : AppColors.white;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: panel,
          border: Border.all(color: _borderColor(context)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              color: AppColors.signal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText.raw(
                          'NEEDS ATTENTION',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontFamily: 'Open Serif',
                            fontSize: 20,
                            height: 0.9,
                            letterSpacing: -1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        addVerticalSpacing(1.5),
                        AppText.raw(
                          '$thisWeek ${thisWeek == 1 ? 'item' : 'items'} this week',
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppText.raw(
                    '$total',
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontFamily: 'Open Serif',
                      fontSize: 38,
                      height: 0.9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 6, color: panel),
            Container(height: 5, color: AppColors.signal),
            _MetricRow(label: 'To pay this week, incl. overdue', value: toPay),
            _MetricRow(label: 'Monthly commitments', value: monthlyCommitments),
            _MetricRow(
              label: 'Needs your attention',
              value: '$total ${total == 1 ? 'item' : 'items'}',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : Border(bottom: BorderSide(color: _borderColor(context))),
    ),
    child: Row(
      children: [
        Expanded(
          child: AppText.raw(
            label,
            style: TextStyle(fontSize: 14, color: _mutedColor(context)),
          ),
        ),
        addHorizontalSpacing(3),
        Flexible(
          child: AppText.raw(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Open Serif',
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => AppText.raw(
    '$title · $count',
    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontFamily: 'Open Serif',
      fontSize: 26,
      fontWeight: FontWeight.w900,
    ),
  );
}

class _WeekActionCard extends StatelessWidget {
  const _WeekActionCard({
    required this.item,
    required this.catalog,
    required this.isLoading,
    required this.onMarkPaid,
  });

  final _DatedItem item;
  final Catalog? catalog;
  final bool isLoading;
  final VoidCallback? onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _DashboardPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.signal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: _foregroundColor(context)),
              ),
              addHorizontalSpacing(3.5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.raw(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Open Serif',
                        fontSize: 21,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (item.amount != null && item.currencyId != null) ...[
                      addVerticalSpacing(0.5),
                      AppText.raw(
                        money(item.amount!, item.currencyId!, catalog),
                        style: TextStyle(
                          fontSize: 15,
                          color: _mutedColor(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          addVerticalSpacing(1.25),
          AppText.raw(
            _relativeDate(item.date),
            style: TextStyle(color: _mutedColor(context)),
          ),
          addVerticalSpacing(1.25),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _UrgencyBadge(label: item.status),
              if (onMarkPaid != null) ...[
                const Spacer(),
                SizedBox(
                  width: 120,
                  child: AppButton(
                    text: 'Mark paid',
                    onPressed: onMarkPaid,
                    isLoading: isLoading,
                    icon: const Icon(Icons.check),
                    compact: true,
                    btnColor: dark ? AppColors.paper : AppColors.ink,
                    textColor: dark ? AppColors.ink : AppColors.paper,
                    borderRadius: 10,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _UrgencyBadge extends StatelessWidget {
  const _UrgencyBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final normalized = label.toLowerCase();
    final text = normalized == 'overdue'
        ? 'OVERDUE'
        : const ['due', 'soon', 'upcoming', 'expiring'].contains(normalized)
        ? 'DUE SOON'
        : label.toUpperCase();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.signal,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule, size: 15, color: AppColors.ink),
            addHorizontalSpacing(1.25),
            AppText.raw(
              text,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingBreakdown extends StatelessWidget {
  const _SpendingBreakdown({
    required this.attention,
    required this.currencyId,
    required this.catalog,
  });

  final DashboardAttention attention;
  final String currencyId;
  final Catalog? catalog;

  @override
  Widget build(BuildContext context) {
    final totals = <String, double>{};
    for (final bill in attention.bills) {
      if (currencyId.isNotEmpty && bill.currencyId != currencyId) continue;
      final category = bill.category.trim().isEmpty ? 'Bills' : bill.category;
      totals.update(
        category,
        (value) => value + bill.amount,
        ifAbsent: () => bill.amount,
      );
    }
    for (final subscription in attention.subscriptions) {
      if (currencyId.isNotEmpty && subscription.currencyId != currencyId) {
        continue;
      }
      totals.update(
        'Subscriptions',
        (value) => value + subscription.amount,
        ifAbsent: () => subscription.amount,
      );
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final visibleEntries = entries.take(4).toList();
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.value);

    return _DashboardPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeading(
            title: 'Where the money goes',
            subtitle: 'Monthly equivalent of unpaid bills and subscriptions',
          ),
          addVerticalSpacing(2),
          if (visibleEntries.isEmpty)
            const _EmptyDashboardSection(
              icon: Icons.donut_small_outlined,
              message: 'Your spending breakdown will appear here.',
            )
          else
            for (var index = 0; index < visibleEntries.length; index++) ...[
              _SpendingRow(
                label: visibleEntries[index].key,
                amount: money(visibleEntries[index].value, currencyId, catalog),
                progress: total == 0 ? 0 : visibleEntries[index].value / total,
              ),
              if (index != visibleEntries.length - 1) addVerticalSpacing(1.75),
            ],
        ],
      ),
    );
  }
}

class _SpendingRow extends StatelessWidget {
  const _SpendingRow({
    required this.label,
    required this.amount,
    required this.progress,
  });

  final String label;
  final String amount;
  final double progress;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: AppText.raw(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          AppText.raw(
            '$amount · ${(progress * 100).round()}%',
            style: TextStyle(color: _mutedColor(context)),
          ),
        ],
      ),
      addVerticalSpacing(0.75),
      ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          color: AppColors.signal,
          backgroundColor: _borderColor(context),
        ),
      ),
    ],
  );
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({required this.items, required this.onOpenCalendar});

  final List<_DatedItem> items;
  final VoidCallback onOpenCalendar;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(4).toList();
    return _DashboardPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: _PanelHeading(
                  title: 'Next 30 days',
                  subtitle: 'Bills, renewals and upkeep',
                ),
              ),
              AppButton(
                text: 'Calendar',
                onPressed: onOpenCalendar,
                icon: const Icon(Icons.calendar_month_outlined),
                variant: AppButtonVariant.text,
                textColor: _foregroundColor(context),
                compact: true,
              ),
            ],
          ),
          addVerticalSpacing(2),
          if (visibleItems.isEmpty)
            const _EmptyDashboardSection(
              icon: Icons.event_available_outlined,
              message: 'Nothing is scheduled in the next 30 days.',
            )
          else
            for (var index = 0; index < visibleItems.length; index++)
              _TimelineRow(
                item: visibleItems[index],
                isLast: index == visibleItems.length - 1,
              ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item, required this.isLast});

  final _DatedItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 54,
          child: AppText.raw(
            DateFormat('d MMM').format(item.date),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(
          width: 22,
          child: Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.signal,
                  shape: BoxShape.circle,
                  border: Border.all(color: _foregroundColor(context)),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 1, color: _borderColor(context)),
                ),
            ],
          ),
        ),
        addHorizontalSpacing(2),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.raw(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                addVerticalSpacing(0.25),
                AppText.raw(
                  item.type,
                  style: TextStyle(color: _mutedColor(context)),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.bills,
    required this.subscriptions,
    required this.maintenance,
    required this.documents,
  });

  final int bills;
  final int subscriptions;
  final int maintenance;
  final int documents;

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 14,
    crossAxisSpacing: 14,
    childAspectRatio: 0.94,
    children: [
      _SummaryTile(
        icon: Icons.receipt_long_outlined,
        count: bills,
        label: 'Bills to pay',
      ),
      _SummaryTile(
        icon: Icons.paid_outlined,
        count: subscriptions,
        label: 'Active subscriptions',
      ),
      _SummaryTile(
        icon: Icons.handyman_outlined,
        count: maintenance,
        label: 'Maintenance due',
      ),
      _SummaryTile(
        icon: Icons.description_outlined,
        count: documents,
        label: 'Expiring documents',
      ),
    ],
  );
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) => _DashboardPanel(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28),
        const Spacer(),
        AppText.raw(
          '$count',
          style: const TextStyle(
            fontFamily: 'Open Serif',
            fontSize: 42,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        addVerticalSpacing(0.75),
        AppText.raw(
          label,
          maxLines: 2,
          style: TextStyle(fontSize: 16, color: _mutedColor(context)),
        ),
      ],
    ),
  );
}

class _PanelHeading extends StatelessWidget {
  const _PanelHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText.raw(
        title,
        style: const TextStyle(
          fontFamily: 'Open Serif',
          fontSize: 24,
          height: 1,
          fontWeight: FontWeight.w900,
        ),
      ),
      addVerticalSpacing(0.75),
      AppText.raw(
        subtitle,
        style: TextStyle(fontSize: 14, color: _mutedColor(context)),
      ),
    ],
  );
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.surfaceDark : AppColors.white,
        border: Border.all(color: _borderColor(context)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _EmptyDashboardSection extends StatelessWidget {
  const _EmptyDashboardSection({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Icon(icon, color: _mutedColor(context)),
        addHorizontalSpacing(3),
        Expanded(
          child: AppText.raw(
            message,
            style: TextStyle(color: _mutedColor(context)),
          ),
        ),
      ],
    ),
  );
}

class _DatedItem {
  const _DatedItem({
    required this.date,
    required this.title,
    required this.type,
    required this.status,
    required this.icon,
    this.amount,
    this.currencyId,
    this.bill,
  });

  final DateTime date;
  final String title;
  final String type;
  final String status;
  final IconData icon;
  final double? amount;
  final String? currencyId;
  final Bill? bill;
}

DashboardAttention _attentionForSpace(
  DashboardAttention attention,
  String? spaceId,
) {
  if (spaceId == null) return attention;
  return DashboardAttention(
    bills: attention.bills.where((item) => item.spaceId == spaceId).toList(),
    subscriptions: attention.subscriptions
        .where((item) => item.spaceId == spaceId)
        .toList(),
    maintenance: attention.maintenance
        .where((item) => item.spaceId == spaceId)
        .toList(),
    assets: attention.assets.where((item) => item.spaceId == spaceId).toList(),
    documents: attention.documents
        .where((item) => item.spaceId == spaceId)
        .toList(),
  );
}

List<_DatedItem> _datedItems(DashboardAttention attention) {
  final items = <_DatedItem>[];
  for (final bill in attention.bills) {
    final date = _parseDate(bill.due);
    if (date != null) {
      items.add(
        _DatedItem(
          date: date,
          title: bill.title,
          type: 'Bill',
          status: bill.status,
          icon: Icons.receipt_long_outlined,
          amount: bill.amount,
          currencyId: bill.currencyId,
          bill: bill,
        ),
      );
    }
  }
  for (final subscription in attention.subscriptions) {
    final date = _parseDate(subscription.renewal);
    if (date != null) {
      items.add(
        _DatedItem(
          date: date,
          title: subscription.title,
          type: 'Subscription',
          status: subscription.status,
          icon: Icons.paid_outlined,
          amount: subscription.amount,
          currencyId: subscription.currencyId,
        ),
      );
    }
  }
  for (final maintenance in attention.maintenance) {
    final date = _parseDate(maintenance.nextDue);
    if (date != null) {
      items.add(
        _DatedItem(
          date: date,
          title: maintenance.title,
          type: 'Maintenance',
          status: maintenance.status,
          icon: Icons.handyman_outlined,
        ),
      );
    }
  }
  for (final asset in attention.assets) {
    final date = _parseDate(asset.renewal);
    if (date != null) {
      items.add(
        _DatedItem(
          date: date,
          title: asset.title,
          type: 'Asset',
          status: asset.status,
          icon: Icons.devices_other_outlined,
        ),
      );
    }
  }
  for (final document in attention.documents) {
    final date = _parseDate(document.expiry);
    if (date != null) {
      items.add(
        _DatedItem(
          date: date,
          title: document.title,
          type: 'Document',
          status: document.status,
          icon: Icons.description_outlined,
        ),
      );
    }
  }
  items.sort((a, b) => a.date.compareTo(b.date));
  return items;
}

List<_DatedItem> _thisWeekItems(List<_DatedItem> items) {
  final weekEnd = _startOfDay(DateTime.now()).add(const Duration(days: 7));
  return items.where((item) => !item.date.isAfter(weekEnd)).toList();
}

List<_DatedItem> _nextThirtyDays(List<_DatedItem> items) {
  final today = _startOfDay(DateTime.now());
  final end = today.add(const Duration(days: 30));
  return items
      .where((item) => !item.date.isBefore(today) && !item.date.isAfter(end))
      .toList();
}

double _toPayThisWeek(DashboardAttention attention, String currencyId) {
  final end = _startOfDay(DateTime.now()).add(const Duration(days: 7));
  return attention.bills
      .where((bill) {
        final date = _parseDate(bill.due);
        return date != null &&
            !date.isAfter(end) &&
            (currencyId.isEmpty || bill.currencyId == currencyId);
      })
      .fold(0, (sum, bill) => sum + bill.amount);
}

double _monthlyCommitments(DashboardAttention attention, String currencyId) {
  var total = 0.0;
  for (final bill in attention.bills) {
    if (currencyId.isEmpty || bill.currencyId == currencyId) {
      total += _monthlyEquivalent(bill.amount, bill.recurrence);
    }
  }
  for (final subscription in attention.subscriptions) {
    if (currencyId.isEmpty || subscription.currencyId == currencyId) {
      total += _monthlyEquivalent(subscription.amount, subscription.billing);
    }
  }
  return total;
}

double _monthlyEquivalent(double amount, String cadence) {
  final value = cadence.toLowerCase();
  if (value.contains('annual') || value.contains('year')) return amount / 12;
  if (value.contains('quarter')) return amount / 3;
  if (value.contains('week')) return amount * 52 / 12;
  if (value.contains('day')) return amount * 365 / 12;
  return amount;
}

String _primaryCurrencyId(DashboardAttention attention) {
  if (attention.bills.isNotEmpty) return attention.bills.first.currencyId;
  if (attention.subscriptions.isNotEmpty) {
    return attention.subscriptions.first.currencyId;
  }
  return '';
}

int _summaryCount(SpaceSummary? summary, List<String> keys, int fallback) {
  if (summary == null) return fallback;
  for (final key in keys) {
    final value = summary.counts[key];
    if (value != null) return value;
  }
  return fallback;
}

bool _hasNoHomeData({
  required int attentionTotal,
  required List<Space>? spaces,
  required SpaceSummary? summary,
}) {
  if (summary != null) {
    final total = summary.counts['total'];
    if (total != null) return total == 0;
    return summary.counts.values.every((count) => count == 0);
  }
  if (spaces != null) {
    return attentionTotal == 0 && spaces.every((space) => space.itemCount == 0);
  }
  return attentionTotal == 0;
}

DateTime? _parseDate(String value) {
  final date = DateTime.tryParse(value);
  return date == null ? null : _startOfDay(date.toLocal());
}

DateTime _startOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String _relativeDate(DateTime date) {
  final days = date.difference(_startOfDay(DateTime.now())).inDays;
  if (days < 0) return '${days.abs()} ${days == -1 ? 'day' : 'days'} overdue';
  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  return 'In $days days';
}

String _displayName(String? value) {
  final name = value?.trim() ?? '';
  return name.isEmpty ? 'there' : name;
}

String _greeting() {
  final hour = DateTime.now().hour;
  return hour < 12
      ? 'morning'
      : hour < 17
      ? 'afternoon'
      : 'evening';
}

Color _foregroundColor(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface;

Color _mutedColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? Colors.white60
    : AppColors.muted;

Color _borderColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? Colors.white24
    : AppColors.line;
