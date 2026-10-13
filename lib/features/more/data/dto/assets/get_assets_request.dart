class GetAssetsRequest {
  const GetAssetsRequest({
    this.page = 1,
    this.limit = 20,
    this.sort = 'createdAt:desc',
    this.status,
    this.type,
    this.spaceId,
  });

  final int page;
  final int limit;
  final String? sort;
  final String? status;
  final String? type;
  final String? spaceId;

  Map<String, String> toQueryParameters() {
    if (page < 1) {
      throw ArgumentError.value(page, 'page', 'Page must be at least 1.');
    }
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', 'Limit must be from 1 to 100.');
    }
    final normalizedSort = _optional(sort);
    if (normalizedSort != null &&
        !RegExp(r'^[A-Za-z][A-Za-z0-9_.]*:(asc|desc)$')
            .hasMatch(normalizedSort)) {
      throw ArgumentError.value(
        sort,
        'sort',
        'Sort must use field:asc or field:desc.',
      );
    }
    final normalizedStatus = _optional(status)?.toLowerCase();
    if (normalizedStatus != null &&
        normalizedStatus != 'active' &&
        normalizedStatus != 'expiring') {
      throw ArgumentError.value(
        status,
        'status',
        'Status must be active or expiring.',
      );
    }
    final normalizedType = _type(type);
    final query = <String, String>{'page': '$page', 'limit': '$limit'};
    if (normalizedSort != null) query['sort'] = normalizedSort;
    if (normalizedStatus != null) query['status'] = normalizedStatus;
    if (normalizedType != null) query['type'] = normalizedType;
    final normalizedSpaceId = _optional(spaceId);
    if (normalizedSpaceId != null) query['spaceId'] = normalizedSpaceId;
    return query;
  }
}

String? _optional(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

String? _type(String? value) {
  final normalized = _optional(value)?.toLowerCase();
  if (normalized == null) return null;
  if (normalized == 'hardware') return 'Hardware';
  if (normalized == 'license') return 'License';
  throw ArgumentError.value(value, 'type', 'Type must be Hardware or License.');
}
