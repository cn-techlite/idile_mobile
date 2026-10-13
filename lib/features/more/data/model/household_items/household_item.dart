class HouseholdItem {
  const HouseholdItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.spaceId,
    required this.room,
    required this.purchased,
    required this.warranty,
    required this.value,
    required this.currencyId,
    required this.createdAt,
    required this.updatedAt,
    this.maintenanceId,
  });

  factory HouseholdItem.fromJson(Map<String, dynamic> json) => HouseholdItem(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    userId: (json['userId'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    spaceId: (json['spaceId'] ?? '').toString(),
    room: (json['room'] ?? '').toString(),
    purchased: (json['purchased'] ?? '').toString(),
    warranty: (json['warranty'] ?? '').toString(),
    value: json['value'] is num
        ? (json['value'] as num).toDouble()
        : double.tryParse('${json['value']}') ?? 0,
    currencyId: (json['currencyId'] ?? '').toString(),
    maintenanceId: json['maintenanceId']?.toString(),
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
  );

  final String id;
  final String userId;
  final String title;
  final String spaceId;
  final String room;
  final String purchased;
  final String warranty;
  final double value;
  final String currencyId;
  final String? maintenanceId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class HouseholdItemPagination {
  const HouseholdItemPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory HouseholdItemPagination.fromJson(Map<String, dynamic> json) =>
      HouseholdItemPagination(
        page: _integer(json['page'], fallback: 1),
        limit: _integer(json['limit'], fallback: 20),
        total: _integer(json['total']),
        totalPages: _integer(json['totalPages']),
        hasNextPage: json['hasNextPage'] == true,
        hasPrevPage: json['hasPrevPage'] == true,
      );

  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;
}

class HouseholdItemPage {
  const HouseholdItemPage({required this.items, required this.pagination});

  factory HouseholdItemPage.fromEnvelope(Map<String, dynamic> envelope) {
    final meta = envelope['meta'] is Map
        ? Map<String, dynamic>.from(envelope['meta'] as Map)
        : const <String, dynamic>{};
    final pagination = meta['pagination'] is Map
        ? Map<String, dynamic>.from(meta['pagination'] as Map)
        : const <String, dynamic>{};
    return HouseholdItemPage(
      items: (envelope['data'] as List? ?? const [])
          .map(
            (value) =>
                HouseholdItem.fromJson(Map<String, dynamic>.from(value as Map)),
          )
          .toList(growable: false),
      pagination: HouseholdItemPagination.fromJson(pagination),
    );
  }

  final List<HouseholdItem> items;
  final HouseholdItemPagination pagination;
}

int _integer(Object? value, {int fallback = 0}) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
