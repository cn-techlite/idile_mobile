class Currency {
  const Currency({
    required this.id,
    required this.userId,
    required this.name,
    required this.country,
    required this.flagUrl,
    required this.symbol,
    required this.createdAt,
    required this.updatedAt,
    this.itemCount = 0,
  });

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    userId: (json['userId'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    country: (json['country'] ?? '').toString(),
    flagUrl: (json['flagUrl'] ?? '').toString(),
    symbol: (json['symbol'] ?? '').toString(),
    itemCount: _integer(json['itemCount']),
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );

  final String id;
  final String userId;
  final String name;
  final String country;
  final String flagUrl;
  final String symbol;
  final int itemCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Currency copyWith({
    String? id,
    String? userId,
    String? name,
    String? country,
    String? flagUrl,
    String? symbol,
    int? itemCount,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) => Currency(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    country: country ?? this.country,
    flagUrl: flagUrl ?? this.flagUrl,
    symbol: symbol ?? this.symbol,
    itemCount: itemCount ?? this.itemCount,
    createdAt: identical(createdAt, _unset)
        ? this.createdAt
        : createdAt as DateTime?,
    updatedAt: identical(updatedAt, _unset)
        ? this.updatedAt
        : updatedAt as DateTime?,
  );
}

int _integer(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
DateTime? _date(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());

const _unset = Object();
