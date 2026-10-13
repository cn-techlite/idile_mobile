class CreateAssetRequest {
  const CreateAssetRequest({
    required this.title,
    required this.spaceId,
    required this.type,
    required this.detail,
    required this.renewal,
    this.renewalDate,
    this.fileBytes,
    this.fileName,
  });

  static const maxFileSizeBytes = 15 * 1024 * 1024;

  final String title;
  final String spaceId;
  final String type;
  final String detail;
  final String renewal;
  final String? renewalDate;
  final List<int>? fileBytes;
  final String? fileName;

  Map<String, String> toFields() {
    _validateFile();
    final normalizedRenewalDate = _optionalDateTime(renewalDate);
    return {
      'title': _required(title, 'title', 'Asset title'),
      'spaceId': _required(spaceId, 'spaceId', 'Space id'),
      'type': _assetType(type),
      'detail': _required(detail, 'detail', 'Asset detail'),
      'renewal': _date(renewal, 'renewal'),
      'renewalDate': ?normalizedRenewalDate,
    };
  }

  void _validateFile() {
    final hasBytes = fileBytes != null;
    final normalizedName = fileName?.trim();
    final hasName = normalizedName != null && normalizedName.isNotEmpty;
    if (hasBytes != hasName) {
      throw ArgumentError(
        'File bytes and file name must be supplied together.',
      );
    }
    if (fileBytes != null && fileBytes!.length > maxFileSizeBytes) {
      throw ArgumentError.value(
        fileBytes!.length,
        'fileBytes',
        'Asset file cannot exceed 15 MB.',
      );
    }
  }
}

String _required(String value, String name, String label) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(value, name, '$label cannot be empty.');
  }
  return normalized;
}

String _assetType(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized == 'hardware') return 'Hardware';
  if (normalized == 'license') return 'License';
  throw ArgumentError.value(value, 'type', 'Type must be Hardware or License.');
}

String _date(String value, String name) {
  final normalized = value.trim();
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(normalized) ||
      DateTime.tryParse(normalized) == null) {
    throw ArgumentError.value(value, name, 'Date must use YYYY-MM-DD.');
  }
  return normalized;
}

String? _optionalDateTime(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  if (DateTime.tryParse(normalized) == null) {
    throw ArgumentError.value(
      value,
      'renewalDate',
      'Renewal date must be a valid ISO date-time.',
    );
  }
  return normalized;
}
