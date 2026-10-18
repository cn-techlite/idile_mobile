class CreateBillRequest {
  const CreateBillRequest({
    required this.title,
    required this.category,
    required this.spaceId,
    required this.amount,
    required this.currencyId,
    required this.due,
    required this.recurrence,
  });

  final String title;
  final String category;
  final String spaceId;
  final double amount;
  final String currencyId;
  final String due;
  final String recurrence;

  Map<String, dynamic> toJson() {
    final normalizedTitle = _required(title, 'title', 'Bill title');
    final normalizedCategory = _required(category, 'category', 'Category');
    final normalizedSpaceId = _required(spaceId, 'spaceId', 'Space id');
    final normalizedCurrencyId = _required(
      currencyId,
      'currencyId',
      'Currency id',
    );
    final normalizedDue = _date(due, 'due');
    final normalizedRecurrence = _required(
      recurrence,
      'recurrence',
      'Recurrence',
    ).toLowerCase();
    if (!amount.isFinite || amount < 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Bill amount must be zero or greater.',
      );
    }
    return {
      'title': normalizedTitle,
      'category': normalizedCategory,
      'spaceId': normalizedSpaceId,
      'amount': amount,
      'currencyId': normalizedCurrencyId,
      'due': normalizedDue,
      'recurrence': normalizedRecurrence,
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
  final parsed = DateTime.tryParse(normalized);
  if (parsed == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(normalized)) {
    throw ArgumentError.value(value, name, 'Date must use YYYY-MM-DD.');
  }
  return normalized;
}
