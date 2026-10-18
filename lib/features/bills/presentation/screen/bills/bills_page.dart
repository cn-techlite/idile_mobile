import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/domain/entities/catalog/account_catalog.dart';
import 'package:idile_mobile_app/features/bills/domain/parameters/bills/create_bill_request.dart';
import 'package:idile_mobile_app/features/bills/domain/parameters/bills/update_bill_request.dart';
import 'package:idile_mobile_app/features/bills/domain/entities/bills/bill.dart';
import 'package:idile_mobile_app/features/bills/presentation/state/providers/bill_provider.dart';
import 'package:idile_mobile_app/features/bills/presentation/widget/bill_tile.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/hearth_providers.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';

Future<void> showCreateBillForm(BuildContext context, WidgetRef ref) async {
  final catalog = await ref.read(catalogControllerProvider.future);
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _BillForm(
      catalog: catalog,
      onSubmit: (payload) => ref
          .read(billControllerProvider.notifier)
          .createBill(payload.createRequest),
    ),
  );
}

class BillsPage extends ConsumerWidget {
  const BillsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billControllerProvider);
    final catalog = ref.watch(catalogControllerProvider).value;
    final value = bills.value;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'bills-add-fab',
        backgroundColor: AppColors.signal,
        foregroundColor: AppColors.ink,
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add),
        label: const AppText.raw('Add bill'),
      ),
      body: Column(
        children: [
          const PageHeading(
            'Bills',
            subtitle: 'What you owe, when it is due.',
            trailing: SpaceSelector(),
          ),
          _StatusFilter(
            selected: value?.statusFilter,
            onChanged: (status) =>
                ref.read(billControllerProvider.notifier).setStatus(status),
          ),
          Expanded(
            child: bills.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () => ref.invalidate(billControllerProvider),
              ),
              data: (state) => state.bills.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No bills yet',
                      message: 'Add rent, utilities or any recurring household bill.',
                    )
                  : RefreshIndicator(
                      onRefresh: ref
                          .read(billControllerProvider.notifier)
                          .refreshBills,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 300) {
                            ref
                                .read(billControllerProvider.notifier)
                                .loadMore();
                          }
                          return false;
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount:
                              state.bills.length +
                              (_showFooter(
                                    state.hasNextPage,
                                    state.loadMoreError,
                                  )
                                  ? 1
                                  : 0),
                          separatorBuilder: (_, _) => addVerticalSpacing(1.25),
                          itemBuilder: (context, index) {
                            if (index == state.bills.length) {
                              if (state.loadMoreError != null) {
                                return Center(
                                  child: AppButton(
                                    text: 'Try loading more again',
                                    onPressed: ref
                                        .read(billControllerProvider.notifier)
                                        .retryLoadMore,
                                    icon: const Icon(Icons.refresh),
                                    variant: AppButtonVariant.outlined,
                                    compact: true,
                                  ),
                                );
                              }
                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final bill = state.bills[index];
                            return BillTile(
                              bill: bill,
                              catalog: catalog,
                              isUpdating: state.isUpdating(bill.id),
                              isDeleting: state.isDeleting(bill.id),
                              isMarkingPaid: state.isMarkingPaid(bill.id),
                              onEdit: () => _openForm(context, ref, bill),
                              onMarkPaid: () => _markPaid(context, ref, bill),
                              onDelete: () => _delete(context, ref, bill),
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  bool _showFooter(bool hasNextPage, String? error) =>
      hasNextPage || error != null;

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, [
    Bill? bill,
  ]) async {
    if (bill == null) {
      await showCreateBillForm(context, ref);
      return;
    }
    final catalog = await ref.read(catalogControllerProvider.future);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _BillForm(
        catalog: catalog,
        bill: bill,
        onSubmit: (payload) => ref
            .read(billControllerProvider.notifier)
            .updateBill(bill.id, payload.updateRequest),
      ),
    );
  }

  Future<void> _markPaid(BuildContext context, WidgetRef ref, Bill bill) async {
    try {
      await ref.read(billControllerProvider.notifier).markPaid(bill.id);
    } catch (error) {
      if (context.mounted) showFailure(context, error);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Bill bill) async {
    if (!await confirmDelete(context, bill.title)) return;
    try {
      await ref.read(billControllerProvider.notifier).deleteBill(bill.id);
    } catch (error) {
      if (context.mounted) showFailure(context, error);
    }
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.selected, required this.onChanged});

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
    child: Row(
      children: [
        for (final option in const <String?>[
          null,
          'upcoming',
          'due-soon',
          'overdue',
          'paid',
        ]) ...[
          ChoiceChip(
            label: AppText(text: option == null ? 'All' : _statusLabel(option)),
            selected: selected == option,
            onSelected: (_) => onChanged(option),
          ),
          addHorizontalSpacing(2),
        ],
      ],
    ),
  );
}

String _statusLabel(String value) => value
    .split('-')
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');

class _BillForm extends StatefulWidget {
  const _BillForm({required this.catalog, required this.onSubmit, this.bill});

  final Catalog catalog;
  final Future<void> Function(_BillFormValue value) onSubmit;
  final Bill? bill;

  @override
  State<_BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<_BillForm> {
  late final TextEditingController title, amount, due;
  late String recurrence;
  String? category, spaceId, currencyId;
  bool isSubmitting = false;
  final key = GlobalKey<FormState>();
  static const recurrences = <String, String>{
    'one-off': 'One-off',
    'weekly': 'Weekly',
    'bi-weekly': 'Bi-weekly',
    'monthly': 'Monthly',
    'quarterly': 'Quarterly',
    'annually': 'Annually',
  };
  @override
  void initState() {
    super.initState();
    final bill = widget.bill;
    title = TextEditingController(text: bill?.title);
    amount = TextEditingController(text: bill?.amount.toString());
    due = TextEditingController(text: bill?.due.split('T').first);
    recurrence = bill?.recurrence.toLowerCase() ?? 'monthly';
    category = bill?.category.isNotEmpty == true
        ? bill!.category
        : (widget.catalog.categories.isEmpty
              ? null
              : widget.catalog.categories.first.name);
    spaceId =
        bill?.spaceId ??
        (widget.catalog.spaces.isEmpty ? null : widget.catalog.spaces.first.id);
    currencyId =
        bill?.currencyId ??
        (widget.catalog.currencies.isEmpty
            ? null
            : widget.catalog.currencies.first.id);
  }

  @override
  void dispose() {
    title.dispose();
    amount.dispose();
    due.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 20,
      right: 20,
      top: 18,
      bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SingleChildScrollView(
      child: Form(
        key: key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText.raw(
              widget.bill == null ? 'Add a bill' : 'Edit bill',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            addVerticalSpacing(2.25),
            GlobalTextField(
              fieldName: 'Title',
              keyBoardType: TextInputType.name,
              textController: title,
              removeSpace: false,
            ),
            addVerticalSpacing(1.5),
            GlobalSearchableDropdown<String>(
              title: 'Category',
              hintText: 'Choose a category',
              value: category,
              options: [
                for (final item in widget.catalog.categories)
                  SearchableDropdownOption(value: item.name, label: item.name),
              ],
              onChanged: (value) => setState(() => category = value),
              emptyMessage: 'Create a category before adding a bill.',
            ),
            addVerticalSpacing(1.5),
            Row(
              children: [
                Expanded(
                  child: GlobalTextField(
                    fieldName: 'Amount',
                    keyBoardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textController: amount,
                  ),
                ),
                addHorizontalSpacing(3),
                Expanded(
                  child: GlobalSearchableDropdown<String>(
                    title: 'Currency',
                    hintText: 'Choose currency',
                    value: currencyId,
                    options: [
                      for (final item in widget.catalog.currencies)
                        SearchableDropdownOption(
                          value: item.id,
                          label: '${item.symbol} ${item.name}',
                        ),
                    ],
                    onChanged: (value) => setState(() => currencyId = value),
                  ),
                ),
              ],
            ),
            addVerticalSpacing(1.5),
            GlobalSearchableDropdown<String>(
              title: 'Space',
              hintText: 'Choose a space',
              value: spaceId,
              options: [
                for (final item in widget.catalog.spaces)
                  SearchableDropdownOption(value: item.id, label: item.name),
              ],
              onChanged: (value) => setState(() => spaceId = value),
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Due date',
              keyBoardType: TextInputType.datetime,
              textController: due,
              readOnly: true,
              suffix: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final value = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.tryParse(due.text) ?? DateTime.now(),
                );
                if (value != null) due.text = _isoDate(value);
              },
            ),
            addVerticalSpacing(1.5),
            GlobalSearchableDropdown<String>(
              title: 'Recurrence',
              hintText: 'Choose recurrence',
              value: recurrence,
              options: [
                for (final entry in recurrences.entries)
                  SearchableDropdownOption(
                    value: entry.key,
                    label: entry.value,
                  ),
              ],
              onChanged: (value) => setState(() => recurrence = value),
              showSearch: false,
            ),
            addVerticalSpacing(2.5),
            AppButton(
              text: 'Save bill',
              onPressed: isSubmitting ? null : _submit,
              isLoading: isSubmitting,
              btnColor: AppColors.ink,
              textColor: AppColors.signal,
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _submit() async {
    if (!key.currentState!.validate() ||
        category == null ||
        spaceId == null ||
        currencyId == null) {
      return;
    }
    final parsedAmount = double.tryParse(amount.text.trim());
    if (parsedAmount == null) {
      showFailure(context, 'Enter a valid bill amount.');
      return;
    }

    setState(() => isSubmitting = true);
    try {
      await widget.onSubmit(
        _BillFormValue(
          title: title.text,
          category: category!,
          spaceId: spaceId!,
          amount: parsedAmount,
          currencyId: currencyId!,
          due: due.text,
          recurrence: recurrence,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      showFailure(context, error);
      setState(() => isSubmitting = false);
    }
  }
}

class _BillFormValue {
  const _BillFormValue({
    required this.title,
    required this.category,
    required this.spaceId,
    required this.amount,
    required this.currencyId,
    required this.due,
    required this.recurrence,
  });

  final String title;
  final String category;
  final String spaceId;
  final double amount;
  final String currencyId;
  final String due;
  final String recurrence;

  CreateBillRequest get createRequest => CreateBillRequest(
    title: title,
    category: category,
    spaceId: spaceId,
    amount: amount,
    currencyId: currencyId,
    due: due,
    recurrence: recurrence,
  );

  UpdateBillRequest get updateRequest => UpdateBillRequest(
    title: title,
    category: category,
    spaceId: spaceId,
    amount: amount,
    currencyId: currencyId,
    due: due,
    recurrence: recurrence,
  );
}

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
