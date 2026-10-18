class Space {
  const Space({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
    this.itemCount = 0,
  });

  factory Space.fromJson(Map<String, dynamic> json) => Space(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    userId: (json['userId'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    icon: (json['icon'] ?? 'home').toString(),
    itemCount: _integer(json['itemCount']),
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );

  final String id;
  final String userId;
  final String name;
  final String icon;
  final int itemCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Space copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    int? itemCount,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) => Space(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    itemCount: itemCount ?? this.itemCount,
    createdAt: identical(createdAt, _unset)
        ? this.createdAt
        : createdAt as DateTime?,
    updatedAt: identical(updatedAt, _unset)
        ? this.updatedAt
        : updatedAt as DateTime?,
  );
}

class SpaceSummary {
  const SpaceSummary({
    required this.counts,
    required this.attention,
    required this.spendByCurrency,
  });

  factory SpaceSummary.fromJson(Map<String, dynamic> json) {
    final countsJson = json['counts'] is Map
        ? Map<String, dynamic>.from(json['counts'] as Map)
        : const <String, dynamic>{};
    return SpaceSummary(
      counts: countsJson.map((key, value) => MapEntry(key, _integer(value))),
      attention: SpaceAttention.fromJson(
        json['attention'] is Map
            ? Map<String, dynamic>.from(json['attention'] as Map)
            : const <String, dynamic>{},
      ),
      spendByCurrency: (json['spendByCurrency'] as List? ?? const [])
          .map(
            (value) =>
                SpaceSpend.fromJson(Map<String, dynamic>.from(value as Map)),
          )
          .toList(growable: false),
    );
  }

  final Map<String, int> counts;
  final SpaceAttention attention;
  final List<SpaceSpend> spendByCurrency;
}

class SpaceAttention {
  const SpaceAttention({
    this.bills = const [],
    this.subscriptions = const [],
    this.maintenance = const [],
    this.assets = const [],
    this.documents = const [],
  });

  factory SpaceAttention.fromJson(Map<String, dynamic> json) => SpaceAttention(
    bills: _attentionItems(json['bills']),
    subscriptions: _attentionItems(json['subscriptions']),
    maintenance: _attentionItems(json['maintenance']),
    assets: _attentionItems(json['assets']),
    documents: _attentionItems(json['documents']),
  );

  final List<SpaceAttentionItem> bills;
  final List<SpaceAttentionItem> subscriptions;
  final List<SpaceAttentionItem> maintenance;
  final List<SpaceAttentionItem> assets;
  final List<SpaceAttentionItem> documents;

  List<({String label, List<SpaceAttentionItem> items})> get sections => [
    (label: 'Bills', items: bills),
    (label: 'Subscriptions', items: subscriptions),
    (label: 'Maintenance', items: maintenance),
    (label: 'Assets', items: assets),
    (label: 'Documents', items: documents),
  ];
}

class SpaceAttentionItem {
  const SpaceAttentionItem({
    required this.id,
    required this.title,
    required this.status,
    required this.raw,
  });

  factory SpaceAttentionItem.fromJson(Map<String, dynamic> json) =>
      SpaceAttentionItem(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        title: (json['title'] ?? json['name'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        raw: Map.unmodifiable(json),
      );

  final String id;
  final String title;
  final String status;
  final Map<String, dynamic> raw;
}

class SpaceSpend {
  const SpaceSpend({required this.currencyId, required this.total});

  factory SpaceSpend.fromJson(Map<String, dynamic> json) => SpaceSpend(
    currencyId: (json['currencyId'] ?? '').toString(),
    total: _number(json['total']),
  );

  final String currencyId;
  final double total;
}

List<SpaceAttentionItem> _attentionItems(Object? value) =>
    (value as List? ?? const [])
        .map(
          (item) => SpaceAttentionItem.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);

int _integer(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
double _number(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
DateTime? _date(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());

const _unset = Object();
