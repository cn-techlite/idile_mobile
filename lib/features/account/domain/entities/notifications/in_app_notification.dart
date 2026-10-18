class InAppNotification {
  const InAppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
    required this.updatedAt,
    this.entityType,
    this.entityId,
  });

  factory InAppNotification.fromJson(Map<String, dynamic> json) =>
      InAppNotification(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        userId: (json['userId'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        message: (json['message'] ?? '').toString(),
        entityType: json['entityType']?.toString(),
        entityId: json['entityId']?.toString(),
        read: json['read'] == true,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      );

  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String? entityType;
  final String? entityId;
  final bool read;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InAppNotification copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    Object? entityType = _unset,
    Object? entityId = _unset,
    bool? read,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) => InAppNotification(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    type: type ?? this.type,
    title: title ?? this.title,
    message: message ?? this.message,
    entityType: identical(entityType, _unset)
        ? this.entityType
        : entityType as String?,
    entityId: identical(entityId, _unset) ? this.entityId : entityId as String?,
    read: read ?? this.read,
    createdAt: identical(createdAt, _unset)
        ? this.createdAt
        : createdAt as DateTime?,
    updatedAt: identical(updatedAt, _unset)
        ? this.updatedAt
        : updatedAt as DateTime?,
  );
}

class NotificationPagination {
  const NotificationPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory NotificationPagination.fromJson(Map<String, dynamic> json) =>
      NotificationPagination(
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

class NotificationPage {
  const NotificationPage({
    required this.notifications,
    required this.pagination,
  });

  factory NotificationPage.fromEnvelope(Map<String, dynamic> envelope) {
    final data = envelope['data'] as List? ?? const [];
    final meta = envelope['meta'] is Map
        ? Map<String, dynamic>.from(envelope['meta'] as Map)
        : const <String, dynamic>{};
    final pagination = meta['pagination'] is Map
        ? Map<String, dynamic>.from(meta['pagination'] as Map)
        : const <String, dynamic>{};
    return NotificationPage(
      notifications: data
          .map(
            (value) => InAppNotification.fromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList(growable: false),
      pagination: NotificationPagination.fromJson(pagination),
    );
  }

  final List<InAppNotification> notifications;
  final NotificationPagination pagination;
}

int _integer(Object? value, {int fallback = 0}) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

const _unset = Object();
