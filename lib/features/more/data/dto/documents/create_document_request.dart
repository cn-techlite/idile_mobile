class CreateDocumentRequest {
  const CreateDocumentRequest({
    required this.title,
    required this.spaceId,
    required this.type,
    this.expiry = '',
    this.related = '',
    this.householdItemId = '',
    this.assetId = '',
    this.fileBytes,
    this.fileName,
  });

  static const maxFileSizeBytes = 15 * 1024 * 1024;

  final String title;
  final String spaceId;
  final String type;
  final String expiry;
  final String related;
  final String householdItemId;
  final String assetId;
  final List<int>? fileBytes;
  final String? fileName;

  Map<String, String> toFields() {
    _validateFile();
    return {
      'title': _required(title, 'title', 'Document title'),
      'spaceId': _required(spaceId, 'spaceId', 'Space id'),
      'type': documentType(type),
      'expiry': optionalDocumentDate(expiry, 'expiry'),
      'related': related.trim(),
      'householdItemId': householdItemId.trim(),
      'assetId': assetId.trim(),
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
        'Document file cannot exceed 15 MB.',
      );
    }
  }
}

const documentTypes = <String>[
  'Receipt',
  'Warranty',
  'Insurance',
  'Lease',
  'Certificate',
];

String requiredDocumentText(String value, String name, String label) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(value, name, '$label cannot be empty.');
  }
  return normalized;
}

String documentType(String value) {
  final normalized = value.trim().toLowerCase();
  for (final type in documentTypes) {
    if (type.toLowerCase() == normalized) return type;
  }
  throw ArgumentError.value(
    value,
    'type',
    'Type must be Receipt, Warranty, Insurance, Lease or Certificate.',
  );
}

String optionalDocumentDate(String value, String name) {
  final normalized = value.trim();
  if (normalized.isEmpty) return '';
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(normalized) ||
      DateTime.tryParse(normalized) == null) {
    throw ArgumentError.value(value, name, 'Date must use YYYY-MM-DD.');
  }
  return normalized;
}

String _required(String value, String name, String label) =>
    requiredDocumentText(value, name, label);
