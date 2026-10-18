class CreateHouseholdItemRequest {
  const CreateHouseholdItemRequest({
    required this.title,
    required this.spaceId,
    required this.room,
    required this.purchased,
    required this.warranty,
    required this.value,
    required this.currencyId,
    this.maintenanceId,
  });

  final String title;
  final String spaceId;
  final String room;
  final String purchased;
  final String warranty;
  final double value;
  final String currencyId;
  final String? maintenanceId;

  Map<String, dynamic> toJson() {
    if (!value.isFinite || value < 0) {
      throw ArgumentError.value(
        value,
        'value',
        'Household item value must be zero or greater.',
      );
    }
    final normalizedMaintenanceId = _optional(maintenanceId);
    return {
      'title': _required(title, 'title', 'Household item title'),
      'spaceId': _required(spaceId, 'spaceId', 'Space id'),
      'room': _required(room, 'room', 'Room'),
      'purchased': _date(purchased, 'purchased'),
      'warranty': _date(warranty, 'warranty'),
      'value': value,
      'currencyId': _required(currencyId, 'currencyId', 'Currency id'),
      'maintenanceId': ?normalizedMaintenanceId,
    };
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

String? _optional(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
