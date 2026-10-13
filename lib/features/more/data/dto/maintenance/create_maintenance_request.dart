class CreateMaintenanceRequest {
  const CreateMaintenanceRequest({
    required this.title,
    required this.spaceId,
    required this.item,
    required this.lastDone,
    required this.nextDue,
    this.intervalMonths = 3,
  });

  final String title;
  final String spaceId;
  final String item;
  final String lastDone;
  final String nextDue;
  final int intervalMonths;

  Map<String, dynamic> toJson() {
    if (intervalMonths < 1) {
      throw ArgumentError.value(
        intervalMonths,
        'intervalMonths',
        'Maintenance interval must be at least one month.',
      );
    }
    return {
      'title': _required(title, 'title', 'Maintenance title'),
      'spaceId': _required(spaceId, 'spaceId', 'Space id'),
      'item': _required(item, 'item', 'Maintenance item'),
      'lastDone': _date(lastDone, 'lastDone'),
      'nextDue': _date(nextDue, 'nextDue'),
      'intervalMonths': intervalMonths,
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
