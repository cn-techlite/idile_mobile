import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/features/account/data/model/catalog/account_catalog.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/hearth_providers.dart';
import 'package:idile_mobile_app/features/more/data/dto/documents/create_document_request.dart';
import 'package:idile_mobile_app/features/more/data/dto/documents/update_document_request.dart';
import 'package:idile_mobile_app/features/more/data/model/documents/document_item.dart';
import 'package:idile_mobile_app/features/more/presentation/state/providers/document_provider.dart';
import 'package:idile_mobile_app/features/more/presentation/widget/document_tile.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/attachment_picker.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showCreateDocumentForm(BuildContext context, WidgetRef ref) async {
  final catalog = await ref.read(catalogControllerProvider.future);
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _DocumentForm(
      catalog: catalog,
      onSubmit: (result) async {
        await ref
            .read(documentControllerProvider.notifier)
            .createDocument(
              CreateDocumentRequest(
                title: result.title,
                spaceId: result.spaceId,
                type: result.type,
                expiry: result.expiry,
                related: result.related,
                householdItemId: result.householdItemId,
                assetId: result.assetId,
                fileBytes: await result.file?.readAsBytes(),
                fileName: result.file?.name,
              ),
            );
      },
    ),
  );
}

class DocumentsPage extends ConsumerWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(documentControllerProvider);
    final value = documents.value;
    return Scaffold(
      appBar: AppBar(
        title: const AppText.raw('Documents'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: SpaceSelector()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'documents-add-fab',
        backgroundColor: AppColors.signal,
        foregroundColor: AppColors.ink,
        onPressed: value?.isCreating == true
            ? null
            : () => _openDocument(context, ref),
        icon: value?.isCreating == true
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: const AppText.raw('Add document'),
      ),
      body: Column(
        children: [
          _DocumentFilters(
            status: value?.statusFilter,
            type: value?.typeFilter,
            onStatusChanged: ref
                .read(documentControllerProvider.notifier)
                .setStatus,
            onTypeChanged: ref
                .read(documentControllerProvider.notifier)
                .setType,
          ),
          Expanded(
            child: documents.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () => ref.invalidate(documentControllerProvider),
              ),
              data: (state) => state.documents.isEmpty
                  ? const EmptyState(
                      icon: Icons.description_outlined,
                      title: 'No documents',
                      message:
                          'Store receipts, warranties and important records.',
                    )
                  : RefreshIndicator(
                      onRefresh: ref
                          .read(documentControllerProvider.notifier)
                          .refreshDocuments,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 300) {
                            ref
                                .read(documentControllerProvider.notifier)
                                .loadMore();
                          }
                          return false;
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount:
                              state.documents.length +
                              (state.hasNextPage || state.loadMoreError != null
                                  ? 1
                                  : 0),
                          separatorBuilder: (_, _) => addVerticalSpacing(1.25),
                          itemBuilder: (context, index) {
                            if (index == state.documents.length) {
                              if (state.loadMoreError != null) {
                                return Center(
                                  child: AppButton(
                                    text: 'Try loading more again',
                                    onPressed: ref
                                        .read(
                                          documentControllerProvider.notifier,
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
                            final document = state.documents[index];
                            final url = document.secureUrl?.trim();
                            return DocumentTile(
                              document: document,
                              isUpdating: state.isUpdating(document.id),
                              isDeleting: state.isDeleting(document.id),
                              onEdit: () =>
                                  _openDocument(context, ref, document),
                              onDelete: () => _delete(context, ref, document),
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

  Future<void> _openDocument(
    BuildContext context,
    WidgetRef ref, [
    DocumentItem? document,
  ]) async {
    if (document == null) {
      await showCreateDocumentForm(context, ref);
      return;
    }
    final catalog = await ref.read(catalogControllerProvider.future);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _DocumentForm(
        catalog: catalog,
        document: document,
        onSubmit: (result) => ref
            .read(documentControllerProvider.notifier)
            .updateDocument(
              document.id,
              UpdateDocumentRequest(
                title: result.title,
                spaceId: result.spaceId,
                type: result.type,
                expiry: result.expiry,
                related: result.related,
                householdItemId: result.householdItemId,
                assetId: result.assetId,
                status: result.status,
              ),
            ),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    DocumentItem document,
  ) async {
    if (!await confirmDelete(context, document.title)) return;
    try {
      await ref
          .read(documentControllerProvider.notifier)
          .deleteDocument(document.id);
    } catch (error) {
      if (context.mounted) showFailure(context, error);
    }
  }
}

class _DocumentFilters extends StatelessWidget {
  const _DocumentFilters({
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
        for (final value in <String?>[null, ...documentTypes]) ...[
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

class _DocumentForm extends StatefulWidget {
  const _DocumentForm({
    required this.catalog,
    required this.onSubmit,
    this.document,
  });

  final Catalog catalog;
  final Future<void> Function(_DocumentFormValue value) onSubmit;
  final DocumentItem? document;

  @override
  State<_DocumentForm> createState() => _DocumentFormState();
}

class _DocumentFormState extends State<_DocumentForm> {
  final key = GlobalKey<FormState>();
  late final TextEditingController title;
  late final TextEditingController expiry;
  late final TextEditingController related;
  late final TextEditingController householdItemId;
  late final TextEditingController assetId;
  String? spaceId;
  late String type;
  late String status;
  PickedAttachment? file;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final document = widget.document;
    title = TextEditingController(text: document?.title);
    expiry = TextEditingController(text: document?.expiry.split('T').first);
    related = TextEditingController(text: document?.related);
    householdItemId = TextEditingController(text: document?.householdItemId);
    assetId = TextEditingController(text: document?.assetId);
    spaceId =
        document?.spaceId ??
        (widget.catalog.spaces.isEmpty ? null : widget.catalog.spaces.first.id);
    type = documentTypes.contains(document?.type)
        ? document!.type
        : documentTypes.first;
    status = document?.status == 'expiring' ? 'expiring' : 'active';
  }

  @override
  void dispose() {
    title.dispose();
    expiry.dispose();
    related.dispose();
    householdItemId.dispose();
    assetId.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.tryParse(expiry.text) ?? DateTime.now(),
    );
    if (date != null) {
      expiry.text =
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
              widget.document == null ? 'Add document' : 'Edit document',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            addVerticalSpacing(2.25),
            GlobalTextField(
              fieldName: 'Document name',
              keyBoardType: TextInputType.name,
              textController: title,
              removeSpace: false,
            ),
            addVerticalSpacing(1.5),
            GlobalSearchableDropdown<String>(
              title: 'Type',
              hintText: 'Choose document type',
              value: type,
              options: [
                for (final value in documentTypes)
                  SearchableDropdownOption(value: value, label: value),
              ],
              onChanged: (value) => setState(() => type = value),
              showSearch: false,
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
              fieldName: 'Related item (optional)',
              keyBoardType: TextInputType.text,
              textController: related,
              removeSpace: false,
              isOptional: true,
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Expiry (optional)',
              keyBoardType: TextInputType.datetime,
              textController: expiry,
              readOnly: true,
              isOptional: true,
              suffix: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (expiry.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear expiry',
                      onPressed: () => setState(expiry.clear),
                      icon: const Icon(Icons.clear),
                    ),
                  const Icon(Icons.calendar_today_outlined),
                ],
              ),
              onTap: _pickExpiry,
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Household item ID (optional)',
              keyBoardType: TextInputType.text,
              textController: householdItemId,
              removeSpace: false,
              isOptional: true,
            ),
            addVerticalSpacing(1.5),
            GlobalTextField(
              fieldName: 'Asset ID (optional)',
              keyBoardType: TextInputType.text,
              textController: assetId,
              removeSpace: false,
              isOptional: true,
            ),
            if (widget.document != null) ...[
              addVerticalSpacing(1.5),
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
            if (widget.document == null) ...[
              addVerticalSpacing(1.5),
              AttachmentPickerField(
                value: file,
                maxFileSizeBytes: CreateDocumentRequest.maxFileSizeBytes,
                onChanged: (value) => setState(() => file = value),
              ),
            ],
            addVerticalSpacing(2.25),
            AppButton(
              text: 'Save document',
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
        _DocumentFormValue(
          title: title.text,
          spaceId: spaceId!,
          type: type,
          expiry: expiry.text,
          related: related.text,
          householdItemId: householdItemId.text,
          assetId: assetId.text,
          status: status,
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

class _DocumentFormValue {
  const _DocumentFormValue({
    required this.title,
    required this.spaceId,
    required this.type,
    required this.expiry,
    required this.related,
    required this.householdItemId,
    required this.assetId,
    required this.status,
    required this.file,
  });

  final String title;
  final String spaceId;
  final String type;
  final String expiry;
  final String related;
  final String householdItemId;
  final String assetId;
  final String status;
  final PickedAttachment? file;
}

String _title(String value) => '${value[0].toUpperCase()}${value.substring(1)}';
