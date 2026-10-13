class CreateSubscriptionRequest {
  const CreateSubscriptionRequest({
    required this.title,
    required this.spaceId,
    required this.amount,
    required this.currencyId,
    required this.billing,
    required this.renewal,
    this.warning,
  });

  final String title;
  final String spaceId;
  final double amount;
  final String currencyId;
  final String billing;
  final String renewal;
  final String? warning;

  Map<String, dynamic> toJson() {
    if (!amount.isFinite || amount < 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Subscription amount must be zero or greater.',
      );
    }
    return {
      'title': _required(title, 'title', 'Subscription title'),
      'spaceId': _required(spaceId, 'spaceId', 'Space id'),
      'amount': amount,
      'currencyId': _required(currencyId, 'currencyId', 'Currency id'),
      'billing': _required(billing, 'billing', 'Billing cycle').toLowerCase(),
      'renewal': _date(renewal, 'renewal'),
      if (warning != null) 'warning': warning!.trim(),
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
