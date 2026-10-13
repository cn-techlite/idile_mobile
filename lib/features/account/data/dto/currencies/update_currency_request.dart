class UpdateCurrencyRequest {
  const UpdateCurrencyRequest({
    this.name,
    this.country,
    this.flagUrl,
    this.symbol,
  });

  final String? name;
  final String? country;
  final String? flagUrl;
  final String? symbol;

  Map<String, dynamic> toJson() {
    if (name == null && country == null && flagUrl == null && symbol == null) {
      throw ArgumentError('At least one currency field must be supplied.');
    }
    final json = <String, dynamic>{};
    if (name != null) json['name'] = _required(name!, 'name');
    if (country != null) json['country'] = _required(country!, 'country');
    if (flagUrl != null) {
      final value = _required(flagUrl!, 'flagUrl');
      _validateUrl(value);
      json['flagUrl'] = value;
    }
    if (symbol != null) json['symbol'] = _required(symbol!, 'symbol');
    return json;
  }
}

String _required(String value, String field) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(value, field, '$field cannot be empty.');
  }
  return normalized;
}

void _validateUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null ||
      !const {'http', 'https'}.contains(uri.scheme) ||
      uri.host.isEmpty) {
    throw ArgumentError.value(value, 'flagUrl', 'Enter a valid flag URL.');
  }
}
