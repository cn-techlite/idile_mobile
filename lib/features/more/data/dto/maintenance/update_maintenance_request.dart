class UpdateMaintenanceRequest {
  const UpdateMaintenanceRequest({
    this.title,
    this.spaceId,
    this.item,
    this.lastDone,
    this.nextDue,
    this.intervalMonths,
    this.status,
  });

  static const statuses = {'due', 'soon', 'scheduled'};

  final String? title;
  final String? spaceId;
  final String? item;
  final String? lastDone;
  final String? nextDue;
  final int? intervalMonths;
  final String? status;

  Map<String, dynamic> toJson() {
    if (title == null &&
        spaceId == null &&
        item == null &&
        lastDone == null &&
        nextDue == null &&
        intervalMonths == null &&
        status == null) {
      throw ArgumentError('At least one maintenance field must be supplied.');
    }
    final json = <String, dynamic>{};
    if (title != null) {
      json['title'] = _required(title!, 'title', 'Maintenance title');
    }
    if (spaceId != null) {
      json['spaceId'] = _required(spaceId!, 'spaceId', 'Space id');
    }
    if (item != null) {
      json['item'] = _required(item!, 'item', 'Maintenance item');
    }
    if (lastDone != null) json['lastDone'] = _date(lastDone!, 'lastDone');
    if (nextDue != null) json['nextDue'] = _date(nextDue!, 'nextDue');
    if (intervalMonths != null) {
      if (intervalMonths! < 1) {
        throw ArgumentError.value(
          intervalMonths,
          'intervalMonths',
          'Maintenance interval must be at least one month.',
        );
      }
      json['intervalMonths'] = intervalMonths;
    }
    if (status != null) {
      final normalizedStatus = status!.trim().toLowerCase();
      if (!statuses.contains(normalizedStatus)) {
        throw ArgumentError.value(status, 'status', 'Unsupported status.');
      }
      json['status'] = normalizedStatus;
    }
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

String _date(String value, String name) {
  final normalized = value.trim();
  if (DateTime.tryParse(normalized) == null ||
      !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(normalized)) {
    throw ArgumentError.value(value, name, 'Date must use YYYY-MM-DD.');
  }
  return normalized;
}
