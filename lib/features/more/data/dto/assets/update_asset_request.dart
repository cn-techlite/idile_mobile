class UpdateAssetRequest {
  const UpdateAssetRequest({
    this.title,
    this.spaceId,
    this.type,
    this.detail,
    this.renewal,
    this.renewalDate,
    this.status,
  });

  final String? title;
  final String? spaceId;
  final String? type;
  final String? detail;
  final String? renewal;
  final String? renewalDate;
  final String? status;

  Map<String, dynamic> toJson() {
    if (title == null &&
        spaceId == null &&
        type == null &&
        detail == null &&
        renewal == null &&
        renewalDate == null &&
        status == null) {
      throw ArgumentError('At least one asset field must be supplied.');
    }
    final json = <String, dynamic>{};
    if (title != null) {
      json['title'] = _required(title!, 'title', 'Asset title');
    }
    if (spaceId != null) {
      json['spaceId'] = _required(spaceId!, 'spaceId', 'Space id');
    }
    if (type != null) json['type'] = _assetType(type!);
    if (detail != null) {
      json['detail'] = _required(detail!, 'detail', 'Asset detail');
    }
    if (renewal != null) json['renewal'] = _date(renewal!, 'renewal');
    if (renewalDate != null) {
      json['renewalDate'] = _dateTime(renewalDate!);
    }
    if (status != null) json['status'] = _status(status!);
    return json;
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

String _dateTime(String value) {
  final normalized = value.trim();
  if (DateTime.tryParse(normalized) == null) {
    throw ArgumentError.value(
      value,
      'renewalDate',
      'Renewal date must be a valid ISO date-time.',
    );
  }
  return normalized;
}

String _status(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized != 'active' && normalized != 'expiring') {
    throw ArgumentError.value(
      value,
      'status',
      'Status must be active or expiring.',
    );
  }
  return normalized;
}
