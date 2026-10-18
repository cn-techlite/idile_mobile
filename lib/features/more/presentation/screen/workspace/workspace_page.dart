import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/domain/entities/catalog/account_catalog.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/hearth_providers.dart';
import 'package:idile_mobile_app/features/more/domain/parameters/assets/create_asset_request.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/attachment_picker.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkspacePage extends ConsumerWidget {
  const WorkspacePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const AppText.raw('Workspace'),
      actions: const [
        Padding(padding: EdgeInsets.only(right: 12), child: SpaceSelector()),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      heroTag: 'workspace-add-fab',
      backgroundColor: AppColors.signal,
      foregroundColor: AppColors.ink,
      onPressed: () => _add(context, ref),
      icon: const Icon(Icons.add),
      label: const AppText.raw('Add asset'),
    ),
    body: ref
        .watch(workspaceControllerProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(
            error: e,
            onRetry: () => ref.invalidate(workspaceControllerProvider),
          ),
          data: (assets) => assets.isEmpty
              ? const EmptyState(
                  icon: Icons.laptop_mac_outlined,
                  title: 'No workspace assets',
                  message: 'Track hardware, licences and their renewal dates.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: assets.length,
                  separatorBuilder: (_, _) => addVerticalSpacing(1.25),
                  itemBuilder: (context, index) {
                    final asset = assets[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            asset.type == 'Hardware'
                                ? Icons.devices_other
                                : Icons.key_outlined,
                          ),
                        ),
                        title: AppText.raw(
                          asset.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: AppText.raw(
                          '${asset.type} · ${asset.detail}\nRenewal ${shortDate(asset.renewal)}',
                        ),
                        isThreeLine: true,
                        onTap: asset.secureUrl == null
                            ? null
                            : () => launchUrl(Uri.parse(asset.secureUrl!)),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'delete' &&
                                await confirmDelete(context, asset.title)) {
                              try {
                                await ref
                                    .read(workspaceControllerProvider.notifier)
                                    .remove(asset.id);
                              } catch (e) {
                                if (context.mounted) showFailure(context, e);
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: AppText.raw('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
  );
  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final catalog = await ref.read(catalogControllerProvider.future);
    if (!context.mounted) return;
    final result = await showModalBottomSheet<_UploadPayload>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AssetForm(catalog: catalog),
    );
    if (result == null) return;
    try {
      await ref
          .read(workspaceControllerProvider.notifier)
          .create(
            result.fields,
            bytes: await result.file?.readAsBytes(),
            fileName: result.file?.name,
          );
    } catch (e) {
      if (context.mounted) showFailure(context, e);
    }
  }
}

class _UploadPayload {
  const _UploadPayload(this.fields, this.file);
  final Map<String, String> fields;
  final PickedAttachment? file;
}

class _AssetForm extends StatefulWidget {
  const _AssetForm({required this.catalog});
  final Catalog catalog;
  @override
  State<_AssetForm> createState() => _AssetFormState();
}

class _AssetFormState extends State<_AssetForm> {
  final title = TextEditingController(),
      detail = TextEditingController(),
      renewal = TextEditingController();
  String type = 'Hardware';
  String? spaceId;
  PickedAttachment? file;
  final key = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    spaceId = widget.catalog.spaces.isEmpty
        ? null
        : widget.catalog.spaces.first.id;
  }

  @override
  void dispose() {
    title.dispose();
    detail.dispose();
    renewal.dispose();
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
              'Add workspace asset',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            addVerticalSpacing(1.75),
            GlobalTextField(
              fieldName: 'Name',
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
              fieldName: 'Renewal / warranty date',
              keyBoardType: TextInputType.datetime,
              textController: renewal,
              readOnly: true,
              suffix: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (d != null) {
                  renewal.text =
                      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                }
              },
            ),
            addVerticalSpacing(1.5),
            AttachmentPickerField(
              value: file,
              maxFileSizeBytes: CreateAssetRequest.maxFileSizeBytes,
              onChanged: (value) => setState(() => file = value),
            ),
            addVerticalSpacing(2),
            AppButton(
              text: 'Save asset',
              onPressed: () {
                if (!key.currentState!.validate() || spaceId == null) return;
                Navigator.pop(
                  context,
                  _UploadPayload({
                    'title': title.text.trim(),
                    'spaceId': spaceId!,
                    'type': type,
                    'detail': detail.text.trim(),
                    'renewal': renewal.text,
                  }, file),
                );
              },
              btnColor: AppColors.ink,
              textColor: AppColors.signal,
            ),
          ],
        ),
      ),
    ),
  );
}
