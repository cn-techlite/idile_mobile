import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:image_picker/image_picker.dart';

/// A file selected from the camera, photo library, or device file browser.
final class PickedAttachment {
  const PickedAttachment._({
    required this.name,
    required this.size,
    required this._readAsBytes,
  });

  final String name;
  final int? size;
  final Future<Uint8List> Function() _readAsBytes;

  Future<Uint8List> readAsBytes() => _readAsBytes();
}

enum _AttachmentSource { camera, gallery, files }

Future<PickedAttachment?> showAttachmentPicker(
  BuildContext context, {
  required int maxFileSizeBytes,
  List<String>? allowedExtensions,
}) async {
  try {
    final source = await showModalBottomSheet<_AttachmentSource>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => const _AttachmentSourceSheet(),
    );
    if (source == null || !context.mounted) return null;

    final attachment = await _pickFrom(
      source,
      allowedExtensions: allowedExtensions,
    );
    if (attachment == null || !context.mounted) return null;

    final size = attachment.size;
    if (size != null && size > maxFileSizeBytes) {
      _showPickerError(
        context,
        'Attachment cannot exceed ${_megabytes(maxFileSizeBytes)} MB.',
      );
      return null;
    }
    if (allowedExtensions != null &&
        !_hasAllowedExtension(attachment.name, allowedExtensions)) {
      _showPickerError(
        context,
        'Choose a ${allowedExtensions.map((value) => value.toUpperCase()).join(', ')} file.',
      );
      return null;
    }
    return attachment;
  } catch (_) {
    if (context.mounted) {
      _showPickerError(
        context,
        'Could not access that attachment. Check the app permission and try again.',
      );
    }
    return null;
  }
}

Future<PickedAttachment?> _pickFrom(
  _AttachmentSource source, {
  List<String>? allowedExtensions,
}) async {
  if (source == _AttachmentSource.files) {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Choose an attachment',
      type: allowedExtensions == null ? FileType.any : FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (file == null) return null;
    return PickedAttachment._(
      name: file.name,
      size: file.lengthSync() ?? await file.length(),
      readAsBytes: file.readAsBytes,
    );
  }

  final file = await ImagePicker().pickImage(
    source: source == _AttachmentSource.camera
        ? ImageSource.camera
        : ImageSource.gallery,
    imageQuality: 92,
    requestFullMetadata: false,
  );
  if (file == null) return null;
  return PickedAttachment._(
    name: file.name,
    size: await file.length(),
    readAsBytes: file.readAsBytes,
  );
}

bool _hasAllowedExtension(String name, List<String> allowedExtensions) {
  final separator = name.lastIndexOf('.');
  if (separator < 0 || separator == name.length - 1) return false;
  final extension = name.substring(separator + 1).toLowerCase();
  return allowedExtensions.any((allowed) => allowed.toLowerCase() == extension);
}

String _megabytes(int bytes) {
  final value = bytes / (1024 * 1024);
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

void _showPickerError(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: AppText.raw(message)));
}

/// Shared attachment field used by forms that accept an optional upload.
class AttachmentPickerField extends StatelessWidget {
  const AttachmentPickerField({
    required this.value,
    required this.onChanged,
    required this.maxFileSizeBytes,
    this.allowedExtensions,
    super.key,
  });

  final PickedAttachment? value;
  final ValueChanged<PickedAttachment?> onChanged;
  final int maxFileSizeBytes;
  final List<String>? allowedExtensions;

  Future<void> _pick(BuildContext context) async {
    final attachment = await showAttachmentPicker(
      context,
      maxFileSizeBytes: maxFileSizeBytes,
      allowedExtensions: allowedExtensions,
    );
    if (attachment != null) onChanged(attachment);
  }

  @override
  Widget build(BuildContext context) {
    final attachment = value;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          text: attachment == null
              ? 'Take photo or choose file'
              : 'Change attachment',
          onPressed: () => _pick(context),
          icon: const Icon(Icons.add_a_photo_outlined),
          variant: AppButtonVariant.outlined,
        ),
        if (attachment != null) ...[
          addVerticalSpacing(1),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.attachment_outlined, color: colors.onSurfaceVariant),
                addHorizontalSpacing(2.5),
                Expanded(
                  child: AppText.raw(
                    attachment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove attachment',
                  onPressed: () => onChanged(null),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AttachmentSourceSheet extends StatelessWidget {
  const _AttachmentSourceSheet();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.raw(
          'Add attachment',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        addVerticalSpacing(0.5),
        AppText.raw(
          'Take a new photo or choose something already on this device.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        addVerticalSpacing(1.5),
        _AttachmentSourceTile(
          icon: Icons.camera_alt_outlined,
          title: 'Take a photo',
          subtitle: 'Open the camera and snap it now',
          onTap: () => Navigator.pop(context, _AttachmentSource.camera),
        ),
        addVerticalSpacing(1),
        _AttachmentSourceTile(
          icon: Icons.photo_library_outlined,
          title: 'Choose a photo',
          subtitle: 'Pick an existing image from your gallery',
          onTap: () => Navigator.pop(context, _AttachmentSource.gallery),
        ),
        addVerticalSpacing(1),
        _AttachmentSourceTile(
          icon: Icons.folder_open_outlined,
          title: 'Browse files',
          subtitle: 'Choose a PDF, image, or another file',
          onTap: () => Navigator.pop(context, _AttachmentSource.files),
        ),
      ],
    ),
  );
}

class _AttachmentSourceTile extends StatelessWidget {
  const _AttachmentSourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: colors.primary),
        title: AppText.raw(title),
        subtitle: AppText.raw(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
