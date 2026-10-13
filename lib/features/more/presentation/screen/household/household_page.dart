import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/data/model/catalog/account_catalog.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/hearth_providers.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/create_household_item_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/household_items/update_household_item_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/maintenance/create_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/maintenance/update_maintenance_request.dart';
import 'package:idile_mobile_app/features/more/data/model/household_items/household_item.dart';
import 'package:idile_mobile_app/features/more/data/model/maintenance/maintenance_task.dart';
import 'package:idile_mobile_app/features/more/presentation/state/providers/household_item_provider.dart';
import 'package:idile_mobile_app/features/more/presentation/state/providers/maintenance_provider.dart';
import 'package:idile_mobile_app/features/more/presentation/widget/household_item_tile.dart';
import 'package:idile_mobile_app/features/more/presentation/widget/maintenance_task_tile.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';

Future<void> showCreateHouseholdItemForm(
  BuildContext context,
  WidgetRef ref,
) async {
  final catalog = await ref.read(catalogControllerProvider.future);
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _HouseholdItemForm(
      catalog: catalog,
      onSubmit: (result) => ref
          .read(householdItemControllerProvider.notifier)
          .createHouseholdItem(result.createRequest),
    ),
  );
}

Future<void> showCreateMaintenanceForm(
  BuildContext context,
  WidgetRef ref,
) async {
  final catalog = await ref.read(catalogControllerProvider.future);
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _MaintenanceForm(
      catalog: catalog,
      onSubmit: (result) => ref
          .read(maintenanceControllerProvider.notifier)
          .createMaintenance(result.createRequest),
    ),
  );
}

class HouseholdPage extends ConsumerWidget {
  const HouseholdPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: Navigator.canPop(context)
          ? AppBar(title: const AppText.raw('Household'))
          : null,
      body: Column(
        children: [
          if (!Navigator.canPop(context))
            const PageHeading(
              'Household',
              subtitle: 'What you own and what needs upkeep.',
              trailing: SpaceSelector(),
            ),
          const TabBar(
            tabs: [
              Tab(text: 'Items'),
              Tab(text: 'Maintenance'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _HouseholdItemsTab(
                  onEdit: (item) => _openItem(context, ref, item),
                ),
                _MaintenanceTab(
                  onEdit: (task) => _openTask(context, ref, task),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          heroTag: 'household-add-fab',
          backgroundColor: AppColors.signal,
          foregroundColor: AppColors.ink,
          onPressed: () => DefaultTabController.of(context).index == 0
              ? _openItem(context, ref)
              : _openTask(context, ref),
          child: const Icon(Icons.add),
        ),
      ),
    ),
  );

  Future<void> _openItem(
    BuildContext context,
    WidgetRef ref, [
    HouseholdItem? item,
  ]) async {
    if (item == null) {
      await showCreateHouseholdItemForm(context, ref);
      return;
    }
    final catalog = await ref.read(catalogControllerProvider.future);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _HouseholdItemForm(
        catalog: catalog,
        item: item,
        onSubmit: (result) => ref
            .read(householdItemControllerProvider.notifier)
            .updateHouseholdItem(item.id, result.updateRequest),
      ),
    );
  }

  Future<void> _openTask(
    BuildContext context,
    WidgetRef ref, [
    MaintenanceTask? task,
  ]) async {
    if (task == null) {
      await showCreateMaintenanceForm(context, ref);
      return;
    }
    final catalog = await ref.read(catalogControllerProvider.future);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _MaintenanceForm(
        catalog: catalog,
        task: task,
        onSubmit: (result) => ref
            .read(maintenanceControllerProvider.notifier)
            .updateMaintenance(task.id, result.updateRequest),
      ),
    );
  }
}

class _HouseholdItemsTab extends ConsumerWidget {
  const _HouseholdItemsTab({required this.onEdit});

  final ValueChanged<HouseholdItem> onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdItems = ref.watch(householdItemControllerProvider);
    final catalog = ref.watch(catalogControllerProvider).value;
    final value = householdItems.value;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
          child: Row(
            children: [
              if (value?.roomFilter != null)
                InputChip(
                  label: AppText.raw(value!.roomFilter!),
                  onDeleted: () => ref
                      .read(householdItemControllerProvider.notifier)
                      .setRoom(null),
                )
              else
                AppText.raw(
                  'All rooms',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              const Spacer(),
              AppButton(
                text: 'Room',
                onPressed: () => _filterByRoom(context, ref, value?.roomFilter),
                icon: const Icon(Icons.filter_list),
                variant: AppButtonVariant.text,
                compact: true,
              ),
            ],
          ),
        ),
        Expanded(
          child: householdItems.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(
              error: error,
              onRetry: () => ref.invalidate(householdItemControllerProvider),
            ),
            data: (state) => state.items.isEmpty
                ? const EmptyState(
                    icon: Icons.chair_outlined,
                    title: 'No household items',
                    message: 'Add appliances, furniture and valuables by room.',
                  )
                : RefreshIndicator(
                    onRefresh: ref
                        .read(householdItemControllerProvider.notifier)
                        .refreshHouseholdItems,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 300) {
                          ref
                              .read(householdItemControllerProvider.notifier)
                              .loadMore();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount:
                            state.items.length +
                            (state.hasNextPage || state.loadMoreError != null
                                ? 1
                                : 0),
                        separatorBuilder: (_, _) => addVerticalSpacing(1.25),
                        itemBuilder: (context, index) {
                          if (index == state.items.length) {
                            if (state.loadMoreError != null) {
                              return Center(
                                child: AppButton(
                                  text: 'Try loading more again',
                                  onPressed: ref
                                      .read(
                                        householdItemControllerProvider
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
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final item = state.items[index];
                          return HouseholdItemTile(
                            item: item,
                            catalog: catalog,
                            isUpdating: state.isUpdating(item.id),
                            isDeleting: state.isDeleting(item.id),
                            onEdit: () => onEdit(item),
                            onDelete: () => _delete(context, ref, item),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _filterByRoom(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final controller = TextEditingController(text: current);
    final room = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText.raw('Filter by room'),
        content: GlobalTextField(
          fieldName: 'e.g. Kitchen',
          keyBoardType: TextInputType.text,
          textController: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          removeSpace: false,
          isOptional: true,
          onFieldSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          AppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
            variant: AppButtonVariant.text,
            compact: true,
          ),
          AppButton(
            text: 'Apply',
            onPressed: () => Navigator.pop(context, controller.text),
            compact: true,
          ),
        ],
      ),
    );
    controller.dispose();
    if (room == null || !context.mounted) return;
    await ref
        .read(householdItemControllerProvider.notifier)
        .setRoom(room.trim().isEmpty ? null : room.trim());
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    HouseholdItem item,
  ) async {
    if (!await confirmDelete(context, item.title)) return;
    try {
      await ref
          .read(householdItemControllerProvider.notifier)
          .deleteHouseholdItem(item.id);
    } catch (error) {
      if (context.mounted) showFailure(context, error);
    }
  }
}

class _MaintenanceTab extends ConsumerWidget {
  const _MaintenanceTab({required this.onEdit});

  final ValueChanged<MaintenanceTask> onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenance = ref.watch(maintenanceControllerProvider);
    final value = maintenance.value;
    return Column(
      children: [
        _MaintenanceStatusFilter(
          selected: value?.statusFilter,
          onChanged: ref.read(maintenanceControllerProvider.notifier).setStatus,
        ),
        Expanded(
          child: maintenance.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(
              error: error,
              onRetry: () => ref.invalidate(maintenanceControllerProvider),
            ),
            data: (state) => state.tasks.isEmpty
                ? const EmptyState(
                    icon: Icons.home_repair_service_outlined,
                    title: 'No upkeep tasks',
                    message:
                        'Add servicing, cleaning and maintenance schedules.',
                  )
                : RefreshIndicator(
                    onRefresh: ref
                        .read(maintenanceControllerProvider.notifier)
                        .refreshMaintenance,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 300) {
                          ref
                              .read(maintenanceControllerProvider.notifier)
                              .loadMore();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount:
                            state.tasks.length +
                            (state.hasNextPage || state.loadMoreError != null
                                ? 1
                                : 0),
                        separatorBuilder: (_, _) => addVerticalSpacing(1.25),
                        itemBuilder: (context, index) {
                          if (index == state.tasks.length) {
                            if (state.loadMoreError != null) {
                              return Center(
                                child: AppButton(
                                  text: 'Try loading more again',
                                  onPressed: ref
                                      .read(
                                        maintenanceControllerProvider.notifier,
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
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final task = state.tasks[index];
                          return MaintenanceTaskTile(
                            task: task,
                            isUpdating: state.isUpdating(task.id),
                            isDeleting: state.isDeleting(task.id),
                            isCompleting: state.isCompleting(task.id),
                            onEdit: () => onEdit(task),
                            onDelete: () => _delete(context, ref, task),
                            onMarkDone: () => _markDone(context, ref, task),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    MaintenanceTask task,
  ) async {
    if (!await confirmDelete(context, task.title)) return;
    try {
      await ref
          .read(maintenanceControllerProvider.notifier)
          .deleteMaintenance(task.id);
    } catch (error) {
      if (context.mounted) showFailure(context, error);
    }
  }

  Future<void> _markDone(
    BuildContext context,
    WidgetRef ref,
    MaintenanceTask task,
  ) async {
    try {
      await ref.read(maintenanceControllerProvider.notifier).markDone(task.id);
    } catch (error) {
      if (context.mounted) showFailure(context, error);
    }
  }
}

class _MaintenanceStatusFilter extends StatelessWidget {
  const _MaintenanceStatusFilter({
    required this.selected,
    required this.onChanged,
  });

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
    child: Row(
      children: [
        for (final status in const <String?>[
          null,
          'due',
          'soon',
          'scheduled',
        ]) ...[
          ChoiceChip(
            label: AppText.raw(status == null ? 'All' : _title(status)),
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

abstract class _BaseHouseholdFormState<T extends StatefulWidget>
    extends State<T> {
  final key = GlobalKey<FormState>();

  Future<void> pickDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
    );
    if (date != null) {
      controller.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}

class _HouseholdItemForm extends StatefulWidget {
  const _HouseholdItemForm({
    required this.catalog,
    required this.onSubmit,
    this.item,
  });

  final Catalog catalog;
  final Future<void> Function(_HouseholdItemFormValue value) onSubmit;
  final HouseholdItem? item;

  @override
  State<_HouseholdItemForm> createState() => _HouseholdItemFormState();
}

class _HouseholdItemFormState
    extends _BaseHouseholdFormState<_HouseholdItemForm> {
  late final TextEditingController title;
  late final TextEditingController room;
  late final TextEditingController purchased;
  late final TextEditingController warranty;
  late final TextEditingController value;
  late final TextEditingController maintenanceId;
  String? spaceId;
  String? currencyId;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    title = TextEditingController(text: item?.title);
    room = TextEditingController(text: item?.room);
    purchased = TextEditingController(text: item?.purchased.split('T').first);
    warranty = TextEditingController(text: item?.warranty.split('T').first);
    value = TextEditingController(text: item?.value.toString());
    maintenanceId = TextEditingController(text: item?.maintenanceId);
    spaceId =
        item?.spaceId ??
        (widget.catalog.spaces.isEmpty ? null : widget.catalog.spaces.first.id);
    currencyId =
        item?.currencyId ??
        (widget.catalog.currencies.isEmpty
            ? null
            : widget.catalog.currencies.first.id);
  }

  @override
  void dispose() {
    title.dispose();
    room.dispose();
    purchased.dispose();
    warranty.dispose();
    value.dispose();
    maintenanceId.dispose();
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
              widget.item == null
                  ? 'Add household item'
                  : 'Edit household item',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            addVerticalSpacing(2.25),
            GlobalTextField(
              fieldName: 'Item name',
              keyBoardType: TextInputType.name,
              textController: title,
              removeSpace: false,
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Room',
              keyBoardType: TextInputType.name,
              textController: room,
              removeSpace: false,
            ),
            addVerticalSpacing(1.5),
            Row(
              children: [
                Expanded(
                  child: GlobalTextField(
                    fieldName: 'Value',
                    keyBoardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textController: value,
                  ),
                ),
                addHorizontalSpacing(3),
                Expanded(
                  child: GlobalSearchableDropdown<String>(
                    title: 'Currency',
                    hintText: 'Choose currency',
                    value: currencyId,
                    options: [
                      for (final currency in widget.catalog.currencies)
                        SearchableDropdownOption(
                          value: currency.id,
                          label: '${currency.symbol} ${currency.name}',
                        ),
                    ],
                    onChanged: (selected) =>
                        setState(() => currencyId = selected),
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
                for (final space in widget.catalog.spaces)
                  SearchableDropdownOption(value: space.id, label: space.name),
              ],
              onChanged: (selected) => setState(() => spaceId = selected),
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Purchased',
              keyBoardType: TextInputType.datetime,
              textController: purchased,
              readOnly: true,
              suffix: const Icon(Icons.calendar_today_outlined),
              onTap: () => pickDate(purchased),
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Warranty until',
              keyBoardType: TextInputType.datetime,
              textController: warranty,
              readOnly: true,
              suffix: const Icon(Icons.calendar_today_outlined),
              onTap: () => pickDate(warranty),
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Maintenance ID (optional)',
              keyBoardType: TextInputType.text,
              textController: maintenanceId,
              removeSpace: false,
              isOptional: true,
            ),
            addVerticalSpacing(2.5),
            AppButton(
              text: 'Save item',
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
    final parsedValue = double.tryParse(value.text.trim());
    if (parsedValue == null) {
      showFailure(context, 'Enter a valid household item value.');
      return;
    }

    setState(() => isSubmitting = true);
    try {
      await widget.onSubmit(
        _HouseholdItemFormValue(
          title: title.text,
          spaceId: spaceId!,
          room: room.text,
          purchased: purchased.text,
          warranty: warranty.text,
          value: parsedValue,
          currencyId: currencyId!,
          maintenanceId: maintenanceId.text,
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

class _HouseholdItemFormValue {
  const _HouseholdItemFormValue({
    required this.title,
    required this.spaceId,
    required this.room,
    required this.purchased,
    required this.warranty,
    required this.value,
    required this.currencyId,
    required this.maintenanceId,
  });

  final String title;
  final String spaceId;
  final String room;
  final String purchased;
  final String warranty;
  final double value;
  final String currencyId;
  final String maintenanceId;

  CreateHouseholdItemRequest get createRequest => CreateHouseholdItemRequest(
    title: title,
    spaceId: spaceId,
    room: room,
    purchased: purchased,
    warranty: warranty,
    value: value,
    currencyId: currencyId,
    maintenanceId: maintenanceId,
  );

  UpdateHouseholdItemRequest get updateRequest => UpdateHouseholdItemRequest(
    title: title,
    spaceId: spaceId,
    room: room,
    purchased: purchased,
    warranty: warranty,
    value: value,
    currencyId: currencyId,
    maintenanceId: maintenanceId,
  );
}

class _MaintenanceForm extends StatefulWidget {
  const _MaintenanceForm({
    required this.catalog,
    required this.onSubmit,
    this.task,
  });

  final Catalog catalog;
  final Future<void> Function(_MaintenanceFormValue value) onSubmit;
  final MaintenanceTask? task;

  @override
  State<_MaintenanceForm> createState() => _MaintenanceFormState();
}

class _MaintenanceFormState extends _BaseHouseholdFormState<_MaintenanceForm> {
  late final TextEditingController title;
  late final TextEditingController item;
  late final TextEditingController lastDone;
  late final TextEditingController nextDue;
  late final TextEditingController interval;
  String? spaceId;
  late String status;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    title = TextEditingController(text: task?.title);
    item = TextEditingController(text: task?.item);
    lastDone = TextEditingController(text: task?.lastDone.split('T').first);
    nextDue = TextEditingController(text: task?.nextDue.split('T').first);
    interval = TextEditingController(
      text: (task?.intervalMonths ?? 3).toString(),
    );
    spaceId =
        task?.spaceId ??
        (widget.catalog.spaces.isEmpty ? null : widget.catalog.spaces.first.id);
    status = task?.status ?? 'scheduled';
  }

  @override
  void dispose() {
    title.dispose();
    item.dispose();
    lastDone.dispose();
    nextDue.dispose();
    interval.dispose();
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
              widget.task == null
                  ? 'Add maintenance task'
                  : 'Edit maintenance task',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            addVerticalSpacing(1.75),
            GlobalTextField(
              fieldName: 'Task',
              keyBoardType: TextInputType.name,
              textController: title,
              removeSpace: false,
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'For item',
              keyBoardType: TextInputType.name,
              textController: item,
              removeSpace: false,
            ),
            addVerticalSpacing(1.5),
            GlobalSearchableDropdown<String>(
              title: 'Space',
              hintText: 'Choose a space',
              value: spaceId,
              options: [
                for (final space in widget.catalog.spaces)
                  SearchableDropdownOption(value: space.id, label: space.name),
              ],
              onChanged: (selected) => setState(() => spaceId = selected),
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Last done',
              keyBoardType: TextInputType.datetime,
              textController: lastDone,
              readOnly: true,
              suffix: const Icon(Icons.calendar_today_outlined),
              onTap: () => pickDate(lastDone),
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Next due',
              keyBoardType: TextInputType.datetime,
              textController: nextDue,
              readOnly: true,
              suffix: const Icon(Icons.calendar_today_outlined),
              onTap: () => pickDate(nextDue),
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Repeat every (months)',
              keyBoardType: TextInputType.number,
              textController: interval,
            ),
            if (widget.task != null) ...[
              addVerticalSpacing(1.5),
              GlobalSearchableDropdown<String>(
                title: 'Status',
                hintText: 'Choose status',
                value: status,
                options: [
                  for (final value in const ['due', 'soon', 'scheduled'])
                    SearchableDropdownOption(
                      value: value,
                      label: '${value[0].toUpperCase()}${value.substring(1)}',
                    ),
                ],
                onChanged: (selected) => setState(() => status = selected),
                showSearch: false,
              ),
            ],
            addVerticalSpacing(2.25),
            AppButton(
              text: 'Save task',
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
    if (!key.currentState!.validate() || spaceId == null) return;
    final parsedInterval = int.tryParse(interval.text.trim());
    if (parsedInterval == null || parsedInterval < 1) {
      showFailure(context, 'Enter a valid repeat interval.');
      return;
    }

    setState(() => isSubmitting = true);
    try {
      await widget.onSubmit(
        _MaintenanceFormValue(
          title: title.text,
          spaceId: spaceId!,
          item: item.text,
          lastDone: lastDone.text,
          nextDue: nextDue.text,
          intervalMonths: parsedInterval,
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

class _MaintenanceFormValue {
  const _MaintenanceFormValue({
    required this.title,
    required this.spaceId,
    required this.item,
    required this.lastDone,
    required this.nextDue,
    required this.intervalMonths,
    required this.status,
  });

  final String title;
  final String spaceId;
  final String item;
  final String lastDone;
  final String nextDue;
  final int intervalMonths;
  final String status;

  CreateMaintenanceRequest get createRequest => CreateMaintenanceRequest(
    title: title,
    spaceId: spaceId,
    item: item,
    lastDone: lastDone,
    nextDue: nextDue,
    intervalMonths: intervalMonths,
  );

  UpdateMaintenanceRequest get updateRequest => UpdateMaintenanceRequest(
    title: title,
    spaceId: spaceId,
    item: item,
    lastDone: lastDone,
    nextDue: nextDue,
    intervalMonths: intervalMonths,
    status: status,
  );
}
