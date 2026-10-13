import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/data/model/catalog/account_catalog.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/hearth_providers.dart';
import 'package:idile_mobile_app/features/more/data/dto/assets/create_asset_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/assets/update_asset_request.dart';
import 'package:idile_mobile_app/features/more/data/model/assets/asset_item.dart';
import 'package:idile_mobile_app/features/more/presentation/state/providers/asset_provider.dart';
import 'package:idile_mobile_app/features/more/presentation/widget/asset_tile.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/attachment_picker.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showCreateAssetForm(BuildContext context, WidgetRef ref) async {
  final catalog = await ref.read(catalogControllerProvider.future);
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _AssetForm(
      catalog: catalog,
      onSubmit: (result) async {
        await ref
            .read(assetControllerProvider.notifier)
            .createAsset(
              CreateAssetRequest(
                title: result.title,
                spaceId: result.spaceId,
                type: result.type,
                detail: result.detail,
                renewal: result.renewal,
                renewalDate: result.addToCalendar
                    ? '${result.renewal}T00:00:00.000Z'
                    : null,
                fileBytes: await result.file?.readAsBytes(),
                fileName: result.file?.name,
              ),
            );
      },
    ),
  );
}

class AssetsPage extends ConsumerWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(assetControllerProvider);
    final value = assets.value;
    return Scaffold(
      appBar: AppBar(
        title: const AppText.raw('Assets'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: SpaceSelector()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'assets-add-fab',
        backgroundColor: AppColors.signal,
        foregroundColor: AppColors.ink,
        onPressed: value?.isCreating == true
            ? null
            : () => _openAsset(context, ref),
        icon: value?.isCreating == true
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: const AppText.raw('Add asset'),
      ),
      body: Column(
        children: [
          _AssetFilters(
            status: value?.statusFilter,
            type: value?.typeFilter,
            onStatusChanged: ref
                .read(assetControllerProvider.notifier)
                .setStatus,
            onTypeChanged: ref.read(assetControllerProvider.notifier).setType,
          ),
          Expanded(
            child: assets.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () => ref.invalidate(assetControllerProvider),
              ),
              data: (state) => state.assets.isEmpty
                  ? const EmptyState(
                      icon: Icons.laptop_mac_outlined,
                      title: 'No assets',
                      message:
                          'Track hardware, licences and their renewal dates.',
                    )
                  : RefreshIndicator(
                      onRefresh: ref
                          .read(assetControllerProvider.notifier)
                          .refreshAssets,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 300) {
                            ref
                                .read(assetControllerProvider.notifier)
                                .loadMore();
                          }
                          return false;
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount:
                              state.assets.length +
                              (state.hasNextPage || state.loadMoreError != null
                                  ? 1
                                  : 0),
                          separatorBuilder: (_, _) => addVerticalSpacing(1.25),
                          itemBuilder: (context, index) {
                            if (index == state.assets.length) {
                              if (state.loadMoreError != null) {
                                return Center(
                                  child: AppButton(
                                    text: 'Try loading more again',
                                    onPressed: ref
                                        .read(assetControllerProvider.notifier)
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
                            final asset = state.assets[index];
                            final url = asset.secureUrl?.trim();
                            return AssetTile(
                              asset: asset,
                              isUpdating: state.isUpdating(asset.id),
                              isDeleting: state.isDeleting(asset.id),
                              onEdit: () => _openAsset(context, ref, asset),
                              onDelete: () => _delete(context, ref, asset),
                              onOpenFile: url == null || url.isEmpty
                                  ? null
                                  : () => launchUrl(Uri.parse(url)),
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

  Future<void> _openAsset(
    BuildContext context,
    WidgetRef ref, [
    AssetItem? asset,
  ]) async {
    if (asset == null) {
      await showCreateAssetForm(context, ref);
      return;
    }
    final catalog = await ref.read(catalogControllerProvider.future);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AssetForm(
        catalog: catalog,
        asset: asset,
        onSubmit: (result) => ref
            .read(assetControllerProvider.notifier)
            .updateAsset(
              asset.id,
              UpdateAssetRequest(
                title: result.title,
                spaceId: result.spaceId,
                type: result.type,
                detail: result.detail,
                renewal: result.renewal,
                renewalDate: result.addToCalendar
                    ? '${result.renewal}T00:00:00.000Z'
                    : null,
                status: result.status,
              ),
            ),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AssetItem asset,
  ) async {
    if (!await confirmDelete(context, asset.title)) return;
    try {
      await ref.read(assetControllerProvider.notifier).deleteAsset(asset.id);
    } catch (error) {
      if (context.mounted) showFailure(context, error);
    }
  }
}

class _AssetFilters extends StatelessWidget {
  const _AssetFilters({
    required this.status,
    required this.type,
    required this.onStatusChanged,
    required this.onTypeChanged,
  });

  final String? status;
  final String? type;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onTypeChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
    child: Row(
      children: [
        for (final value in const <String?>[null, 'Hardware', 'License']) ...[
          ChoiceChip(
            label: AppText.raw(value ?? 'All types'),
            selected: type == value,
            onSelected: (_) => onTypeChanged(value),
          ),
          addHorizontalSpacing(2),
        ],
        const SizedBox(height: 28, child: VerticalDivider(width: 16)),
        for (final value in const <String?>[null, 'active', 'expiring']) ...[
          ChoiceChip(
            label: AppText.raw(value == null ? 'All statuses' : _title(value)),
            selected: status == value,
            onSelected: (_) => onStatusChanged(value),
          ),
          addHorizontalSpacing(2),
        ],
      ],
    ),
  );
}

class _AssetForm extends StatefulWidget {
  const _AssetForm({required this.catalog, required this.onSubmit, this.asset});

  final Catalog catalog;
  final Future<void> Function(_AssetFormValue value) onSubmit;
  final AssetItem? asset;

  @override
  State<_AssetForm> createState() => _AssetFormState();
}

class _AssetFormState extends State<_AssetForm> {
  final key = GlobalKey<FormState>();
  late final TextEditingController title;
  late final TextEditingController detail;
  late final TextEditingController renewal;
  String? spaceId;
  late String type;
  late String status;
  late bool addToCalendar;
  PickedAttachment? file;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final asset = widget.asset;
    title = TextEditingController(text: asset?.title);
    detail = TextEditingController(text: asset?.detail);
    renewal = TextEditingController(text: asset?.renewal.split('T').first);
    spaceId =
        asset?.spaceId ??
        (widget.catalog.spaces.isEmpty ? null : widget.catalog.spaces.first.id);
    type = asset?.type == 'License' ? 'License' : 'Hardware';
    status = asset?.status == 'expiring' ? 'expiring' : 'active';
    addToCalendar = asset?.renewalDate != null;
  }

  @override
  void dispose() {
    title.dispose();
    detail.dispose();
    renewal.dispose();
    super.dispose();
  }

  Future<void> _pickRenewal() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.tryParse(renewal.text) ?? DateTime.now(),
    );
    if (date != null) {
      renewal.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
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
              widget.asset == null ? 'Add asset' : 'Edit asset',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            addVerticalSpacing(2.25),
            GlobalTextField(
              fieldName: 'Asset name',
              keyBoardType: TextInputType.name,
              textController: title,
              removeSpace: false,
            ),
            addVerticalSpacing(1.5),
            GlobalSearchableDropdown<String>(
              title: 'Type',
              hintText: 'Choose asset type',
              value: type,
              options: const [
                SearchableDropdownOption(value: 'Hardware', label: 'Hardware'),
                SearchableDropdownOption(value: 'License', label: 'License'),
              ],
              onChanged: (value) => setState(() => type = value),
              showSearch: false,
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Details',
              keyBoardType: TextInputType.text,
              textController: detail,
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
              onChanged: (value) => setState(() => spaceId = value),
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Renewal / expiry date',
              keyBoardType: TextInputType.datetime,
              textController: renewal,
              readOnly: true,
              suffix: const Icon(Icons.calendar_today_outlined),
              onTap: _pickRenewal,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const AppText.raw('Add renewal to calendar'),
              value: addToCalendar,
              onChanged: (value) => setState(() => addToCalendar = value),
            ),
            if (widget.asset != null) ...[
              addVerticalSpacing(1),
              GlobalSearchableDropdown<String>(
                title: 'Status',
                hintText: 'Choose status',
                value: status,
                options: [
                  for (final value in const ['active', 'expiring'])
                    SearchableDropdownOption(
                      value: value,
                      label: _title(value),
                    ),
                ],
                onChanged: (value) => setState(() => status = value),
                showSearch: false,
              ),
            ],
            if (widget.asset == null) ...[
              addVerticalSpacing(1.5),
              AttachmentPickerField(
                value: file,
                maxFileSizeBytes: CreateAssetRequest.maxFileSizeBytes,
                onChanged: (value) => setState(() => file = value),
              ),
            ],
            addVerticalSpacing(2.25),
            AppButton(
              text: 'Save asset',
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

    setState(() => isSubmitting = true);
    try {
      await widget.onSubmit(
        _AssetFormValue(
          title: title.text,
          spaceId: spaceId!,
          type: type,
          detail: detail.text,
          renewal: renewal.text,
          status: status,
          addToCalendar: addToCalendar,
          file: file,
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

class _AssetFormValue {
  const _AssetFormValue({
    required this.title,
    required this.spaceId,
    required this.type,
    required this.detail,
    required this.renewal,
    required this.status,
    required this.addToCalendar,
    required this.file,
  });

  final String title;
  final String spaceId;
  final String type;
  final String detail;
  final String renewal;
  final String status;
  final bool addToCalendar;
  final PickedAttachment? file;
}

String _title(String value) => '${value[0].toUpperCase()}${value.substring(1)}';
