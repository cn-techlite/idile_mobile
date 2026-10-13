class DocumentItem {
  const DocumentItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.spaceId,
    required this.type,
    required this.expiry,
    required this.related,
    required this.householdItemId,
    required this.assetId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.cloudinaryPublicId,
    this.secureUrl,
    this.resourceType,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) => DocumentItem(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    userId: (json['userId'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    spaceId: (json['spaceId'] ?? '').toString(),
    type: (json['type'] ?? '').toString(),
    expiry: (json['expiry'] ?? '').toString(),
    related: (json['related'] ?? '').toString(),
    householdItemId: (json['householdItemId'] ?? '').toString(),
    assetId: (json['assetId'] ?? '').toString(),
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
  final String expiry;
  final String related;
  final String householdItemId;
  final String assetId;
  final String status;
  final String? cloudinaryPublicId;
  final String? secureUrl;
  final String? resourceType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class DocumentPagination {
  const DocumentPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory DocumentPagination.fromJson(Map<String, dynamic> json) =>
      DocumentPagination(
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

class DocumentPage {
  const DocumentPage({required this.documents, required this.pagination});

  factory DocumentPage.fromEnvelope(Map<String, dynamic> envelope) {
    final meta = envelope['meta'] is Map
        ? Map<String, dynamic>.from(envelope['meta'] as Map)
        : const <String, dynamic>{};
    final pagination = meta['pagination'] is Map
        ? Map<String, dynamic>.from(meta['pagination'] as Map)
        : const <String, dynamic>{};
    return DocumentPage(
      documents: (envelope['data'] as List? ?? const [])
          .map(
            (value) =>
                DocumentItem.fromJson(Map<String, dynamic>.from(value as Map)),
          )
          .toList(growable: false),
      pagination: DocumentPagination.fromJson(pagination),
    );
  }

  final List<DocumentItem> documents;
  final DocumentPagination pagination;
}

int _integer(Object? value, {int fallback = 0}) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
