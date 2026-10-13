class CreateCurrencyRequest {
  const CreateCurrencyRequest({
    required this.name,
    required this.country,
    required this.flagUrl,
    required this.symbol,
  });

  final String name;
  final String country;
  final String flagUrl;
  final String symbol;

  Map<String, dynamic> toJson() {
    final normalizedName = _required(name, 'name');
    final normalizedCountry = _required(country, 'country');
    final normalizedFlagUrl = _required(flagUrl, 'flagUrl');
    final normalizedSymbol = _required(symbol, 'symbol');
    _validateUrl(normalizedFlagUrl);
    return {
      'name': normalizedName,
      'country': normalizedCountry,
      'flagUrl': normalizedFlagUrl,
      'symbol': normalizedSymbol,
    };
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
