class UpdateHouseholdItemRequest {
  const UpdateHouseholdItemRequest({
    this.title,
    this.spaceId,
    this.room,
    this.purchased,
    this.warranty,
    this.value,
    this.currencyId,
    this.maintenanceId,
  });

  final String? title;
  final String? spaceId;
  final String? room;
  final String? purchased;
  final String? warranty;
  final double? value;
  final String? currencyId;
  final String? maintenanceId;

  Map<String, dynamic> toJson() {
    if (title == null &&
        spaceId == null &&
        room == null &&
        purchased == null &&
        warranty == null &&
        value == null &&
        currencyId == null &&
        maintenanceId == null) {
      throw ArgumentError(
        'At least one household item field must be supplied.',
      );
    }
    final json = <String, dynamic>{};
    if (title != null) {
      json['title'] = _required(title!, 'title', 'Household item title');
    }
    if (spaceId != null) {
      json['spaceId'] = _required(spaceId!, 'spaceId', 'Space id');
    }
    if (room != null) json['room'] = _required(room!, 'room', 'Room');
    if (purchased != null) json['purchased'] = _date(purchased!, 'purchased');
    if (warranty != null) json['warranty'] = _date(warranty!, 'warranty');
    if (value != null) {
      if (!value!.isFinite || value! < 0) {
        throw ArgumentError.value(
          value,
          'value',
          'Household item value must be zero or greater.',
        );
      }
      json['value'] = value;
    }
    if (currencyId != null) {
      json['currencyId'] = _required(currencyId!, 'currencyId', 'Currency id');
    }
    if (maintenanceId != null) {
      json['maintenanceId'] = maintenanceId!.trim();
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
