class CalendarEntry {
  const CalendarEntry({
    required this.date,
    required this.entityType,
    required this.entityId,
    required this.title,
    required this.status,
    this.amount,
    this.currencyId,
  });

  factory CalendarEntry.fromJson(Map<String, dynamic> json) => CalendarEntry(
    date: (json['date'] ?? '').toString(),
    entityType: (json['entityType'] ?? '').toString(),
    entityId: (json['entityId'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    status: (json['status'] ?? '').toString(),
    amount: json['amount'] is num
        ? (json['amount'] as num).toDouble()
        : double.tryParse('${json['amount'] ?? ''}'),
    currencyId: json['currencyId']?.toString(),
  );

  final String date;
  final String entityType;
  final String entityId;
  final String title;
  final String status;
  final double? amount;
  final String? currencyId;
}
