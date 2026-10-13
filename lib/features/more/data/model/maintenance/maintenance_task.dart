class MaintenanceTask {
  const MaintenanceTask({
    required this.id,
    required this.userId,
    required this.title,
    required this.spaceId,
    required this.item,
    required this.lastDone,
    required this.nextDue,
    required this.status,
    required this.intervalMonths,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) =>
      MaintenanceTask(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        userId: (json['userId'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        spaceId: (json['spaceId'] ?? '').toString(),
        item: (json['item'] ?? '').toString(),
        lastDone: (json['lastDone'] ?? '').toString(),
        nextDue: (json['nextDue'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        intervalMonths: json['intervalMonths'] is num
            ? (json['intervalMonths'] as num).toInt()
            : int.tryParse('${json['intervalMonths']}') ?? 3,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      );

  final String id;
  final String userId;
  final String title;
  final String spaceId;
  final String item;
  final String lastDone;
  final String nextDue;
  final String status;
  final int intervalMonths;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class MaintenancePagination {
  const MaintenancePagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory MaintenancePagination.fromJson(Map<String, dynamic> json) =>
      MaintenancePagination(
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

class MaintenancePage {
  const MaintenancePage({required this.tasks, required this.pagination});

  factory MaintenancePage.fromEnvelope(Map<String, dynamic> envelope) {
    final meta = envelope['meta'] is Map
        ? Map<String, dynamic>.from(envelope['meta'] as Map)
        : const <String, dynamic>{};
    final pagination = meta['pagination'] is Map
        ? Map<String, dynamic>.from(meta['pagination'] as Map)
        : const <String, dynamic>{};
    return MaintenancePage(
      tasks: (envelope['data'] as List? ?? const [])
          .map(
            (value) => MaintenanceTask.fromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList(growable: false),
      pagination: MaintenancePagination.fromJson(pagination),
    );
  }

  final List<MaintenanceTask> tasks;
  final MaintenancePagination pagination;
}

int _integer(Object? value, {int fallback = 0}) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
