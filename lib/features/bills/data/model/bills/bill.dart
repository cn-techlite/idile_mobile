class BillPayment {
  const BillPayment({
    required this.paidOn,
    required this.amount,
    required this.currencyId,
  });

  factory BillPayment.fromJson(Map<String, dynamic> json) => BillPayment(
    paidOn: (json['paidOn'] ?? '').toString(),
    amount: _number(json['amount']),
    currencyId: (json['currencyId'] ?? '').toString(),
  );

  final String paidOn;
  final double amount;
  final String currencyId;
}

class Bill {
  const Bill({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.spaceId,
    required this.amount,
    required this.currencyId,
    required this.due,
    required this.status,
    required this.recurrence,
    required this.createdAt,
    required this.updatedAt,
    this.payments = const [],
  });

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    userId: (json['userId'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    category: (json['category'] ?? '').toString(),
    spaceId: (json['spaceId'] ?? '').toString(),
    amount: _number(json['amount']),
    currencyId: (json['currencyId'] ?? '').toString(),
    due: (json['due'] ?? '').toString(),
    status: (json['status'] ?? '').toString(),
    recurrence: (json['recurrence'] ?? '').toString(),
    payments: (json['payments'] as List? ?? const [])
        .map(
          (value) =>
              BillPayment.fromJson(Map<String, dynamic>.from(value as Map)),
        )
        .toList(growable: false),
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
  );

  final String id;
  final String userId;
  final String title;
  final String category;
  final String spaceId;
  final double amount;
  final String currencyId;
  final String due;
  final String status;
  final String recurrence;
  final List<BillPayment> payments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Bill copyWith({
    String? id,
    String? userId,
    String? title,
    String? category,
    String? spaceId,
    double? amount,
    String? currencyId,
    String? due,
    String? status,
    String? recurrence,
    List<BillPayment>? payments,
    Object? createdAt = _unset,
    Object? updatedAt = _unset,
  }) => Bill(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    category: category ?? this.category,
    spaceId: spaceId ?? this.spaceId,
    amount: amount ?? this.amount,
    currencyId: currencyId ?? this.currencyId,
    due: due ?? this.due,
    status: status ?? this.status,
    recurrence: recurrence ?? this.recurrence,
    payments: payments ?? this.payments,
    createdAt: identical(createdAt, _unset)
        ? this.createdAt
        : createdAt as DateTime?,
    updatedAt: identical(updatedAt, _unset)
        ? this.updatedAt
        : updatedAt as DateTime?,
  );
}

class BillPagination {
  const BillPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory BillPagination.fromJson(Map<String, dynamic> json) => BillPagination(
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

class BillPage {
  const BillPage({required this.bills, required this.pagination});

  factory BillPage.fromEnvelope(Map<String, dynamic> envelope) {
    final meta = envelope['meta'] is Map
        ? Map<String, dynamic>.from(envelope['meta'] as Map)
        : const <String, dynamic>{};
    final pagination = meta['pagination'] is Map
        ? Map<String, dynamic>.from(meta['pagination'] as Map)
        : const <String, dynamic>{};
    return BillPage(
      bills: (envelope['data'] as List? ?? const [])
          .map(
            (value) => Bill.fromJson(Map<String, dynamic>.from(value as Map)),
          )
          .toList(growable: false),
      pagination: BillPagination.fromJson(pagination),
    );
  }

  final List<Bill> bills;
  final BillPagination pagination;
}

double _number(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
int _integer(Object? value, {int fallback = 0}) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

const _unset = Object();
