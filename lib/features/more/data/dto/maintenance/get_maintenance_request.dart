class GetMaintenanceRequest {
  const GetMaintenanceRequest({
    this.status,
    this.spaceId,
    this.page = 1,
    this.limit = 20,
    this.sort = 'nextDue:asc',
  });

  static const statuses = {'due', 'soon', 'scheduled'};

  final String? status;
  final String? spaceId;
  final int page;
  final int limit;
  final String? sort;

  Map<String, String> toQueryParameters() {
    if (page < 1) {
      throw ArgumentError.value(page, 'page', 'Page must be at least 1.');
    }
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', 'Limit must be from 1 to 100.');
    }
    final normalizedStatus = _optional(status)?.toLowerCase();
    if (normalizedStatus != null && !statuses.contains(normalizedStatus)) {
      throw ArgumentError.value(status, 'status', 'Unsupported status.');
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
    final query = <String, String>{'page': '$page', 'limit': '$limit'};
    if (normalizedStatus != null) query['status'] = normalizedStatus;
    final normalizedSpaceId = _optional(spaceId);
    if (normalizedSpaceId != null) query['spaceId'] = normalizedSpaceId;
    if (normalizedSort != null) query['sort'] = normalizedSort;
    return query;
  }
}

String? _optional(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
