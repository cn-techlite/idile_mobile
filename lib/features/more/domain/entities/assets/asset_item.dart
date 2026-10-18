class AssetItem {
  const AssetItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.spaceId,
    required this.type,
    required this.detail,
    required this.renewal,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.renewalDate,
    this.cloudinaryPublicId,
    this.secureUrl,
    this.resourceType,
  });

  factory AssetItem.fromJson(Map<String, dynamic> json) => AssetItem(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    userId: (json['userId'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    spaceId: (json['spaceId'] ?? '').toString(),
    type: (json['type'] ?? '').toString(),
    detail: (json['detail'] ?? '').toString(),
    renewal: (json['renewal'] ?? '').toString(),
    renewalDate: json['renewalDate']?.toString(),
    status: (json['status'] ?? '').toString(),
    cloudinaryPublicId: json['cloudinaryPublicId']?.toString(),
    secureUrl: json['secureUrl']?.toString(),
    resourceType: json['resourceType']?.toString(),
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
  );

  final String id;
  final String userId;
  final String title;
  final String spaceId;
  final String type;
  final String detail;
  final String renewal;
  final String? renewalDate;
  final String status;
  final String? cloudinaryPublicId;
  final String? secureUrl;
  final String? resourceType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class AssetPagination {
  const AssetPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AssetPagination.fromJson(Map<String, dynamic> json) =>
      AssetPagination(
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

class AssetPage {
  const AssetPage({required this.assets, required this.pagination});

  factory AssetPage.fromEnvelope(Map<String, dynamic> envelope) {
    final meta = envelope['meta'] is Map
        ? Map<String, dynamic>.from(envelope['meta'] as Map)
        : const <String, dynamic>{};
    final pagination = meta['pagination'] is Map
        ? Map<String, dynamic>.from(meta['pagination'] as Map)
        : const <String, dynamic>{};
    return AssetPage(
      assets: (envelope['data'] as List? ?? const [])
          .map(
            (value) =>
                AssetItem.fromJson(Map<String, dynamic>.from(value as Map)),
          )
          .toList(growable: false),
      pagination: AssetPagination.fromJson(pagination),
    );
  }

  final List<AssetItem> assets;
  final AssetPagination pagination;
}

int _integer(Object? value, {int fallback = 0}) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
