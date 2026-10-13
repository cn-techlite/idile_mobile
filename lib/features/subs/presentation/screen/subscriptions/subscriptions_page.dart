import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/data/model/catalog/account_catalog.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/hearth_providers.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/create_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/data/dto/subscriptions/update_subscription_request.dart';
import 'package:idile_mobile_app/features/subs/data/model/subscriptions/subscription.dart';
import 'package:idile_mobile_app/features/subs/presentation/state/providers/subscription_provider.dart';
import 'package:idile_mobile_app/features/subs/presentation/widget/subscription_tile.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';

Future<void> showCreateSubscriptionForm(
  BuildContext context,
  WidgetRef ref,
) async {
  final catalog = await ref.read(catalogControllerProvider.future);
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _SubscriptionForm(
      catalog: catalog,
      onSubmit: (result) => ref
          .read(subscriptionControllerProvider.notifier)
          .createSubscription(result.createRequest),
    ),
  );
}

class SubscriptionsPage extends ConsumerWidget {
  const SubscriptionsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionControllerProvider);
    final catalog = ref.watch(catalogControllerProvider).value;
    final value = subscriptions.value;
    return Scaffold(
      appBar: Navigator.canPop(context)
          ? AppBar(title: const AppText.raw('Subscriptions'))
          : null,
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'subscriptions-add-fab',
        backgroundColor: AppColors.signal,
        foregroundColor: AppColors.ink,
        onPressed: () => _open(context, ref),
        icon: const Icon(Icons.add),
        label: const AppText.raw('Add subscription'),
      ),
      body: Column(
        children: [
          if (!Navigator.canPop(context))
            const PageHeading(
              'Subscriptions',
              subtitle: 'Renewals without surprises.',
              trailing: SpaceSelector(),
            ),
          _StatusFilter(
            selected: value?.statusFilter,
            onChanged: (status) => ref
                .read(subscriptionControllerProvider.notifier)
                .setStatus(status),
          ),
          Expanded(
            child: subscriptions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () => ref.invalidate(subscriptionControllerProvider),
              ),
              data: (state) => state.subscriptions.isEmpty
                  ? const EmptyState(
                      icon: Icons.autorenew,
                      title: 'No subscriptions',
                      message: 'Track streaming, software, insurance and other renewals.',
                    )
                  : RefreshIndicator(
                      onRefresh: ref
                          .read(subscriptionControllerProvider.notifier)
                          .refreshSubscriptions,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 300) {
                            ref
                                .read(subscriptionControllerProvider.notifier)
                                .loadMore();
                          }
                          return false;
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount:
                              state.subscriptions.length +
                              (state.hasNextPage || state.loadMoreError != null
                                  ? 1
                                  : 0),
                          separatorBuilder: (_, _) => addVerticalSpacing(1.25),
                          itemBuilder: (context, index) {
                            if (index == state.subscriptions.length) {
                              if (state.loadMoreError != null) {
                                return Center(
                                  child: AppButton(
                                    text: 'Try loading more again',
                                    onPressed: ref
                                        .read(
                                          subscriptionControllerProvider
                                              .notifier,
                                        )
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
                            final item = state.subscriptions[index];
                            return SubscriptionTile(
                              subscription: item,
                              catalog: catalog,
                              isUpdating: state.isUpdating(item.id),
                              isDeleting: state.isDeleting(item.id),
                              onEdit: () => _open(context, ref, item),
                              onDelete: () => _delete(context, ref, item),
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

  Future<void> _open(
    BuildContext context,
    WidgetRef ref, [
    SubscriptionItem? item,
  ]) async {
    if (item == null) {
      await showCreateSubscriptionForm(context, ref);
      return;
    }
    final catalog = await ref.read(catalogControllerProvider.future);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SubscriptionForm(
        catalog: catalog,
        item: item,
        onSubmit: (result) => ref
            .read(subscriptionControllerProvider.notifier)
            .updateSubscription(item.id, result.updateRequest),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    SubscriptionItem item,
  ) async {
    if (!await confirmDelete(context, item.title)) return;
    try {
      await ref
          .read(subscriptionControllerProvider.notifier)
          .deleteSubscription(item.id);
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
        for (final status in const <String?>[
          null,
          'active',
          'trial',
          'paused',
          'cancelled',
        ]) ...[
          ChoiceChip(
            label: AppText(text: status == null ? 'All' : _title(status)),
            selected: selected == status,
            onSelected: (_) => onChanged(status),
          ),
          addHorizontalSpacing(2),
        ],
      ],
    ),
  );
}

String _title(String value) => '${value[0].toUpperCase()}${value.substring(1)}';

class _SubscriptionForm extends StatefulWidget {
  const _SubscriptionForm({
    required this.catalog,
    required this.onSubmit,
    this.item,
  });

  final Catalog catalog;
  final Future<void> Function(_SubscriptionFormValue value) onSubmit;
  final SubscriptionItem? item;
  @override
  State<_SubscriptionForm> createState() => _SubscriptionFormState();
}

class _SubscriptionFormState extends State<_SubscriptionForm> {
  late final TextEditingController title, amount, renewal, warning;
  String? spaceId, currencyId;
  late String billing, status;
  bool isSubmitting = false;
  final key = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    final i = widget.item;
    title = TextEditingController(text: i?.title);
    amount = TextEditingController(text: i?.amount.toString());
    renewal = TextEditingController(text: i?.renewal.split('T').first);
    warning = TextEditingController(text: i?.warning);
    spaceId =
        i?.spaceId ??
        (widget.catalog.spaces.isEmpty ? null : widget.catalog.spaces.first.id);
    currencyId =
        i?.currencyId ??
        (widget.catalog.currencies.isEmpty
            ? null
            : widget.catalog.currencies.first.id);
    billing = i?.billing ?? 'monthly';
    status = i?.status ?? 'active';
  }

  @override
  void dispose() {
    title.dispose();
    amount.dispose();
    renewal.dispose();
    warning.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      18,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SingleChildScrollView(
      child: Form(
        key: key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText.raw(
              widget.item == null ? 'Add subscription' : 'Edit subscription',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            addVerticalSpacing(2.25),
            GlobalTextField(
              fieldName: 'Name',
              keyBoardType: TextInputType.name,
              textController: title,
              removeSpace: false,
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
            Row(
              children: [
                Expanded(
                  child: GlobalSearchableDropdown<String>(
                    title: 'Billing',
                    hintText: 'Choose billing',
                    value: billing,
                    options: const [
                      SearchableDropdownOption(
                        value: 'monthly',
                        label: 'Monthly',
                      ),
                      SearchableDropdownOption(
                        value: 'yearly',
                        label: 'Yearly',
                      ),
                    ],
                    onChanged: (value) => setState(() => billing = value),
                    showSearch: false,
                  ),
                ),
                addHorizontalSpacing(3),
                Expanded(
                  child: GlobalSearchableDropdown<String>(
                    title: 'Status',
                    hintText: 'Choose status',
                    value: status,
                    options: [
                      for (final item in const [
                        'active',
                        'trial',
                        'paused',
                        'cancelled',
                      ])
                        SearchableDropdownOption(
                          value: item,
                          label: _title(item),
                        ),
                    ],
                    onChanged: (value) => setState(() => status = value),
                    showSearch: false,
                  ),
                ),
              ],
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Renewal date',
              keyBoardType: TextInputType.datetime,
              textController: renewal,
              readOnly: true,
              suffix: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate:
                      DateTime.tryParse(renewal.text) ?? DateTime.now(),
                );
                if (d != null) {
                  renewal.text =
                      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                }
              },
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Note (optional)',
              keyBoardType: TextInputType.text,
              textController: warning,
              removeSpace: false,
              isOptional: true,
            ),
            addVerticalSpacing(2.5),
            AppButton(
              text: 'Save subscription',
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
        spaceId == null ||
        currencyId == null) {
      return;
    }
    final parsedAmount = double.tryParse(amount.text.trim());
    if (parsedAmount == null) {
      showFailure(context, 'Enter a valid subscription amount.');
      return;
    }

    setState(() => isSubmitting = true);
    try {
      await widget.onSubmit(
        _SubscriptionFormValue(
          title: title.text,
          spaceId: spaceId!,
          amount: parsedAmount,
          currencyId: currencyId!,
          billing: billing,
          renewal: renewal.text,
          warning: warning.text,
          status: status,
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

class _SubscriptionFormValue {
  const _SubscriptionFormValue({
    required this.title,
    required this.spaceId,
    required this.amount,
    required this.currencyId,
    required this.billing,
    required this.renewal,
    required this.warning,
    required this.status,
  });

  final String title;
  final String spaceId;
  final double amount;
  final String currencyId;
  final String billing;
  final String renewal;
  final String warning;
  final String status;

  CreateSubscriptionRequest get createRequest => CreateSubscriptionRequest(
    title: title,
    spaceId: spaceId,
    amount: amount,
    currencyId: currencyId,
    billing: billing,
    renewal: renewal,
    warning: warning,
  );

  UpdateSubscriptionRequest get updateRequest => UpdateSubscriptionRequest(
    title: title,
    spaceId: spaceId,
    amount: amount,
    currencyId: currencyId,
    billing: billing,
    renewal: renewal,
    warning: warning,
    status: status,
  );
}
