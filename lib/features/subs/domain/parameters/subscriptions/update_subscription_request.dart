class UpdateSubscriptionRequest {
  const UpdateSubscriptionRequest({
    this.title,
    this.spaceId,
    this.amount,
    this.currencyId,
    this.billing,
    this.renewal,
    this.warning,
    this.status,
  });

  static const statuses = {'active', 'trial', 'paused', 'cancelled'};

  final String? title;
  final String? spaceId;
  final double? amount;
  final String? currencyId;
  final String? billing;
  final String? renewal;
  final String? warning;
  final String? status;

  Map<String, dynamic> toJson() {
    if (title == null &&
        spaceId == null &&
        amount == null &&
        currencyId == null &&
        billing == null &&
        renewal == null &&
        warning == null &&
        status == null) {
      throw ArgumentError('At least one subscription field must be supplied.');
    }
    final json = <String, dynamic>{};
    if (title != null) {
      json['title'] = _required(title!, 'title', 'Subscription title');
    }
    if (spaceId != null) {
      json['spaceId'] = _required(spaceId!, 'spaceId', 'Space id');
    }
    if (amount != null) {
      if (!amount!.isFinite || amount! < 0) {
        throw ArgumentError.value(
          amount,
          'amount',
          'Subscription amount must be zero or greater.',
        );
      }
      json['amount'] = amount;
    }
    if (currencyId != null) {
      json['currencyId'] = _required(currencyId!, 'currencyId', 'Currency id');
    }
    if (billing != null) {
      json['billing'] = _required(
        billing!,
        'billing',
        'Billing cycle',
      ).toLowerCase();
    }
    if (renewal != null) json['renewal'] = _date(renewal!, 'renewal');
    if (warning != null) json['warning'] = warning!.trim();
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
