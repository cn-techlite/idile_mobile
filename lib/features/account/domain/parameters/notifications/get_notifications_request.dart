class GetNotificationsRequest {
  const GetNotificationsRequest({
    this.page = 1,
    this.limit = 20,
    this.read,
    this.sort,
  });

  final int page;
  final int limit;
  final bool? read;
  final String? sort;

  Map<String, String> toQueryParameters() {
    if (page < 1) {
      throw ArgumentError.value(page, 'page', 'Page must be at least 1.');
    }
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', 'Limit must be from 1 to 100.');
    }
    final normalizedSort = sort?.trim();
    if (normalizedSort != null &&
        normalizedSort.isNotEmpty &&
        !RegExp(r'^[A-Za-z][A-Za-z0-9_.]*:(asc|desc)$')
            .hasMatch(normalizedSort)) {
      throw ArgumentError.value(
        sort,
        'sort',
        'Sort must use field:asc or field:desc.',
      );
    }
    return {
      'page': '$page',
      'limit': '$limit',
      if (read != null) 'read': '$read',
      if (normalizedSort != null && normalizedSort.isNotEmpty)
        'sort': normalizedSort,
    };
  }
}
