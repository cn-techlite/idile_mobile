class Category {
  const Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.itemCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    userId: (json['userId'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    itemCount: _integer(json['itemCount']),
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );

  final String id;
  final String userId;
  final String name;
  final int itemCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category copyWith({
    String? id,
    String? userId,
    String? name,
    int? itemCount,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) => Category(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
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
