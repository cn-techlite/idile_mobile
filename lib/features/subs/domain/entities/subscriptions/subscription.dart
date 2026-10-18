class SubscriptionItem {
  const SubscriptionItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.spaceId,
    required this.amount,
    required this.currencyId,
    required this.billing,
    required this.renewal,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.warning,
  });

  factory SubscriptionItem.fromJson(Map<String, dynamic> json) =>
      SubscriptionItem(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        userId: (json['userId'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        spaceId: (json['spaceId'] ?? '').toString(),
        amount: json['amount'] is num
            ? (json['amount'] as num).toDouble()
            : double.tryParse('${json['amount']}') ?? 0,
        currencyId: (json['currencyId'] ?? '').toString(),
        billing: (json['billing'] ?? '').toString(),
        renewal: (json['renewal'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        warning: json['warning']?.toString(),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      );

  final String id;
  final String userId;
  final String title;
  final String spaceId;
  final double amount;
  final String currencyId;
  final String billing;
  final String renewal;
  final String status;
  final String? warning;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubscriptionItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? spaceId,
    double? amount,
    String? currencyId,
    String? billing,
    String? renewal,
    String? status,
    Object? warning = _unset,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) => SubscriptionItem(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    spaceId: spaceId ?? this.spaceId,
    amount: amount ?? this.amount,
    currencyId: currencyId ?? this.currencyId,
    billing: billing ?? this.billing,
    renewal: renewal ?? this.renewal,
    status: status ?? this.status,
    warning: identical(warning, _unset) ? this.warning : warning as String?,
    createdAt: identical(createdAt, _unset)
        ? this.createdAt
        : createdAt as DateTime?,
    updatedAt: identical(updatedAt, _unset)
        ? this.updatedAt
        : updatedAt as DateTime?,
  );
}

class SubscriptionPagination {
  const SubscriptionPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory SubscriptionPagination.fromJson(Map<String, dynamic> json) =>
      SubscriptionPagination(
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

class SubscriptionPage {
  const SubscriptionPage({
    required this.subscriptions,
    required this.pagination,
  });

  factory SubscriptionPage.fromEnvelope(Map<String, dynamic> envelope) {
    final meta = envelope['meta'] is Map
        ? Map<String, dynamic>.from(envelope['meta'] as Map)
        : const <String, dynamic>{};
    final pagination = meta['pagination'] is Map
        ? Map<String, dynamic>.from(meta['pagination'] as Map)
        : const <String, dynamic>{};
    return SubscriptionPage(
      subscriptions: (envelope['data'] as List? ?? const [])
          .map(
            (value) => SubscriptionItem.fromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList(growable: false),
      pagination: SubscriptionPagination.fromJson(pagination),
    );
  }

  final List<SubscriptionItem> subscriptions;
  final SubscriptionPagination pagination;
}

int _integer(Object? value, {int fallback = 0}) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

const _unset = Object();
