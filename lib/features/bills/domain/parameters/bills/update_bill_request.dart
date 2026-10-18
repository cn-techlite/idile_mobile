class UpdateBillRequest {
  const UpdateBillRequest({
    this.title,
    this.category,
    this.spaceId,
    this.amount,
    this.currencyId,
    this.due,
    this.recurrence,
  });

  final String? title;
  final String? category;
  final String? spaceId;
  final double? amount;
  final String? currencyId;
  final String? due;
  final String? recurrence;

  Map<String, dynamic> toJson() {
    if (title == null &&
        category == null &&
        spaceId == null &&
        amount == null &&
        currencyId == null &&
        due == null &&
        recurrence == null) {
      throw ArgumentError('At least one bill field must be supplied.');
    }
    final json = <String, dynamic>{};
    if (title != null) json['title'] = _required(title!, 'title', 'Bill title');
    if (category != null) {
      json['category'] = _required(category!, 'category', 'Category');
    }
    if (spaceId != null) {
      json['spaceId'] = _required(spaceId!, 'spaceId', 'Space id');
    }
    if (amount != null) {
      if (!amount!.isFinite || amount! < 0) {
        throw ArgumentError.value(
          amount,
          'amount',
          'Bill amount must be zero or greater.',
        );
      }
      json['amount'] = amount;
    }
    if (currencyId != null) {
      json['currencyId'] = _required(currencyId!, 'currencyId', 'Currency id');
    }
    if (due != null) json['due'] = _date(due!, 'due');
    if (recurrence != null) {
      json['recurrence'] = _required(
        recurrence!,
        'recurrence',
        'Recurrence',
      ).toLowerCase();
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
  final parsed = DateTime.tryParse(normalized);
  if (parsed == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(normalized)) {
    throw ArgumentError.value(value, name, 'Date must use YYYY-MM-DD.');
  }
  return normalized;
}
