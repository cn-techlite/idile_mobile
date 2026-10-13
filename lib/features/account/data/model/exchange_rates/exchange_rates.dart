class ExchangeRates {
  const ExchangeRates({
    required this.id,
    required this.baseCode,
    required this.rates,
    required this.fetchedAt,
    required this.nextUpdateAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExchangeRates.fromJson(Map<String, dynamic> json) => ExchangeRates(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    baseCode: (json['baseCode'] ?? '').toString(),
    rates: Map<String, double>.unmodifiable(
      (json['rates'] is Map ? json['rates'] as Map : const {}).map(
        (key, value) => MapEntry(
          key.toString(),
          value is num ? value.toDouble() : double.tryParse('$value') ?? 0,
        ),
      ),
    ),
    fetchedAt: _date(json['fetchedAt']),
    nextUpdateAt: _date(json['nextUpdateAt']),
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );

  final String id;
  final String baseCode;
  final Map<String, double> rates;
  final DateTime? fetchedAt;
  final DateTime? nextUpdateAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  double? rateFor(String currencyCode) =>
      rates[currencyCode.trim().toUpperCase()];
}

DateTime? _date(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());
